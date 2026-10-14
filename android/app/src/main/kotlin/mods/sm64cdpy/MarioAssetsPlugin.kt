package mods.sm64cdpy

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.InputStream
import java.security.MessageDigest
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference

/** Main-engine-only importer. Immutable generations + one durable pointer prevent mixed assets. */
class MarioAssetsPlugin : FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var binding: ActivityPluginBinding? = null
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val cancelled = AtomicBoolean(false)
    private val reader = AtomicReference<InputStream?>(null)
    private var attached = false
    private var pending: MethodChannel.Result? = null
    private var picking = false
    private val root get() = File(context.noBackupFilesDir, "mario_theme_v${MarioRomDecoder.VERSION}")
    private val preferences get() = context.getSharedPreferences("mario_theme", Context.MODE_PRIVATE)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        attached = true
        channel = MethodChannel(binding.binaryMessenger, "sm64cdpy/mario_assets")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "read" -> runOperation(result) { snapshot() }
                "remove" -> runOperation(result) {
                    val previous = preferences.getString("generation", null)
                    if (!preferences.edit().remove("generation").commit()) {
                        // commit(false) can still change SharedPreferences' in-memory map.
                        preferences.edit().putString("generation", previous).commit()
                        error("Could not remove resources")
                    }
                    emptyMap<String, Any>() // Old immutable files cleaned at next startup, after engine image caches disappear.
                }
                "import" -> {
                    if (pending != null) result.error("busy", "Import already pending", null)
                    else if (this.binding == null) result.error("unavailable", "No activity", null)
                    else {
                        pending = result
                        cancelled.set(false)
                        picking = true
                        try {
                            this.binding!!.activity.startActivityForResult(
                                Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                                    addCategory(Intent.CATEGORY_OPENABLE)
                                    type = "*/*"
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }, 6418)
                        } catch (error: Exception) { finishError("unavailable", error) }
                    }
                }
                "cancel" -> {
                    requestCancellation()
                    // A selected document is consumed once; no persistent URI or ROM copy remains.
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        executor.execute {
            root.mkdirs()
            val active = preferences.getString("generation", null)
            root.listFiles()?.filter { it.name != active }?.forEach { it.deleteRecursively() }
        }
    }

    private fun snapshot(): Map<String, Any> {
        val name = preferences.getString("generation", null) ?: return emptyMap()
        if (!Regex("[a-f0-9-]{36}").matches(name)) {
            preferences.edit().remove("generation").commit()
            return emptyMap()
        }
        val directory = File(root, name)
        val files = MarioRomDecoder.textures.associate { it.id to File(directory, "${it.id}.png") }
        if (MarioRomDecoder.textures.any { texture ->
            val file = files.getValue(texture.id)
            val options = android.graphics.BitmapFactory.Options().apply { inJustDecodeBounds = true }
            if (!file.isFile || file.length() !in 1..65536) true
            else {
                android.graphics.BitmapFactory.decodeFile(file.path, options)
                options.outWidth != texture.width || options.outHeight != texture.height
            }
        }) {
            preferences.edit().remove("generation").commit()
            return emptyMap()
        }
        return mapOf("generation" to name, "files" to files.mapValues { it.value.absolutePath })
    }

    private fun runOperation(result: MethodChannel.Result, operation: () -> Map<String, Any>) {
        if (pending != null) { result.error("busy", "Import already pending", null); return }
        pending = result
        cancelled.set(false)
        executor.execute {
            try { val data = operation(); main.post { finish(data) } }
            catch (error: Exception) { main.post { finishError("storage", error) } }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != 6418) return false
        if (!picking || pending == null) return true
        picking = false
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null || cancelled.get()) {
            finish(null); return true
        }
        executor.execute {
            var staging: File? = null
            try {
                val bytes = ByteArray(MarioRomDecoder.ROM_SIZE)
                context.contentResolver.openInputStream(uri).use { stream ->
                    checkNotNull(stream)
                    reader.set(stream)
                    checkCancelled()
                    var offset = 0
                    while (offset < bytes.size) {
                        checkCancelled()
                        val count = stream.read(bytes, offset, minOf(8192, bytes.size - offset))
                        require(count > 0) { "Invalid ROM size" }
                        offset += count
                    }
                    require(stream.read() == -1) { "Invalid ROM size" }
                }
                reader.set(null)
                val hash = MessageDigest.getInstance("MD5").digest(bytes).joinToString("") { "%02x".format(it.toInt() and 255) }
                require(hash == MarioRomDecoder.ROM_MD5) { "Unsupported ROM" }
                val directory = File(root, UUID.randomUUID().toString())
                staging = directory
                check(directory.mkdirs())
                val segments = mutableMapOf<Int, ByteArray>()
                for (texture in MarioRomDecoder.textures) {
                    checkCancelled()
                    val segment = segments.getOrPut(texture.segment) {
                        require(texture.segment.toLong() + texture.segmentBytes <= bytes.size)
                        MarioRomDecoder.decompress(bytes.copyOfRange(texture.segment, texture.segment + texture.segmentBytes))
                    }
                    val bitmap = Bitmap.createBitmap(MarioRomDecoder.pixels(segment, texture), texture.width, texture.height, Bitmap.Config.ARGB_8888)
                    try {
                        File(directory, "${texture.id}.png").outputStream().use {
                            check(bitmap.compress(Bitmap.CompressFormat.PNG, 100, it))
                            it.fd.sync()
                        }
                        val file = File(directory, "${texture.id}.png")
                        check(file.length() in 1..65536)
                        check(android.graphics.BitmapFactory.decodeFile(file.path)?.let { decoded ->
                            val valid = decoded.width == texture.width && decoded.height == texture.height
                            decoded.recycle(); valid
                        } == true)
                    } finally { bitmap.recycle() }
                }
                // Final commit on main serializes cancellation with the visibility switch.
                main.post {
                    val previous = preferences.getString("generation", null)
                    var attemptedCommit = false
                    try {
                        checkCancelled()
                        check(attached)
                        attemptedCommit = true
                        check(preferences.edit().putString("generation", directory.name).commit())
                        val confirmed = snapshot()
                        check(confirmed.isNotEmpty())
                        finish(confirmed)
                    } catch (error: Exception) {
                        if (attemptedCommit) preferences.edit().putString("generation", previous).commit()
                        directory.deleteRecursively() // At most 15 tiny files, including after executor teardown.
                        finishError(if (cancelled.get()) "cancelled" else "storage", error)
                    }
                }
            } catch (error: Exception) {
                reader.set(null)
                staging?.deleteRecursively()
                main.post { finishError(if (cancelled.get()) "cancelled" else if (error is IllegalArgumentException) "unsupported" else "storage", error) }
            }
        }
        return true
    }

    private fun requestCancellation() {
        cancelled.set(true)
        val stream = reader.getAndSet(null) ?: return
        Thread({ try { stream.close() } catch (_: Exception) {} }, "mario-rom-cancel").apply {
            isDaemon = true
            start()
        }
    }
    private fun checkCancelled() { check(!cancelled.get()) { "Cancelled" } }
    private fun finish(data: Map<String, Any>?) {
        val result = pending; pending = null; picking = false
        if (attached) result?.success(data)
    }
    private fun finishError(code: String, error: Exception) {
        val result = pending; pending = null; picking = false
        if (attached) result?.error(code, error.javaClass.simpleName, null)
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding; binding.addActivityResultListener(this)
    }
    override fun onDetachedFromActivityForConfigChanges() {
        binding?.removeActivityResultListener(this); binding = null
    }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
    override fun onDetachedFromActivity() {
        onDetachedFromActivityForConfigChanges()
        if (picking) { requestCancellation(); finish(null) }
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        attached = false; requestCancellation(); pending = null
        channel.setMethodCallHandler(null)
        executor.shutdown() // queued cleanup and in-flight bounded reads are allowed to finish
    }
}

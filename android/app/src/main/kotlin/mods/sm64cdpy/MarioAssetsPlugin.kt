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
                    else {
                        pending = result
                        cancelled.set(false)
                        importFromUser()
                    }
                }
                "importFile" -> {
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
            root.listFiles()?.filter { it.name != active && it.name != "player_previews" }?.forEach { it.deleteRecursively() }
            if (active == null || File(root, active).isDirectory) {
                File(context.noBackupFilesDir, "mario_theme_v1").listFiles()?.forEach { it.deleteRecursively() }
            }
        }
    }

    private fun snapshot(nameOverride: String? = null, clearInvalid: Boolean = true): Map<String, Any> {
        val name = nameOverride ?: preferences.getString("generation", null) ?: return emptyMap()
        if (!Regex("[a-f0-9-]{36}").matches(name)) {
            if (clearInvalid) preferences.edit().remove("generation").commit()
            return emptyMap()
        }
        var directory = File(root, name)
        val version = if (directory.isDirectory) MarioRomDecoder.VERSION else 1
        if (version == 1) directory = File(File(context.noBackupFilesDir, "mario_theme_v1"), name)
        val specs = if (version == 1) MarioRomDecoder.legacyTextures else MarioRomDecoder.textures
        val dimensions = specs.associate { it.id to (it.width to it.height) }.toMutableMap()
        if (version >= 2) {
            dimensions["panel_light"] = 32 to 32
            dimensions["panel_dark"] = 32 to 32
            MarioRomDecoder.skies.forEach { dimensions[it.id] = 256 to 256 }
        }
        if (version >= 3) {
            val model = File(directory, "player_model.bin")
            if (!model.isFile || model.length() !in 1..524288) {
                if (clearInvalid) preferences.edit().remove("generation").commit()
                return emptyMap()
            }
        }
        val files = dimensions.keys.associateWith { File(directory, "$it.png") }.toMutableMap()
        if (dimensions.any { (id, size) ->
            val file = files.getValue(id)
            val options = android.graphics.BitmapFactory.Options().apply { inJustDecodeBounds = true }
            if (!file.isFile || file.length() !in 1..524288) true
            else {
                android.graphics.BitmapFactory.decodeFile(file.path, options)
                options.outWidth != size.first || options.outHeight != size.second
            }
        }) {
            if (clearInvalid) preferences.edit().remove("generation").commit()
            return emptyMap()
        }
        if (version >= 2) {
            for (id in MarioRomDecoder.fontIds) {
                val file = File(directory, "$id.ttf")
                if (!file.isFile || file.length() !in 1..1048576) {
                    if (clearInvalid) preferences.edit().remove("generation").commit()
                    return emptyMap()
                }
                files[id] = file
            }
        }
        return mapOf("generation" to name, "version" to version, "files" to files.mapValues { it.value.absolutePath })
    }

    private fun saveImage(directory: File, id: String, pixels: IntArray, width: Int, height: Int) {
        checkCancelled()
        val bitmap = Bitmap.createBitmap(pixels, width, height, Bitmap.Config.ARGB_8888)
        val file = File(directory, "$id.png")
        try {
            file.outputStream().use { check(bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)); it.fd.sync() }
            check(file.length() in 1..524288)
            check(android.graphics.BitmapFactory.decodeFile(file.path)?.let { decoded ->
                val valid = decoded.width == width && decoded.height == height
                decoded.recycle(); valid
            } == true)
        } finally { bitmap.recycle() }
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
        importResources { readRom(uri) }
        return true
    }

    private fun readRom(uri: android.net.Uri): ByteArray {
        val bytes = ByteArray(MarioRomDecoder.ROM_SIZE)
        context.contentResolver.openInputStream(uri).use { stream ->
            checkNotNull(stream)
            reader.set(stream)
            try {
                var offset = 0
                while (offset < bytes.size) {
                    checkCancelled()
                    val count = stream.read(bytes, offset, minOf(8192, bytes.size - offset))
                    require(count > 0) { "Invalid ROM size" }
                    offset += count
                }
                require(stream.read() == -1) { "Invalid ROM size" }
            } finally { reader.set(null) }
        }
        val hash = MessageDigest.getInstance("MD5").digest(bytes).joinToString("") { "%02x".format(it.toInt() and 255) }
        require(hash == MarioRomDecoder.ROM_MD5) { "Unsupported ROM" }
        return bytes
    }

    private fun importFromUser() = importResources {
        val user = GameFolderStore.root(context) ?: throw IllegalStateException("game_folder")
        val preferred = user.findFile("baserom.us.z64")?.takeIf { it.isFile }
        val candidates = (listOfNotNull(preferred) + user.listFiles().filter {
            it.isFile && it.name?.endsWith(".z64", true) == true
        }).distinctBy { it.uri }.take(8)
        if (candidates.isEmpty()) throw IllegalStateException("rom_missing")
        var valid: ByteArray? = null
        for (candidate in candidates) {
            checkCancelled()
            try { valid = readRom(candidate.uri); break }
            catch (_: IllegalArgumentException) { /* Check the next direct child, never recurse. */ }
        }
        valid ?: throw IllegalArgumentException("Unsupported ROM")
    }

    private fun importResources(load: () -> ByteArray) {
        executor.execute {
            var staging: File? = null
            try {
                val bytes = load()
                val directory = File(root, UUID.randomUUID().toString())
                staging = directory
                check(directory.mkdirs())
                val segments = mutableMapOf<Int, ByteArray>()
                val pixelsById = mutableMapOf<String, IntArray>()
                fun segment(address: Int, length: Int): ByteArray = segments.getOrPut(address) {
                    require(address.toLong() + length <= bytes.size)
                    MarioRomDecoder.decompress(bytes.copyOfRange(address, address + length))
                }
                val playerSegment = segment(MarioRomDecoder.PLAYER_SEGMENT, MarioRomDecoder.PLAYER_SEGMENT_BYTES)
                File(directory, "player_model.bin").outputStream().use {
                    it.write(playerSegment)
                    it.fd.sync()
                }
                for (texture in MarioRomDecoder.textures) {
                    checkCancelled()
                    val pixels = MarioRomDecoder.pixels(segment(texture.segment, texture.segmentBytes), texture)
                    pixelsById[texture.id] = pixels
                    saveImage(directory, texture.id, pixels, texture.width, texture.height)
                }
                for (sky in MarioRomDecoder.skies) {
                    saveImage(directory, sky.id, MarioRomDecoder.skyPixels(segment(sky.segment, sky.bytes)), 256, 256)
                }
                saveImage(directory, "panel_light", MarioRomDecoder.panelPixels(pixelsById.getValue("stone"), false), 32, 32)
                saveImage(directory, "panel_dark", MarioRomDecoder.panelPixels(pixelsById.getValue("stone_dark"), true), 32, 32)
                fun glyphs(prefix: String): MutableMap<Char, MarioPixelFont.Glyph> = MarioRomDecoder.textures
                    .filter { it.id.startsWith(prefix) }
                    .associate { it.id.last() to MarioPixelFont.Glyph(pixelsById.getValue(it.id), it.width, it.height) }.toMutableMap()
                val menu = glyphs("menu_glyph_")
                ('A'..'Z').forEach { menu[it.lowercaseChar()] = menu.getValue(it) }
                val dialog = glyphs("dialog_glyph_")
                val hud = glyphs("hud_glyph_")
                ('0'..'9').forEach { hud[it] = MarioPixelFont.Glyph(pixelsById.getValue("digit_$it"), 16, 16) }
                ('A'..'Z').forEach { if (hud[it] == null) hud[it] = menu.getValue(it); hud[it.lowercaseChar()] = hud.getValue(it) }
                val fonts = listOf("font_menu" to menu, "font_dialog" to dialog, "font_hud" to hud)
                for ((id, glyphs) in fonts) {
                    checkCancelled()
                    val file = File(directory, "$id.ttf")
                    file.outputStream().use { it.write(MarioPixelFont.build("SM64 ROM ${id.removePrefix("font_")}", glyphs)); it.fd.sync() }
                    check(file.length() in 1..1048576)
                    // Parse actual generated TrueType before publishing the generation.
                    android.graphics.Typeface.createFromFile(file)
                }
                val confirmed = snapshot(directory.name, clearInvalid = false)
                check(confirmed.isNotEmpty())
                // Disk scans/conversion stay off UI; only the small pointer commit is serialized with cancellation.
                main.post {
                    val previous = preferences.getString("generation", null)
                    var attemptedCommit = false
                    try {
                        checkCancelled()
                        check(attached)
                        attemptedCommit = true
                        check(preferences.edit().putString("generation", directory.name).commit())
                        check(preferences.getString("generation", null) == directory.name)
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
                main.post { finishError(if (cancelled.get()) "cancelled" else if (error.message in setOf("game_folder", "rom_missing")) error.message!! else if (error is IllegalArgumentException) "unsupported" else "storage", error) }
            }
        }
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

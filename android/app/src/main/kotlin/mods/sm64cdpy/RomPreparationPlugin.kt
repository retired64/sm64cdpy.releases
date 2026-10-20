package mods.sm64cdpy

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream
import java.security.MessageDigest
import java.util.UUID
import java.util.concurrent.CancellationException
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference

/** Main-engine-only, streaming ROM preparation with no broad storage permission. */
class RomPreparationPlugin : FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener,
    EventChannel.StreamHandler {
    companion object {
        private const val METHOD_CHANNEL = "sm64cdpy/rom_preparation"
        private const val EVENT_CHANNEL = "sm64cdpy/rom_preparation_events"
        private const val PICK_ROM = 7421
        private const val CREATE_ROM = 7422
        private const val PROGRESS_INTERVAL_MS = 150L
    }

    private lateinit var context: Context
    private lateinit var methods: MethodChannel
    private lateinit var events: EventChannel
    private var activityBinding: ActivityPluginBinding? = null
    private val executor = Executors.newSingleThreadExecutor { runnable -> Thread(runnable, "rom-preparation") }
    private val main = Handler(Looper.getMainLooper())
    private val lock = Any()
    private val cancelled = AtomicBoolean(false)
    private val input = AtomicReference<InputStream?>(null)
    private val output = AtomicReference<OutputStream?>(null)
    private var sink: EventChannel.EventSink? = null
    private var attached = false
    private var revision = 0L
    private var snapshot: Map<String, Any?> = baseSnapshot("idle")
    private var operationId: String? = null
    private var staging: File? = null
    private var sourceFormat: String? = null
    private var sourceName: String? = null
    private var sourceUri: Uri? = null
    private var awaitingPicker: Int? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        attached = true
        methods = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        events = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        events.setStreamHandler(this)
        methods.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "snapshot" -> result.success(currentSnapshot())
                    "pickAndPrepare" -> result.success(startPicker())
                    "export" -> result.success(startExportPicker())
                    "cancel" -> result.success(cancel())
                    "discard" -> result.success(discard())
                    else -> result.notImplemented()
                }
            } catch (error: RomPreparationException) {
                result.error(error.code, error.message, null)
            } catch (error: Exception) {
                result.error("unexpected", error.message, error.javaClass.simpleName)
            }
        }
        executor.execute { cleanupOrphans() }
    }

    private fun startPicker(): Map<String, Any?> {
        val binding = activityBinding ?: throw RomPreparationException("unavailable", "Activity is unavailable")
        val previousStaging: File?
        synchronized(lock) {
            if (isBusy(snapshot["phase"] as? String)) throw RomPreparationException("busy", "Preparation is already active")
            previousStaging = staging
            staging = null
            operationId = UUID.randomUUID().toString()
            sourceFormat = null
            sourceName = null
            sourceUri = null
            cancelled.set(false)
            awaitingPicker = PICK_ROM
            updateLocked("picking")
        }
        executor.execute { previousStaging?.parentFile?.deleteRecursively() }
        try {
            binding.activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "*/*"
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                putExtra(Intent.EXTRA_LOCAL_ONLY, false)
            }, PICK_ROM)
        } catch (error: Exception) {
            fail("unavailable", error)
        }
        return currentSnapshot()
    }

    private fun startExportPicker(): Map<String, Any?> {
        val binding = activityBinding ?: throw RomPreparationException("unavailable", "Activity is unavailable")
        synchronized(lock) {
            if (snapshot["canExport"] != true || staging?.isFile != true) {
                throw RomPreparationException("not_prepared", "No verified ROM is ready")
            }
            cancelled.set(false)
            awaitingPicker = CREATE_ROM
            updateLocked("choosingDestination")
        }
        try {
            binding.activity.startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/octet-stream"
                putExtra(Intent.EXTRA_TITLE, "baserom.us.z64")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }, CREATE_ROM)
        } catch (error: Exception) {
            synchronized(lock) {
                awaitingPicker = null
                updateLocked("prepared", inputName = sourceName, format = sourceFormat)
            }
            throw RomPreparationException("unavailable", error.message ?: "Document picker unavailable")
        }
        return currentSnapshot()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_ROM && requestCode != CREATE_ROM) return false
        val expected = synchronized(lock) { awaitingPicker }
        if (expected != requestCode) return true
        synchronized(lock) { awaitingPicker = null }
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null || cancelled.get()) {
            synchronized(lock) {
                if (requestCode == CREATE_ROM && staging?.isFile == true) {
                    updateLocked("prepared", inputName = sourceName, format = sourceFormat)
                } else {
                    updateLocked("idle")
                }
            }
            return true
        }
        if (requestCode == PICK_ROM) prepare(uri) else export(uri)
        return true
    }

    private fun prepare(uri: Uri) {
        synchronized(lock) {
            sourceName = displayName(uri)
            sourceUri = uri
            updateLocked("inspecting", inputName = sourceName)
        }
        executor.execute {
            val directory = File(context.cacheDir, "rom_preparation/${operationId}")
            val target = File(directory, "baserom.us.z64")
            try {
                if (!directory.mkdirs() && !directory.isDirectory) throw java.io.IOException("Could not create staging")
                val stream = context.contentResolver.openInputStream(uri)
                    ?: throw RomPreparationException("read_failed", "The selected document cannot be opened")
                input.set(stream)
                FileOutputStream(target).use { fileOutput ->
                    output.set(fileOutput)
                    val lastEvent = longArrayOf(0L)
                    synchronized(lock) { updateLocked("converting", inputName = sourceName, processed = 0L, total = MarioRomDecoder.ROM_SIZE.toLong()) }
                    val conversion = stream.use {
                        RomByteOrderConverter.convertToZ64(
                            it,
                            fileOutput,
                            cancelled = cancelled::get,
                            onProgress = { processed, total ->
                                val now = android.os.SystemClock.elapsedRealtime()
                                if (processed == total || now - lastEvent[0] >= PROGRESS_INTERVAL_MS) {
                                    lastEvent[0] = now
                                    synchronized(lock) { updateLocked("converting", inputName = sourceName, processed = processed, total = total) }
                                }
                            },
                        )
                    }
                    fileOutput.fd.sync()
                    sourceFormat = conversion.sourceFormat.wireName
                }
                input.set(null); output.set(null)
                synchronized(lock) { updateLocked("validating", inputName = sourceName, format = sourceFormat) }
                verifyFile(target)
                staging = target
                synchronized(lock) { updateLocked("prepared", inputName = sourceName, format = sourceFormat, processed = MarioRomDecoder.ROM_SIZE.toLong(), total = MarioRomDecoder.ROM_SIZE.toLong()) }
            } catch (error: Exception) {
                input.set(null); output.set(null)
                target.delete(); directory.delete()
                handleFailure(error)
            }
        }
    }

    private fun export(uri: Uri) {
        val source = staging ?: return fail("not_prepared", RomPreparationException("not_prepared", "Staging file is missing"))
        if (uri == sourceUri) return fail("export_failed", RomPreparationException("export_failed", "Destination must differ from source"), keepPrepared = true)
        executor.execute {
            try {
                synchronized(lock) { updateLocked("exporting", inputName = sourceName, format = sourceFormat, processed = 0L, total = source.length()) }
                FileInputStream(source).use { reader ->
                    input.set(reader)
                    val writer = context.contentResolver.openOutputStream(uri, "wt")
                        ?: throw RomPreparationException("export_failed", "Destination cannot be opened")
                    writer.use {
                        output.set(it)
                        val buffer = ByteArray(64 * 1024)
                        var copied = 0L
                        var lastEvent = 0L
                        while (true) {
                            checkCancelled()
                            val count = reader.read(buffer)
                            if (count < 0) break
                            if (count == 0) {
                                val single = reader.read()
                                if (single < 0) break
                                it.write(single)
                                copied++
                            } else {
                                it.write(buffer, 0, count)
                                copied += count
                            }
                            val now = android.os.SystemClock.elapsedRealtime()
                            if (copied == source.length() || now - lastEvent >= PROGRESS_INTERVAL_MS) {
                                lastEvent = now
                                synchronized(lock) { updateLocked("exporting", inputName = sourceName, format = sourceFormat, processed = copied, total = source.length()) }
                            }
                        }
                        it.flush()
                    }
                }
                input.set(null); output.set(null)
                synchronized(lock) { updateLocked("verifyingExport", inputName = sourceName, format = sourceFormat) }
                verifyUri(uri)
                val outputName = displayName(uri) ?: "baserom.us.z64"
                source.delete(); source.parentFile?.delete(); staging = null
                synchronized(lock) { updateLocked("saved", inputName = sourceName, outputName = outputName, format = sourceFormat, processed = MarioRomDecoder.ROM_SIZE.toLong(), total = MarioRomDecoder.ROM_SIZE.toLong()) }
            } catch (error: Exception) {
                input.set(null); output.set(null)
                try { DocumentsContract.deleteDocument(context.contentResolver, uri) } catch (_: Exception) {}
                handleFailure(error, keepPrepared = source.isFile)
            }
        }
    }

    private fun verifyFile(file: File) {
        if (file.length() != MarioRomDecoder.ROM_SIZE.toLong()) throw RomPreparationException("verification_failed", "Prepared size changed")
        FileInputStream(file).use { verifyStream(it) }
    }

    private fun verifyUri(uri: Uri) {
        val stream = context.contentResolver.openInputStream(uri)
            ?: throw RomPreparationException("verification_failed", "Saved document cannot be reopened")
        input.set(stream)
        try { stream.use { verifyStream(it) } } finally { input.set(null) }
    }

    private fun verifyStream(stream: InputStream) {
        val digest = MessageDigest.getInstance("MD5")
        val buffer = ByteArray(64 * 1024)
        var countTotal = 0L
        while (true) {
            checkCancelled()
            val count = stream.read(buffer)
            if (count < 0) break
            if (count == 0) continue
            countTotal += count
            if (countTotal > MarioRomDecoder.ROM_SIZE) throw RomPreparationException("verification_failed", "Saved document is too large")
            digest.update(buffer, 0, count)
        }
        val hash = digest.digest().joinToString("") { "%02x".format(it.toInt() and 0xff) }
        if (countTotal != MarioRomDecoder.ROM_SIZE.toLong() || hash != MarioRomDecoder.ROM_MD5) {
            throw RomPreparationException("verification_failed", "Saved document did not pass verification")
        }
    }

    private fun cancel(): Map<String, Any?> {
        val phase = synchronized(lock) { snapshot["phase"] as? String }
        if (!isBusy(phase)) return currentSnapshot()
        cancelled.set(true)
        synchronized(lock) { updateLocked("cancelling") }
        closeAsync(input.getAndSet(null)); closeAsync(output.getAndSet(null))
        if (awaitingPicker != null) synchronized(lock) {
            awaitingPicker = null
            if (staging?.isFile == true) {
                updateLocked("prepared", inputName = sourceName, format = sourceFormat)
            } else {
                updateLocked("cancelled")
            }
        }
        return currentSnapshot()
    }

    private fun discard(): Map<String, Any?> {
        val file = synchronized(lock) {
            if (isBusy(snapshot["phase"] as? String)) {
                throw RomPreparationException("busy", "Preparation is still active")
            }
            staging.also { staging = null }
        }
        executor.execute { file?.parentFile?.deleteRecursively() }
        synchronized(lock) {
            operationId = null; sourceFormat = null; sourceName = null; sourceUri = null; cancelled.set(false)
            updateLocked("idle")
        }
        return currentSnapshot()
    }

    private fun handleFailure(error: Exception, keepPrepared: Boolean = false) {
        if (error is CancellationException || cancelled.get()) {
            synchronized(lock) {
                if (keepPrepared) {
                    updateLocked("prepared", inputName = sourceName, format = sourceFormat)
                } else {
                    updateLocked("cancelled")
                }
            }
            return
        }
        val code = (error as? RomPreparationException)?.code ?: when (error) {
            is SecurityException -> "permission"
            is java.io.FileNotFoundException -> "permission"
            is java.io.IOException -> "storage"
            else -> "unexpected"
        }
        fail(code, error, keepPrepared)
    }

    private fun fail(code: String, error: Exception, keepPrepared: Boolean = false) {
        synchronized(lock) {
            updateLocked("failed", inputName = sourceName, format = sourceFormat, errorCode = code,
                technicalDetail = error.javaClass.simpleName, canExport = keepPrepared)
        }
    }

    private fun checkCancelled() { if (cancelled.get()) throw CancellationException("Cancelled") }
    private fun isBusy(phase: String?) = phase in setOf("picking", "inspecting", "converting", "validating", "choosingDestination", "exporting", "verifyingExport", "cancelling")
    private fun closeAsync(stream: java.io.Closeable?) { if (stream != null) Thread({ try { stream.close() } catch (_: Exception) {} }, "rom-preparation-cancel").apply { isDaemon = true; start() } }

    private fun updateLocked(
        phase: String,
        inputName: String? = null,
        outputName: String? = null,
        format: String? = null,
        processed: Long? = null,
        total: Long? = null,
        errorCode: String? = null,
        technicalDetail: String? = null,
        canExport: Boolean = false,
    ) {
        revision++
        snapshot = baseSnapshot(phase) + mapOf(
            "operationId" to operationId,
            "revision" to revision,
            "inputName" to inputName,
            "outputName" to outputName,
            "sourceFormat" to format,
            "processedBytes" to processed,
            "totalBytes" to total,
            "errorCode" to errorCode,
            "technicalDetail" to technicalDetail,
            "canExport" to (phase == "prepared" || canExport),
        )
        emit(snapshot)
    }

    private fun baseSnapshot(phase: String): Map<String, Any?> = mapOf("phase" to phase, "revision" to revision)
    private fun currentSnapshot(): Map<String, Any?> = synchronized(lock) { HashMap(snapshot) }
    private fun emit(value: Map<String, Any?>) { main.post { if (attached) sink?.success(value) } }
    private fun displayName(uri: Uri): String? {
        var cursor: Cursor? = null
        return try {
            cursor = context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            if (cursor?.moveToFirst() == true) cursor.getString(0) else null
        } catch (_: Exception) { null } finally { cursor?.close() }
    }
    private fun cleanupOrphans() { File(context.cacheDir, "rom_preparation").listFiles()?.forEach { it.deleteRecursively() } }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) { sink = eventSink; eventSink.success(currentSnapshot()) }
    override fun onCancel(arguments: Any?) { sink = null }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activityBinding = binding; binding.addActivityResultListener(this) }
    override fun onDetachedFromActivityForConfigChanges() { activityBinding?.removeActivityResultListener(this); activityBinding = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this); activityBinding = null
        if (awaitingPicker != null) { awaitingPicker = null; synchronized(lock) { updateLocked(if (staging?.isFile == true) "prepared" else "cancelled") } }
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        attached = false; cancelled.set(true); closeAsync(input.getAndSet(null)); closeAsync(output.getAndSet(null))
        methods.setMethodCallHandler(null); events.setStreamHandler(null); sink = null
        val file = staging; staging = null
        executor.execute { file?.parentFile?.deleteRecursively() }
        executor.shutdown()
    }
}

package mods.sm64cdpy

import android.content.Context
import android.util.AtomicFile
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest
import java.time.Instant
import org.json.JSONArray
import org.json.JSONObject

/**
 * Canonical native evidence of a completed installation. The store is private
 * to the application and intentionally contains no SAF URI or download URL.
 */
object InstallationReceiptStore {
    const val SCHEMA_VERSION = 1
    private const val RECEIPTS_DIRECTORY = "installation_receipts_v1"
    private const val QUARANTINE_DIRECTORY = "quarantine"
    private const val HISTORY_FILE = "installation_history_v1.json"
    private const val MAX_HISTORY_EVENTS = 500
    private val writeLock = Any()

    data class WriteResult(
        val eventKind: String,
        val receiptFileName: String,
        internal val installWorkerId: String,
        internal val previousContent: ByteArray?
    )

    fun writeConfirmed(
        context: Context,
        identity: InstallIdentityMetadata,
        destination: String,
        displayTitle: String,
        installWorkerId: String,
        manifest: SafZipExtractor.WriteManifest
    ): WriteResult {
        require(destination == "mods" || destination == "dynos") {
            "Unknown install destination: $destination"
        }
        require(manifest.fileCount > 0) { "Cannot record an empty installation" }
        require(manifest.sentinels.isNotEmpty()) { "Installation has no verifiable sentinels" }

        synchronized(writeLock) {
            val directory = File(context.filesDir, RECEIPTS_DIRECTORY)
            if (!directory.exists() && !directory.mkdirs()) {
                throw IllegalStateException("Could not create the installation receipt store")
            }

            val receiptName = "${sha256(identity.artifactKey)}.json"
            val target = File(directory, receiptName)
            val previousContent = target.takeIf(File::isFile)?.readBytes()
            val eventKind = when {
                target.isFile -> "reinstall"
                else -> "install"
            }

            val sentinels = JSONArray()
            manifest.sentinels.forEach { entry ->
                sentinels.put(
                    JSONObject()
                        .put("relativePath", entry.relativePath)
                        .put("kind", entry.kind)
                )
            }
            val displaySnapshot = JSONObject()
                .put("title", displayTitle)
                .put("versionLabel", identity.versionLabel ?: JSONObject.NULL)
                .put("filename", identity.fileName ?: JSONObject.NULL)
            val receipt = JSONObject()
                .put("schemaVersion", SCHEMA_VERSION)
                .put("contentKey", identity.contentKey)
                .put("artifactKey", identity.artifactKey)
                .put("operationKey", identity.operationKey)
                .put("section", identity.section)
                .put("contentId", identity.contentId)
                .put("artifactId", identity.artifactId)
                .put("destination", destination)
                .put("installedAt", Instant.now().toString())
                .put("installWorkerId", installWorkerId)
                .put("eventKind", eventKind)
                .put("fileCount", manifest.fileCount)
                .put("sentinels", sentinels)
                .put("source", "sm64cdpy")
                .put("displaySnapshot", displaySnapshot)
                .put("packageShape", manifest.packageShape.wireValue)

            try {
                writeAtomically(target, receipt.toString().toByteArray(Charsets.UTF_8))
                appendHistory(context, receipt)
            } catch (error: Exception) {
                restoreReceipt(target, previousContent)
                throw IllegalStateException(
                    "Files were copied, but the installation receipt could not be saved",
                    error
                )
            }
            return WriteResult(eventKind, receiptName, installWorkerId, previousContent)
        }
    }

    /** Restores the prior receipt if this exact Worker was cancelled after writing. */
    fun rollbackIfCurrent(context: Context, write: WriteResult) {
        synchronized(writeLock) {
            val target = File(
                File(context.filesDir, RECEIPTS_DIRECTORY),
                write.receiptFileName
            )
            val belongsToWorker = try {
                JSONObject(target.readText(Charsets.UTF_8))
                    .optString("installWorkerId") == write.installWorkerId
            } catch (_: Exception) {
                false
            }
            if (!belongsToWorker) return

            if (write.previousContent == null) {
                target.delete()
            } else {
                writeAtomically(target, write.previousContent)
            }
            removeHistoryEvent(context, write.installWorkerId)
        }
    }

    fun readSnapshot(context: Context): Map<String, Any> = synchronized(writeLock) {
        val receiptsDirectory = File(context.filesDir, RECEIPTS_DIRECTORY)
        val issues = mutableListOf<Map<String, String>>()
        val receiptQuarantine = File(receiptsDirectory, QUARANTINE_DIRECTORY)
        receiptQuarantine.listFiles().orEmpty().filter(File::isFile).forEach {
            issues += mapOf("file" to it.name, "reason" to "Receipt quarantined")
        }
        val historyQuarantine = File(context.filesDir, QUARANTINE_DIRECTORY)
        historyQuarantine.listFiles().orEmpty().filter(File::isFile).forEach {
            issues += mapOf("file" to it.name, "reason" to "History quarantined")
        }
        val receipts = receiptsDirectory.listFiles()
            .orEmpty()
            .filter { it.isFile && it.extension == "json" }
            .sortedBy { it.name }
            .mapNotNull { file ->
                readValidated(file, issues, receiptsDirectory)?.let(::jsonObjectToMap)
            }

        val historyFile = File(context.filesDir, HISTORY_FILE)
        val history = if (!historyFile.isFile) {
            emptyList()
        } else {
            try {
                val array = JSONArray(historyFile.readText(Charsets.UTF_8))
                buildList {
                    for (index in 0 until array.length()) {
                        val item = array.optJSONObject(index)
                            ?: throw IllegalArgumentException("History entry $index is not an object")
                        validateReceipt(item)
                        add(jsonObjectToMap(item))
                    }
                }.sortedByDescending { it["installedAt"] as String }
            } catch (error: Exception) {
                quarantine(historyFile, File(context.filesDir, QUARANTINE_DIRECTORY))
                issues += mapOf(
                    "file" to HISTORY_FILE,
                    "reason" to (error.message ?: "Invalid installation history")
                )
                emptyList()
            }
        }

        mapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "receipts" to receipts,
            "history" to history,
            "issues" to issues
        )
    }

    fun clearHistory(context: Context) = synchronized(writeLock) {
        writeAtomically(File(context.filesDir, HISTORY_FILE), JSONArray().toString().toByteArray())
        File(context.filesDir, QUARANTINE_DIRECTORY)
            .listFiles().orEmpty().forEach(File::delete)
    }

    private fun appendHistory(context: Context, receipt: JSONObject) {
        val file = File(context.filesDir, HISTORY_FILE)
        val items = mutableListOf<JSONObject>()
        if (file.isFile) {
            try {
                val current = JSONArray(file.readText(Charsets.UTF_8))
                for (index in 0 until current.length()) {
                    val item = current.optJSONObject(index)
                        ?: throw IllegalArgumentException("Invalid history entry")
                    validateReceipt(item)
                    items += item
                }
            } catch (_: Exception) {
                quarantine(file, File(context.filesDir, QUARANTINE_DIRECTORY))
            }
        }
        items.removeAll { it.optString("installWorkerId") == receipt.optString("installWorkerId") }
        items += JSONObject(receipt.toString())
        val retained = items.sortedByDescending { it.getString("installedAt") }
            .take(MAX_HISTORY_EVENTS)
        val output = JSONArray()
        retained.forEach(output::put)
        writeAtomically(file, output.toString().toByteArray(Charsets.UTF_8))
    }

    private fun removeHistoryEvent(context: Context, workerId: String) {
        val file = File(context.filesDir, HISTORY_FILE)
        if (!file.isFile) return
        val current = JSONArray(file.readText(Charsets.UTF_8))
        val output = JSONArray()
        for (index in 0 until current.length()) {
            val item = current.optJSONObject(index) ?: continue
            if (item.optString("installWorkerId") != workerId) output.put(item)
        }
        writeAtomically(file, output.toString().toByteArray(Charsets.UTF_8))
    }

    private fun readValidated(
        file: File,
        issues: MutableList<Map<String, String>>,
        receiptsDirectory: File
    ): JSONObject? = try {
        val receipt = JSONObject(file.readText(Charsets.UTF_8))
        validateReceipt(receipt)
        require(file.name == "${sha256(receipt.getString("artifactKey"))}.json") {
            "Receipt filename does not match artifactKey"
        }
        receipt
    } catch (error: Exception) {
        quarantine(file, File(receiptsDirectory, QUARANTINE_DIRECTORY))
        issues += mapOf(
            "file" to file.name,
            "reason" to (error.message ?: "Invalid installation receipt")
        )
        null
    }

    private fun validateReceipt(receipt: JSONObject) {
        require(receipt.getInt("schemaVersion") == SCHEMA_VERSION) {
            "Unsupported receipt schema"
        }
        val section = receipt.requiredString("section")
        require(section in setOf("mods", "vip", "dynos", "touch_controls", "omm", "render96"))
        val contentKey = receipt.requiredString("contentKey")
        val artifactKey = receipt.requiredString("artifactKey")
        receipt.requiredString("contentId")
        receipt.requiredString("artifactId")
        require(contentKey.startsWith("v1|$section|"))
        require(artifactKey.startsWith("$contentKey|"))
        require(receipt.requiredString("operationKey") == artifactKey)
        require(receipt.requiredString("destination") in setOf("mods", "dynos"))
        require(receipt.requiredString("eventKind") in setOf("install", "update", "reinstall"))
        require(receipt.requiredString("source") in setOf("sm64cdpy", "external"))
        require(receipt.requiredString("installWorkerId").isNotEmpty())
        Instant.parse(receipt.requiredString("installedAt"))
        require(receipt.getInt("fileCount") > 0)
        require(receipt.getString("packageShape") in setOf(
            "loose_file", "single_root", "multiple_roots", "root_files"
        ))
        val sentinels = receipt.getJSONArray("sentinels")
        require(sentinels.length() in 1..SafZipExtractor.MAX_SENTINELS)
        for (index in 0 until sentinels.length()) {
            val sentinel = sentinels.getJSONObject(index)
            val path = sentinel.requiredString("relativePath")
            require(SafZipExtractor.sanitizeEntryName(path) == path)
            require(sentinel.requiredString("kind") == "file")
        }
        receipt.getJSONObject("displaySnapshot").requiredString("title")
    }

    private fun JSONObject.requiredString(key: String): String {
        require(has(key) && !isNull(key)) { "Missing $key" }
        return getString(key).trim().also {
            require(it.isNotEmpty()) { "Missing $key" }
        }
    }

    private fun jsonObjectToMap(value: JSONObject): Map<String, Any?> = buildMap {
        val keys = value.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            put(key, jsonValue(value.get(key)))
        }
    }

    private fun jsonValue(value: Any?): Any? = when (value) {
        JSONObject.NULL, null -> null
        is JSONObject -> jsonObjectToMap(value)
        is JSONArray -> List(value.length()) { jsonValue(value.get(it)) }
        else -> value
    }

    private fun quarantine(file: File, directory: File) {
        if (!directory.exists()) directory.mkdirs()
        val target = File(directory, "${System.currentTimeMillis()}-${file.name}")
        if (!file.renameTo(target)) file.delete()
    }

    private fun restoreReceipt(target: File, previousContent: ByteArray?) {
        if (previousContent == null) target.delete() else writeAtomically(target, previousContent)
    }

    private fun writeAtomically(target: File, content: ByteArray) {
        val atomicFile = AtomicFile(target)
        var stream: FileOutputStream? = null
        try {
            stream = atomicFile.startWrite()
            stream.write(content)
            stream.flush()
            stream.fd.sync()
            atomicFile.finishWrite(stream)
        } catch (error: Exception) {
            stream?.let(atomicFile::failWrite)
            throw error
        }
    }

    private fun sha256(value: String): String = MessageDigest
        .getInstance("SHA-256")
        .digest(value.toByteArray(Charsets.UTF_8))
        .joinToString("") { "%02x".format(it) }
}

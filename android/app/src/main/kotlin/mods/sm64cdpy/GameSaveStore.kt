package mods.sm64cdpy

import android.content.Context
import androidx.documentfile.provider.DocumentFile
import java.io.File
import java.security.MessageDigest
import java.util.UUID

internal object GameSaveStore {
    private fun hash(bytes: ByteArray) = MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it.toInt() and 255) }
    private fun document(context: Context): DocumentFile = GameFolderStore.root(context)?.findFile("sm64_save_file.bin")?.takeIf { it.isFile && it.canRead() } ?: error("missing")
    private fun read(context: Context, file: DocumentFile): ByteArray {
        val bytes = context.contentResolver.openInputStream(file.uri)?.use { it.readBytesBounded() } ?: error("access")
        require(bytes.size <= 512) { "size" }; return bytes
    }
    private fun java.io.InputStream.readBytesBounded(): ByteArray {
        val out = java.io.ByteArrayOutputStream()
        val buffer = ByteArray(513)
        while (out.size() < 513) { val n = read(buffer, 0, 513 - out.size()); if (n < 0) break; out.write(buffer, 0, n) }
        return out.toByteArray()
    }
    private fun directory(context: Context, file: DocumentFile) = File(context.noBackupFilesDir, "game_save_backups/${hash(file.uri.toString().toByteArray())}").apply { check(mkdirs() || isDirectory) }
    private fun backup(context: Context, file: DocumentFile, bytes: ByteArray) {
        val target = File(directory(context, file), "${System.currentTimeMillis()}-${UUID.randomUUID()}.bin")
        target.outputStream().use { it.write(bytes); it.fd.sync() }
        require(target.readBytes().contentEquals(bytes)) { "verify" }
        // Keep recovery history; never prune a backup during a failed mutation.
    }
    fun snapshot(context: Context): Map<String, Any?> = synchronized(InstallationSafAccessCoordinator.lock) {
        val file = document(context); val bytes = read(context, file); val codec = runCatching { GameSaveCodec(bytes) }.getOrNull()
        mapOf("revision" to hash(bytes), "identity" to file.uri.toString(), "damaged" to (codec == null), "slots" to if (codec == null) emptyList<Map<String, Any?>>() else (0..3).flatMap { slot -> (0..1).map { bank ->
            mapOf("slot" to slot, "bank" to bank, "valid" to codec.valid(slot, bank), "empty" to (!codec.valid(slot, bank) && codec.empty(slot, bank) || codec.flags(slot, bank) and 1 == 0),
                "stars" to codec.stars(slot, bank), "coins" to codec.coins(slot, bank), "cannons" to codec.cannons(slot, bank), "flags" to codec.flags(slot, bank), "total" to codec.total(slot, bank))
        } }, "backups" to directory(context, file).listFiles()?.filter { it.name.endsWith(".bin") && it.length() <= 512L }?.sortedByDescending { it.name }?.map { mapOf("id" to it.name, "time" to it.lastModified()) }.orEmpty())
    }
    fun mutate(context: Context, arguments: Map<*, *>): Map<String, Any?> = synchronized(InstallationSafAccessCoordinator.lock) {
        val query = androidx.work.WorkQuery.Builder.fromStates(listOf(
            androidx.work.WorkInfo.State.ENQUEUED, androidx.work.WorkInfo.State.RUNNING, androidx.work.WorkInfo.State.BLOCKED)).build()
        require(androidx.work.WorkManager.getInstance(context).getWorkInfos(query).get().none { info ->
            info.tags.any { it == ModInstallWorker::class.java.name || it == ModDownloadWorker::class.java.name }
        }) { "installing" }
        val file = document(context); require(file.canWrite()) { "access" }
        require(file.uri.toString() == arguments["identity"]) { "conflict" }
        val before = read(context, file); require(hash(before) == arguments["revision"]) { "conflict" }
        val action = arguments["action"] as? String ?: error("invalid")
        if (action == "backup") { backup(context, file, before); return@synchronized snapshot(context) }
        val next = if (action == "restore") {
            val id = arguments["backup"] as? String ?: error("invalid")
            require(Regex("""[0-9]+-[a-f0-9-]{36}\.bin""").matches(id)) { "invalid" }
            val source = File(directory(context, file), id); require(source.isFile && source.length() == 512L) { "missing" }
            source.readBytes().also { GameSaveCodec(it) }
        } else {
            val codec = GameSaveCodec(before)
            val slot = (arguments["slot"] as? Number)?.toInt() ?: error("invalid")
            when (action) {
                "erase" -> codec.erase(slot)
                "copy" -> codec.copy(slot, (arguments["destination"] as? Number)?.toInt() ?: error("invalid"))
                "edit" -> codec.edit(slot, (arguments["bank"] as? Number)?.toInt() ?: error("invalid"),
                    (arguments["stars"] as? List<*>)?.map { (it as Number).toInt() } ?: error("invalid"),
                    (arguments["coins"] as? List<*>)?.map { (it as Number).toInt() } ?: error("invalid"),
                    (arguments["cannons"] as? List<*>)?.map { it as Boolean } ?: error("invalid"),
                    (arguments["castle"] as? Number)?.toInt() ?: error("invalid"),
                    (arguments["unlocks"] as? Number)?.toInt() ?: error("invalid"))
                else -> error("invalid")
            }; codec.bytes
        }
        backup(context, file, before)
        require(read(context, file).contentEquals(before)) { "conflict" }
        context.contentResolver.openOutputStream(file.uri, "rwt")?.use { it.write(next); it.flush() } ?: error("write")
        require(read(context, file).contentEquals(next)) { "verify" }
        snapshot(context)
    }
}

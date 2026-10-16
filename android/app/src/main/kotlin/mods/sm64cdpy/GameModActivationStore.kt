package mods.sm64cdpy

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.util.AtomicFile
import androidx.documentfile.provider.DocumentFile
import java.io.File
import java.io.FileOutputStream

/** Native authority shared by all engines. SAF I/O is performed on a background thread. */
internal object GameModActivationStore {
    const val KEY = "game_user_tree_uri"
    private const val MAX_CONFIG = 256 * 1024
    private const val MAX_ENTRIES = 500
    private const val BACKUP_DOCUMENT = "game_mod_backup_document"
    private const val BACKUP_CURRENT_REVISION = "game_config_backup_current_revision"
    private data class Mod(val name: String, val title: String, val tags: Set<String>, val safe: Boolean, val metadata: LuaModMetadata.Info, val origin: String = "user")

    private fun prefs(context: Context) = context.getSharedPreferences(ModInstallerPlugin.PREF_NAME, Context.MODE_PRIVATE)
    private fun sameDocument(a: Uri, b: Uri): Boolean = a.authority == b.authority &&
        DocumentsContract.getDocumentId(a) == DocumentsContract.getDocumentId(b)

    private fun root(context: Context, uri: Uri): DocumentFile {
        val granted = GameFolderAccess.hasGrant(context, uri, write = true)
        if (!granted) {
            throw SecurityException("access")
        }
        val root = GameFolderStore.root(context) ?: error("access")
        require(root.name == "user" && root.canRead() && root.canWrite()) { "folder" }
        val mods = root.findFile("mods") ?: error("folder")
        require(mods.isDirectory) { "folder" }
        val selected = prefs(context).getString(ModInstallerPlugin.KEY_TREE_URI, null)
        if (selected != null) {
            val existing = GameFolderAccess.resolve(context, Uri.parse(selected)) ?: error("folder")
            require(sameDocument(existing.uri, mods.uri)) { "mismatch" }
        }
        return root
    }

    fun select(context: Context, uri: Uri, flags: Int) = GameFolderStore.connect(context, uri, flags)

    private fun release(context: Context, uri: Uri) {
        // Do not release a grant also owned by an installation folder preference.
        val values = listOf(ModInstallerPlugin.KEY_TREE_URI, ModInstallerPlugin.KEY_DYNOS_TREE_URI, KEY)
        if (values.any { prefs(context).getString(it, null) == uri.toString() }) return
        try { context.contentResolver.releasePersistableUriPermission(uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION) } catch (_: Exception) { }
    }

    fun clear(context: Context) = GameFolderStore.disconnect(context)

    private fun requireNoInstall(context: Context) {
        val query = androidx.work.WorkQuery.Builder.fromStates(listOf(
            androidx.work.WorkInfo.State.ENQUEUED, androidx.work.WorkInfo.State.RUNNING,
            androidx.work.WorkInfo.State.BLOCKED)).build()
        val work = androidx.work.WorkManager.getInstance(context).getWorkInfos(query).get()
        require(work.none { info -> info.tags.any { it == ModInstallWorker::class.java.name ||
            it == ModDownloadWorker::class.java.name } }) { "installing" }
    }

    private fun verifySize(context: Context, target: DocumentFile) {
        var visited = 0
        var size = 0L
        val queue = java.util.ArrayDeque<Pair<DocumentFile, String>>()
        queue.add(target to "")
        val groups = mapOf("actors" to listOf(".bin", ".col"), "data" to listOf(".bhv"),
            "textures" to listOf(".tex"), "levels" to listOf(".lvl"),
            "sound" to listOf(".m64", ".mp3", ".aiff", ".ogg"))
        while (queue.isNotEmpty()) {
            require(++visited <= 4000) { "limit" }
            val (entry, path) = queue.removeFirst()
            if (entry.isDirectory) {
                val children = entry.listFiles()
                require(visited + queue.size + children.size <= 4000) { "limit" }
                for (child in children) {
                    val name = child.name ?: error("invalid")
                    if (!GameModConfig.validName(name)) continue
                    queue.add(child to if (path.isEmpty()) name else "$path/$name")
                }
            } else {
                val ext = groups[path.substringBefore('/')]
                val relevant = path.isEmpty() || path.endsWith(".lua") || path.endsWith(".luac") ||
                    (path.count { it == '/' } == 1 && ext?.any { path.endsWith(it) } == true)
                if (!relevant) continue
                val length = context.contentResolver.query(entry.uri,
                    arrayOf(DocumentsContract.Document.COLUMN_SIZE), null, null, null)?.use { cursor ->
                    if (cursor.moveToFirst() && !cursor.isNull(0)) cursor.getLong(0) else null
                } ?: error("invalid")
                require(length >= 0) { "invalid" }
                size += length
                require(size < 35L * 1048576L) { "size" }
            }
        }
    }

    private fun backupFile(context: Context, uri: Uri): File {
        val digest = java.security.MessageDigest.getInstance("SHA-256").digest(uri.toString().toByteArray(Charsets.UTF_8))
        val name = digest.joinToString("") { "%02x".format(it.toInt() and 255) }
        return File(context.filesDir, "game-mod-config-$name.backup")
    }

    private fun bounded(input: java.io.InputStream, limit: Int): ByteArray {
        val output = java.io.ByteArrayOutputStream()
        val buffer = ByteArray(8192)
        while (output.size() < limit) {
            val count = input.read(buffer, 0, minOf(buffer.size, limit - output.size()))
            if (count < 0) break
            output.write(buffer, 0, count)
        }
        return output.toByteArray()
    }

    fun restore(context: Context): Map<String, Any?> = synchronized(InstallationSafAccessCoordinator.lock) {
        requireNoInstall(context)
        val saved = prefs(context).getString(KEY, null) ?: error("access")
        val file = root(context, Uri.parse(saved)).findFile("sm64config.txt") ?: error("missing")
        require(prefs(context).getString(BACKUP_DOCUMENT, null) == file.uri.toString()) { "missing" }
        val bytes = AtomicFile(backupFile(context, file.uri)).openRead().use { bounded(it, MAX_CONFIG + 1) }
        require(bytes.size <= MAX_CONFIG) { "format" }
        val current = read(context, file)
        prefs(context).getString(BACKUP_CURRENT_REVISION, null)?.let { expected ->
            require(revision(current) == expected) { "conflict" }
        }
        context.contentResolver.openFileDescriptor(file.uri, "rwt")?.use { descriptor ->
            FileOutputStream(descriptor.fileDescriptor).use { output -> output.write(bytes); output.flush(); output.fd.sync() }
        } ?: error("access")
        require(read(context, file).contentEquals(bytes)) { "verify" }
        require(prefs(context).edit().remove(BACKUP_DOCUMENT).remove(BACKUP_CURRENT_REVISION).commit()) { "access" }
        val confirmed = snapshot(context)
        require(confirmed["status"] == "ready") { "verify" }
        confirmed
    }

    private fun read(context: Context, file: DocumentFile): ByteArray {
        val bytes = context.contentResolver.openInputStream(file.uri)?.use { bounded(it, MAX_CONFIG + 1) }
            ?: error("access")
        require(bytes.size <= MAX_CONFIG && !bytes.contains(0.toByte())) { "format" }
        val decoded = try { Charsets.UTF_8.newDecoder().decode(java.nio.ByteBuffer.wrap(bytes)).toString() }
            catch (_: java.nio.charset.CharacterCodingException) { error("format") }
        require(!decoded.startsWith('\uFEFF')) { "format" }
        return bytes
    }

    private fun readMod(context: Context, child: DocumentFile, origin: String): Mod? {
        val name = child.name ?: return null
        if (!GameModConfig.validName(name)) return null
        val script = when {
            child.isFile && name.endsWith(".lua") -> child
            child.isDirectory -> child.findFile("main.lua")?.takeIf { it.isFile }
            else -> null
        } ?: return null
        var title = name
        var safe = true
        var tags = emptySet<String>()
        var metadata = LuaModMetadata.Info()
        try {
            val lines = mutableListOf<String>()
            context.contentResolver.openInputStream(script.uri)?.bufferedReader(Charsets.UTF_8)?.use { reader ->
                var length = 0
                while (true) {
                    reader.mark(2)
                    val first = reader.read()
                    val second = reader.read()
                    reader.reset()
                    if (first != 45 || second != 45) break
                    val lineBuffer = StringBuilder()
                    var ended = false
                    while (true) {
                        val character = reader.read()
                        if (character < 0) { ended = true; break }
                        if (character == 10) break
                        require(lineBuffer.length < 800) { "invalid" }
                        lineBuffer.append(character.toChar())
                    }
                    if (ended && lineBuffer.isEmpty()) break
                    val line = lineBuffer.toString().removeSuffix("\r")
                    length += line.length + 1
                    require(length <= 65536 && line.length <= 800) { "invalid" }
                    if (!line.startsWith("--")) break
                    lines += line
                }
            } ?: error("access")
            metadata = LuaModMetadata.parse(lines.joinToString("\n"), name)
            var foundTags = false
            for (line in lines) {
                if (title == name && line.startsWith("-- name:")) title = line.removePrefix("-- name:").trim().take(64)
                if (!foundTags && line.startsWith("-- incompatible:")) {
                    tags = line.removePrefix("-- incompatible:").trim().take(256).split(' ').filter { it.isNotEmpty() }.toSet()
                    foundTags = true
                }
            }
        } catch (_: Exception) { safe = false }
        return Mod(name, metadata.name ?: LuaModMetadata.clean(title).ifBlank { name }, tags, safe, metadata, origin)
    }

    private fun scan(context: Context, directory: DocumentFile, origin: String = "user"): List<Mod> {
        val children = directory.listFiles()
        require(children.size <= MAX_ENTRIES) { "limit" }
        return children.mapNotNull { readMod(context, it, origin) }.sortedBy { it.name }
    }

    private fun findMod(context: Context, user: DocumentFile, name: String): Mod? {
        fun find(base: DocumentFile?, origin: String): Mod? {
            val folder = base?.findFile("mods")?.takeIf { it.isDirectory && it.canRead() } ?: return null
            val child = folder.findFile(name)?.takeIf { it.name == name } ?: return null
            return readMod(context, child, origin)
        }
        return find(user, "user") ?: find(GameFolderStore.gameRoot(context), "root")
    }

    private fun findPack(context: Context, user: DocumentFile, name: String): Pack? {
        fun find(base: DocumentFile?, origin: String): Pack? {
            val folder = base?.findFile("dynos")?.findFile("packs") ?: return null
            val child = folder.findFile(name)?.takeIf { it.name == name && it.isDirectory } ?: return null
            return Pack(child, origin)
        }
        return find(GameFolderStore.gameRoot(context), "root") ?: find(user, "user")
    }

    private fun scanMods(context: Context, user: DocumentFile): List<Mod> {
        val personal = scan(context, user.findFile("mods") ?: error("folder"))
        val external = GameFolderStore.gameRoot(context)?.findFile("mods")?.let {
            require(it.isDirectory && it.canRead()) { "access" }
            scan(context, it, "root")
        } ?: emptyList()
        return GameFolderLayout.preferred(personal, external) { it.name }
    }

    private data class Pack(val document: DocumentFile, val origin: String) {
        val name get() = document.name!!
    }
    private fun packs(context: Context, user: DocumentFile): List<Pack> {
        fun scanPacks(base: DocumentFile?, origin: String): List<Pack> {
            val directory = base?.findFile("dynos")?.findFile("packs") ?: return emptyList()
            require(directory.isDirectory && directory.canRead()) { "access" }
            val entries = directory.listFiles()
            require(entries.size <= MAX_ENTRIES) { "limit" }
            return entries.filter { it.isDirectory && it.name != null }.map { Pack(it, origin) }.sortedBy { it.name }
        }
        // DynOS scans resources first; Lua scans user first. Their precedence differs.
        return GameFolderLayout.preferred(scanPacks(GameFolderStore.gameRoot(context), "root"),
            scanPacks(user, "user")) { it.name }
    }

    fun snapshot(context: Context): Map<String, Any?> = synchronized(InstallationSafAccessCoordinator.lock) {
        val saved = prefs(context).getString(KEY, null)
            ?: return@synchronized mapOf("status" to "unselected", "mods" to emptyList<Any>())
        try {
            val directory = root(context, Uri.parse(saved))
            val config = directory.findFile("sm64config.txt") ?: error("missing")
            require(config.canWrite()) { "access" }
            val text = read(context, config).toString(Charsets.UTF_8)
            val selected = GameModConfig.enabled(text)
            val enabledPacks = GameDynosConfig.enabled(text)
            val dynos = packs(context, directory)
            val mods = scanMods(context, directory)
            val activeMods = mods.filter { it.name in selected }
            val conflictingNames = mutableSetOf<String>()
            for (candidate in mods) {
                if (activeMods.any { active ->
                        active.name != candidate.name &&
                            active.tags.intersect(candidate.tags).isNotEmpty()
                    }) {
                    conflictingNames += candidate.name
                }
            }
            val allModsSafe = mods.all { it.safe }
            mapOf("status" to "ready", "backupAvailable" to (prefs(context).getString(BACKUP_DOCUMENT, null) == config.uri.toString()), "mods" to mods.map { mod ->
                mapOf("kind" to "lua", "origin" to mod.origin, "name" to mod.name, "title" to mod.title,
                    "author" to mod.metadata.author, "category" to mod.metadata.category,
                    "versionLabel" to mod.metadata.version, "description" to mod.metadata.description, "enabled" to (mod.name in selected),
                    "selectable" to (mod.name in selected || (mod.safe && allModsSafe && mod.name !in conflictingNames)))
            } + dynos.map { pack ->
                val name = pack.name
                mapOf("kind" to "dynos", "origin" to pack.origin, "name" to name, "title" to name,
                    "enabled" to (name in enabledPacks),
                    "selectable" to GameDynosConfig.validName(name))
            })
        } catch (error: Exception) {
            mapOf("backupAvailable" to (prefs(context).getString(BACKUP_DOCUMENT, null)?.let { backupUri ->
                runCatching { root(context, Uri.parse(saved)).findFile("sm64config.txt")?.uri.toString() == backupUri }.getOrDefault(false)
            } ?: false), "status" to (error.message?.takeIf { it in setOf("missing", "folder", "mismatch", "limit", "format") } ?: "access"),
                "mods" to emptyList<Any>())
        }
    }

    fun set(context: Context, name: String, enabled: Boolean, kind: String = "lua"): Map<String, Any?> =
        synchronized(InstallationSafAccessCoordinator.lock) {
            require(kind == "lua" || kind == "dynos") { "invalid" }
            val dynos = kind == "dynos"
            require(if (dynos) GameDynosConfig.validName(name) else GameModConfig.validName(name)) { "invalid" }
            val saved = prefs(context).getString(KEY, null) ?: error("access")
            val directory = root(context, Uri.parse(saved))
            val file = directory.findFile("sm64config.txt") ?: error("missing")
            require(file.isFile && file.canWrite()) { "access" }
            val original = read(context, file)
            val text = original.toString(Charsets.UTF_8)
            requireNoInstall(context)
            val updated = if (dynos) {
                if (enabled) require(findPack(context, directory, name) != null) { "invalid" }
                GameDynosConfig.edit(text, name, enabled)
            } else {
                val active = GameModConfig.enabled(text)
                if (enabled) {
                    val target = findMod(context, directory, name) ?: error("invalid")
                    require(target.safe) { "invalid" }
                    val activeMods = if (target.tags.isEmpty()) {
                        emptyList()
                    } else {
                        require(active.size <= MAX_ENTRIES * 2) { "limit" }
                        active.asSequence()
                            .filter { it != name }
                            .mapNotNull { findMod(context, directory, it) }
                            .toList()
                    }
                    require(activeMods.all { it.safe }) { "invalid" }
                    val base = if (target.origin == "root") GameFolderStore.gameRoot(context) else directory
                    verifySize(context, base?.findFile("mods")?.findFile(name) ?: error("invalid"))
                    require(activeMods.none { it.tags.intersect(target.tags).isNotEmpty() }) { "conflict" }
                }
                GameModConfig.edit(text, name, enabled)
            }.toByteArray(Charsets.UTF_8)
            require(updated.size <= MAX_CONFIG) { "limit" }
            if (original.contentEquals(updated)) {
                return@synchronized mapOf(
                    "status" to "ready",
                    "backupAvailable" to (prefs(context).getString(BACKUP_DOCUMENT, null) == file.uri.toString()),
                    "mods" to emptyList<Any>(),
                )
            }
            val backup = AtomicFile(backupFile(context, file.uri))
            val stream = backup.startWrite()
            try { stream.write(original); backup.finishWrite(stream) }
            catch (error: Exception) { backup.failWrite(stream); throw error }
            require(prefs(context).edit().putString(BACKUP_DOCUMENT, file.uri.toString()).remove(BACKUP_CURRENT_REVISION).commit()) { "access" }
            require(read(context, file).contentEquals(original)) { "conflict" }
            requireNoInstall(context)
            try {
                context.contentResolver.openFileDescriptor(file.uri, "rwt")?.use { descriptor ->
                    FileOutputStream(descriptor.fileDescriptor).use { output ->
                        output.write(updated)
                        output.flush()
                        output.fd.sync()
                    }
                } ?: error("access")
                require(read(context, file).contentEquals(updated)) { "verify" }
                require(prefs(context).edit().putString(BACKUP_CURRENT_REVISION, revision(updated)).commit()) { "access" }
            } catch (error: Exception) {
                // Backup remains intact; never overwrite a possible intervening game write.
                throw IllegalStateException("write", error)
            }
            mapOf(
                "status" to "ready",
                "backupAvailable" to (prefs(context).getString(BACKUP_DOCUMENT, null) == file.uri.toString()),
                "mods" to emptyList<Any>(),
            )
        }

    private fun revision(bytes: ByteArray): String = java.security.MessageDigest.getInstance("SHA-256")
        .digest(bytes).joinToString("") { "%02x".format(it.toInt() and 255) }

    private fun playerMap(profile: PlayerProfileConfig.Profile): Map<String, Any> = mapOf(
        "name" to profile.name,
        "model" to profile.model,
        "colors" to profile.colors,
    )

    private fun paletteFiles(context: Context, directory: DocumentFile): List<Map<String, Any?>> {
        val mario = PlayerProfileConfig.parsePalette(
            """[PALETTE]
PANTS_R=0
PANTS_G=0
PANTS_B=255
SHIRT_R=255
SHIRT_G=0
SHIRT_B=0
GLOVES_R=255
GLOVES_G=255
GLOVES_B=255
SHOES_R=114
SHOES_G=28
SHOES_B=14
HAIR_R=115
HAIR_G=6
HAIR_B=0
SKIN_R=254
SKIN_G=193
SKIN_B=121
CAP_R=255
CAP_G=0
CAP_B=0
EMBLEM_R=255
EMBLEM_G=0
EMBLEM_B=0
"""
        )!!
        val output = mutableListOf<Map<String, Any?>>(
            mapOf("id" to "builtin:Mario", "name" to "Mario", "writable" to false, "colors" to mario)
        )
        fun scan(folder: DocumentFile?, origin: String, writable: Boolean) {
            if (folder == null || !folder.isDirectory || !folder.canRead()) return
            for (file in folder.listFiles().sortedBy { it.name?.lowercase() }.take(128)) {
                val fileName = file.name ?: continue
                if (!file.isFile || !fileName.endsWith(".ini", true) || fileName.length !in 5..68) continue
                val bytes = try {
                    context.contentResolver.openInputStream(file.uri)?.use { bounded(it, 16385) }
                } catch (_: Exception) { null } ?: continue
                if (bytes.size > 16384 || bytes.contains(0.toByte())) continue
                val colors = runCatching { PlayerProfileConfig.parsePalette(bytes.toString(Charsets.UTF_8)) }.getOrNull() ?: continue
                val name = fileName.dropLast(4)
                if (origin == "builtin" && output.any { it["name"] == name }) continue
                output += mapOf("id" to "$origin:${file.uri}", "name" to name, "writable" to writable, "colors" to colors)
                if (output.size >= 128) return
            }
        }
        scan(GameFolderStore.gameRoot(context)?.findFile("palettes"), "builtin", false)
        scan(directory.findFile("palettes"), "user", true)
        return output
    }

    fun playerSnapshot(context: Context): Map<String, Any?> = synchronized(InstallationSafAccessCoordinator.lock) {
        val saved = prefs(context).getString(KEY, null)
            ?: return@synchronized mapOf("status" to "unselected")
        try {
            val directory = root(context, Uri.parse(saved))
            val file = directory.findFile("sm64config.txt") ?: error("missing")
            require(file.isFile && file.canWrite()) { "access" }
            val bytes = read(context, file)
            mapOf(
                "status" to "ready",
                "backupAvailable" to (prefs(context).getString(BACKUP_DOCUMENT, null) == file.uri.toString()),
                "revision" to revision(bytes),
                "profile" to playerMap(PlayerProfileConfig.parse(bytes.toString(Charsets.UTF_8))),
                "palettes" to paletteFiles(context, directory),
            )
        } catch (error: Exception) {
            mapOf("status" to (error.message?.takeIf { it in setOf("missing", "folder", "mismatch", "limit", "format") } ?: "access"))
        }
    }

    fun applyPlayer(context: Context, name: String, model: Int, colors: List<Int>, expectedRevision: String): Map<String, Any?> =
        synchronized(InstallationSafAccessCoordinator.lock) {
            require(PlayerProfileConfig.validName(name) && model in 0..4 && colors.size == PlayerProfileConfig.parts.size) { "invalid" }
            val saved = prefs(context).getString(KEY, null) ?: error("access")
            val directory = root(context, Uri.parse(saved))
            val file = directory.findFile("sm64config.txt") ?: error("missing")
            require(file.isFile && file.canWrite()) { "access" }
            requireNoInstall(context)
            val original = read(context, file)
            require(revision(original) == expectedRevision) { "conflict" }
            val updated = PlayerProfileConfig.edit(original.toString(Charsets.UTF_8), name, model, colors).toByteArray(Charsets.UTF_8)
            require(updated.size <= MAX_CONFIG) { "limit" }
            if (!original.contentEquals(updated)) {
                val backup = AtomicFile(backupFile(context, file.uri))
                val stream = backup.startWrite()
                try { stream.write(original); backup.finishWrite(stream) }
                catch (error: Exception) { backup.failWrite(stream); throw error }
                require(prefs(context).edit().putString(BACKUP_DOCUMENT, file.uri.toString()).remove(BACKUP_CURRENT_REVISION).commit()) { "access" }
                require(read(context, file).contentEquals(original)) { "conflict" }
                requireNoInstall(context)
                try {
                    context.contentResolver.openFileDescriptor(file.uri, "rwt")?.use { descriptor ->
                        FileOutputStream(descriptor.fileDescriptor).use { output ->
                            output.write(updated); output.flush(); output.fd.sync()
                        }
                    } ?: error("access")
                    require(read(context, file).contentEquals(updated)) { "verify" }
                    require(prefs(context).edit().putString(BACKUP_CURRENT_REVISION, revision(updated)).commit()) { "access" }
                } catch (error: Exception) { throw IllegalStateException("write", error) }
            }
            val confirmed = read(context, file)
            val profile = PlayerProfileConfig.parse(confirmed.toString(Charsets.UTF_8))
            require(profile.name == name && profile.colors == colors) { "verify" }
            mapOf(
                "status" to "ready",
                "backupAvailable" to (prefs(context).getString(BACKUP_DOCUMENT, null) == file.uri.toString()),
                "revision" to revision(confirmed),
                "profile" to playerMap(profile),
                "palettes" to paletteFiles(context, directory),
            )
        }

    private fun validPaletteName(name: String): Boolean = name.length in 1..63 && name == name.trim() &&
        name !in setOf(".", "..") && name.none { it in setOf('/', '\\', '\u0000', '\n', '\r', ':') }

    fun savePlayerPalette(context: Context, name: String, colors: List<Int>, overwrite: Boolean): Map<String, Any?> =
        synchronized(InstallationSafAccessCoordinator.lock) {
            require(validPaletteName(name) && colors.size == PlayerProfileConfig.parts.size) { "invalid" }
            val saved = prefs(context).getString(KEY, null) ?: error("access")
            val directory = root(context, Uri.parse(saved))
            val folder = directory.findFile("palettes") ?: directory.createDirectory("palettes") ?: error("access")
            require(folder.isDirectory && folder.canWrite()) { "access" }
            val fileName = "$name.ini"
            val existing = folder.listFiles().firstOrNull { it.name == fileName }
            require(existing == null || overwrite) { "exists" }
            val file = existing ?: folder.createFile("application/octet-stream", fileName) ?: error("access")
            require(file.name == fileName) { "access" }
            val bytes = PlayerProfileConfig.palette(colors).toByteArray(Charsets.UTF_8)
            context.contentResolver.openFileDescriptor(file.uri, "rwt")?.use { descriptor ->
                FileOutputStream(descriptor.fileDescriptor).use { output -> output.write(bytes); output.flush(); output.fd.sync() }
            } ?: error("access")
            val actual = context.contentResolver.openInputStream(file.uri)?.use { bounded(it, 16385) } ?: error("access")
            require(actual.contentEquals(bytes)) { "verify" }
            playerSnapshot(context)
        }

    fun deletePlayerPalette(context: Context, id: String): Map<String, Any?> =
        synchronized(InstallationSafAccessCoordinator.lock) {
            require(id.startsWith("user:")) { "invalid" }
            val saved = prefs(context).getString(KEY, null) ?: error("access")
            val directory = root(context, Uri.parse(saved))
            val folder = directory.findFile("palettes") ?: error("missing")
            val targetUri = id.removePrefix("user:")
            val target = folder.listFiles().firstOrNull { it.uri.toString() == targetUri } ?: error("missing")
            require(target.isFile && target.name?.endsWith(".ini", true) == true && target.delete()) { "access" }
            playerSnapshot(context)
        }
}

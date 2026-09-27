package mods.sm64cdpy

import android.content.Context
import android.net.Uri
import android.util.AtomicFile
import androidx.documentfile.provider.DocumentFile
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest
import java.time.Instant
import java.util.ArrayDeque
import org.json.JSONArray
import org.json.JSONObject

/**
 * Conservative, bounded discovery for content that has no SM64CDPY receipt.
 *
 * Discovery is deliberately separate from [InstallationReceiptStore]. A hit
 * proves only that a Lua-shaped item exists in a selected SAF tree; it never
 * fabricates catalog identity or installation evidence.
 */
object InstallationDiscoveryScanner {
    const val SCHEMA_VERSION = 1
    const val MAX_HEADER_BYTES = 64 * 1024
    const val MAX_VISITED_DOCUMENTS = 4_000
    const val MAX_DISCOVERIES = 500
    const val MAX_FOLDER_DEPTH = 3

    private const val CACHE_FILE = "installation_discoveries_v1.json"

    data class LuaMetadata(
        val name: String? = null,
        val version: String? = null,
        val category: String? = null,
        val author: String? = null,
        val description: String? = null
    )

    private data class Candidate(
        val file: DocumentFile,
        val relativePath: String,
        val sourceType: String,
        val structuralMarker: Boolean
    )

    private data class Budget(var visited: Int = 0, var results: Int = 0)

    fun scan(context: Context, force: Boolean): Map<String, Any?> =
        synchronized(InstallationSafAccessCoordinator.lock) {
        val roots = selectedRoots(context)
        val fingerprints = roots.mapValues { (_, value) ->
            rootFingerprint(context, value.uriString)
        }
        val cached = readCacheObject(context)
        if (!force && cached != null && cacheMatches(cached, fingerprints)) {
            return@synchronized publicCacheMap(cached)
        }

        val detectedAt = Instant.now().toString()
        val discoveries = JSONArray()
        val issues = JSONArray()
        val budget = Budget()

        roots.forEach { (destination, selected) ->
            if (budget.results >= MAX_DISCOVERIES) return@forEach
            val root = resolveRoot(context, selected.uriString)
            if (root == null) return@forEach
            try {
                scanRoot(context, root, destination, detectedAt, budget)
                    .forEach { discoveries.put(it) }
            } catch (error: SecurityException) {
                issues.put(issue(destination, "permission_revoked"))
            } catch (error: Exception) {
                issues.put(issue(destination, error.message ?: "scan_failed"))
            }
        }

        val output = JSONObject()
            .put("schemaVersion", SCHEMA_VERSION)
            .put("scannedAt", detectedAt)
            .put("rootFingerprints", JSONObject().apply {
                fingerprints.forEach { (key, value) -> put(key, value ?: JSONObject.NULL) }
            })
            .put("discoveries", discoveries)
            .put("issues", issues)
            .put("truncated", budget.visited >= MAX_VISITED_DOCUMENTS ||
                    budget.results >= MAX_DISCOVERIES)
        writeCacheObject(context, output)
        publicCacheMap(output)
    }

    fun readCached(context: Context): Map<String, Any?> =
        synchronized(InstallationSafAccessCoordinator.lock) {
        val cached = readCacheObject(context) ?: return@synchronized emptyResult()
        publicCacheMap(cached)
    }

    fun attachToSnapshot(
        receiptSnapshot: Map<String, Any>,
        discoverySnapshot: Map<String, Any?>
    ): Map<String, Any?> {
        @Suppress("UNCHECKED_CAST")
        val receipts = receiptSnapshot["receipts"] as? List<Map<String, Any?>> ?: emptyList()
        val ownedPaths = receipts.groupBy { it["destination"] as? String }
            .mapValues { (_, values) ->
                values.flatMap { receipt ->
                    @Suppress("UNCHECKED_CAST")
                    (receipt["sentinels"] as? List<Map<String, Any?>>).orEmpty()
                        .mapNotNull { it["relativePath"] as? String }
                }.toSet()
            }
        @Suppress("UNCHECKED_CAST")
        val discoveries = (discoverySnapshot["discoveries"] as? List<Map<String, Any?>>)
            .orEmpty()
            .filter { discovery ->
                val destination = discovery["destination"] as? String
                val entryPath = discovery["entryPath"] as? String
                entryPath == null || entryPath !in ownedPaths[destination].orEmpty()
            }
        @Suppress("UNCHECKED_CAST")
        val receiptIssues = receiptSnapshot["issues"] as? List<Map<String, String>> ?: emptyList()
        @Suppress("UNCHECKED_CAST")
        val discoveryIssues = discoverySnapshot["issues"] as? List<Map<String, String>>
            ?: emptyList()
        return buildMap {
            putAll(receiptSnapshot)
            put("discoveries", discoveries)
            put("discoveryScannedAt", discoverySnapshot["scannedAt"])
            put("discoveryTruncated", discoverySnapshot["truncated"] == true)
            put("issues", receiptIssues + discoveryIssues)
        }
    }

    internal fun parseLuaHeader(text: String, fallbackName: String): LuaMetadata {
        var name: String? = null
        var category: String? = null
        var author: String? = null
        var description: String? = null
        val normalized = text.removePrefix("\uFEFF")
        for (raw in normalized.lineSequence()) {
            val line = raw.trimEnd('\r')
            if (!line.startsWith("--")) break
            val separator = line.indexOf(':')
            if (separator < 2) continue
            val key = line.substring(2, separator).trim().lowercase()
            val value = cleanLuaText(line.substring(separator + 1)).takeIf(String::isNotBlank)
            when (key) {
                "name" -> if (name == null) name = value?.take(64)
                "category" -> if (category == null) category = value?.take(64)
                "author" -> if (author == null) author = value?.take(128)
                "description" -> if (description == null) description = value?.take(800)
            }
        }
        val version = extractVersion(name, description, fallbackName)
        return LuaMetadata(name, version, category, author, description)
    }

    internal fun cleanLuaText(value: String): String = value
        .replace("\\n", " ")
        .replace(Regex("\\\\+#[0-9A-Fa-f]{6}\\\\+"), "")
        .replace(Regex("\\\\+"), "")
        .replace(Regex("[ \\t]{2,}"), " ")
        .trim()

    private fun scanRoot(
        context: Context,
        root: DocumentFile,
        destination: String,
        detectedAt: String,
        budget: Budget
    ): List<JSONObject> {
        val output = mutableListOf<JSONObject>()
        val entries = safeList(root, budget).sortedBy { it.name?.lowercase().orEmpty() }

        val rootFiles = entries.filter(DocumentFile::isFile)
        val rootMarker = rootFiles.firstOrNull { it.name.equals("main.lua", true) }
            ?: rootFiles.firstOrNull { it.name.equals("mod.lua", true) }
        if (rootMarker != null && budget.results < MAX_DISCOVERIES) {
            output += describeCandidate(
                context,
                Candidate(rootMarker, rootMarker.name.orEmpty(), "root_files", true),
                destination,
                detectedAt
            )
            budget.results++
        }

        rootFiles.asSequence()
            .filter { isLua(it) && it != rootMarker }
            .take(MAX_DISCOVERIES - budget.results)
            .forEach { file ->
                output += describeCandidate(
                    context,
                    Candidate(file, file.name.orEmpty(), "loose_lua", false),
                    destination,
                    detectedAt
                )
                budget.results++
            }

        entries.asSequence()
            .filter(DocumentFile::isDirectory)
            .takeWhile { budget.visited < MAX_VISITED_DOCUMENTS &&
                    budget.results < MAX_DISCOVERIES }
            .forEach { folder ->
                findFolderCandidate(folder, folder.name.orEmpty(), budget)?.let { candidate ->
                    output += describeCandidate(context, candidate, destination, detectedAt)
                    budget.results++
                }
            }
        return output
    }

    private fun findFolderCandidate(
        folder: DocumentFile,
        folderPath: String,
        budget: Budget
    ): Candidate? {
        data class Pending(val directory: DocumentFile, val path: String, val depth: Int)
        val queue = ArrayDeque<Pending>()
        queue.add(Pending(folder, folderPath, 0))
        val mainCandidates = mutableListOf<Candidate>()
        val modCandidates = mutableListOf<Candidate>()
        val luaCandidates = mutableListOf<Candidate>()
        while (queue.isNotEmpty() && budget.visited < MAX_VISITED_DOCUMENTS) {
            val current = queue.removeFirst()
            val entries = safeList(current.directory, budget)
                .sortedBy { it.name?.lowercase().orEmpty() }
            entries.forEach { entry ->
                val name = entry.name ?: return@forEach
                val path = "${current.path}/$name"
                if (entry.isFile && isLua(entry)) {
                    val candidate = Candidate(
                        entry,
                        path,
                        "folder",
                        name.equals("main.lua", true) || name.equals("mod.lua", true)
                    )
                    when {
                        name.equals("main.lua", true) -> mainCandidates += candidate
                        name.equals("mod.lua", true) -> modCandidates += candidate
                        else -> luaCandidates += candidate
                    }
                } else if (entry.isDirectory && current.depth < MAX_FOLDER_DEPTH) {
                    queue.add(Pending(entry, path, current.depth + 1))
                }
            }
        }
        return mainCandidates.firstOrNull()
            ?: modCandidates.firstOrNull()
            ?: luaCandidates.firstOrNull()
    }

    private fun describeCandidate(
        context: Context,
        candidate: Candidate,
        destination: String,
        detectedAt: String
    ): JSONObject {
        val fallbackName = candidate.relativePath.substringBefore('/').substringBeforeLast('.')
        val metadata = if (candidate.file.name?.endsWith(".luac", true) == true) {
            LuaMetadata(version = extractVersion(fallbackName))
        } else {
            parseLuaHeader(readHeader(context, candidate.file), fallbackName)
        }
        val displayName = metadata.name ?: fallbackName.ifBlank { candidate.file.name ?: "Lua mod" }
        val confidence = when {
            candidate.structuralMarker && metadata.name != null -> "exact"
            candidate.structuralMarker -> "probable"
            else -> "unlinked"
        }
        return JSONObject()
            .put("schemaVersion", SCHEMA_VERSION)
            .put("discoveryKey", sha256("$destination|${candidate.relativePath}"))
            .put("destination", destination)
            .put("entryPath", candidate.relativePath)
            .put("displayName", displayName)
            .put("versionLabel", metadata.version ?: JSONObject.NULL)
            .put("category", metadata.category ?: JSONObject.NULL)
            .put("author", metadata.author ?: JSONObject.NULL)
            .put("sourceType", candidate.sourceType)
            .put("confidence", confidence)
            .put("detectedAt", detectedAt)
    }

    private fun safeList(directory: DocumentFile, budget: Budget): List<DocumentFile> {
        if (budget.visited >= MAX_VISITED_DOCUMENTS) return emptyList()
        val remaining = MAX_VISITED_DOCUMENTS - budget.visited
        val entries = directory.listFiles().take(remaining)
        budget.visited += entries.size
        return entries
    }

    private fun readHeader(context: Context, file: DocumentFile): String {
        val input = context.contentResolver.openInputStream(file.uri) ?: return ""
        input.use { stream ->
            val output = ByteArrayOutputStream()
            val buffer = ByteArray(4_096)
            while (output.size() < MAX_HEADER_BYTES) {
                val length = stream.read(buffer, 0, minOf(buffer.size, MAX_HEADER_BYTES - output.size()))
                if (length <= 0) break
                output.write(buffer, 0, length)
            }
            return output.toByteArray().toString(Charsets.UTF_8)
        }
    }

    private fun selectedRoots(context: Context): Map<String, SelectedRoot> {
        val prefs = context.getSharedPreferences(ModInstallerPlugin.PREF_NAME, Context.MODE_PRIVATE)
        return mapOf(
            "mods" to SelectedRoot(prefs.getString(ModInstallerPlugin.KEY_TREE_URI, null)),
            "dynos" to SelectedRoot(prefs.getString(ModInstallerPlugin.KEY_DYNOS_TREE_URI, null))
        )
    }

    private data class SelectedRoot(val uriString: String?)

    private fun resolveRoot(context: Context, uriString: String?): DocumentFile? {
        if (uriString == null) return null
        val uri = Uri.parse(uriString)
        val granted = context.contentResolver.persistedUriPermissions.any {
            it.uri == uri && it.isReadPermission
        }
        if (!granted) return null
        return DocumentFile.fromTreeUri(context, uri)?.takeIf { it.exists() && it.canRead() }
    }

    private fun rootFingerprint(context: Context, uriString: String?): String? {
        if (uriString == null) return null
        val uri = try {
            Uri.parse(uriString)
        } catch (_: Exception) {
            return sha256("invalid|$uriString")
        }
        val readable = context.contentResolver.persistedUriPermissions.any {
            it.uri == uri && it.isReadPermission
        }
        return sha256("$uriString|read=$readable")
    }

    private fun isLua(file: DocumentFile): Boolean {
        val name = file.name ?: return false
        return name.endsWith(".lua", true) || name.endsWith(".luac", true)
    }

    private fun extractVersion(vararg texts: String?): String? {
        val combined = texts.filterNotNull().joinToString(" ")
        val patterns = listOf(
            Regex("(?i)\\bversion\\s*[:-]?\\s*v?(\\d+(?:[.-]\\d+){0,3})\\b"),
            Regex("(?i)\\bv(?:er)?[.\\s]?(\\d+(?:[.-]\\d+){1,3})\\b"),
            Regex("\\b(\\d+\\.\\d+(?:\\.\\d+)?)\\b")
        )
        return patterns.firstNotNullOfOrNull { pattern ->
            pattern.find(combined)?.groupValues?.get(1)?.replace('-', '.')
        }
    }

    private fun cacheMatches(cache: JSONObject, fingerprints: Map<String, String?>): Boolean {
        if (cache.optInt("schemaVersion") != SCHEMA_VERSION) return false
        val stored = cache.optJSONObject("rootFingerprints") ?: return false
        return fingerprints.all { (key, value) ->
            if (value == null) stored.isNull(key) else stored.optString(key) == value
        }
    }

    private fun readCacheObject(context: Context): JSONObject? {
        val file = File(context.filesDir, CACHE_FILE)
        if (!file.isFile) return null
        return try {
            JSONObject(file.readText(Charsets.UTF_8)).takeIf {
                it.optInt("schemaVersion") == SCHEMA_VERSION
            }
        } catch (_: Exception) {
            file.delete()
            null
        }
    }

    private fun writeCacheObject(context: Context, value: JSONObject) {
        val atomic = AtomicFile(File(context.filesDir, CACHE_FILE))
        var stream: FileOutputStream? = null
        try {
            stream = atomic.startWrite()
            stream.write(value.toString().toByteArray(Charsets.UTF_8))
            stream.flush()
            stream.fd.sync()
            atomic.finishWrite(stream)
        } catch (error: Exception) {
            stream?.let(atomic::failWrite)
            throw error
        }
    }

    private fun publicCacheMap(value: JSONObject): Map<String, Any?> = mapOf(
        "schemaVersion" to SCHEMA_VERSION,
        "scannedAt" to value.optString("scannedAt").takeIf(String::isNotEmpty),
        "discoveries" to jsonArrayToMaps(value.optJSONArray("discoveries") ?: JSONArray()),
        "issues" to jsonArrayToMaps(value.optJSONArray("issues") ?: JSONArray()),
        "truncated" to value.optBoolean("truncated", false)
    )

    private fun emptyResult(): Map<String, Any?> = mapOf(
        "schemaVersion" to SCHEMA_VERSION,
        "scannedAt" to null,
        "discoveries" to emptyList<Map<String, Any?>>(),
        "issues" to emptyList<Map<String, Any?>>(),
        "truncated" to false
    )

    private fun jsonArrayToMaps(array: JSONArray): List<Map<String, Any?>> =
        List(array.length()) { index -> jsonObjectToMap(array.getJSONObject(index)) }

    private fun jsonObjectToMap(value: JSONObject): Map<String, Any?> = buildMap {
        val keys = value.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val item = value.get(key)
            put(key, if (item == JSONObject.NULL) null else item)
        }
    }

    private fun issue(destination: String, reason: String): JSONObject = JSONObject()
        .put("file", "discovery:$destination")
        .put("reason", reason)

    private fun sha256(value: String): String = MessageDigest
        .getInstance("SHA-256")
        .digest(value.toByteArray(Charsets.UTF_8))
        .joinToString("") { "%02x".format(it) }
}

/** Serializes read-heavy SAF library operations across both Flutter engines. */
internal object InstallationSafAccessCoordinator {
    val lock = Any()
}

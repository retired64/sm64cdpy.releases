package mods.sm64cdpy

import android.content.ContentResolver
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.SystemClock
import android.provider.DocumentsContract
import android.util.Log
import androidx.documentfile.provider.DocumentFile
import java.io.ByteArrayInputStream
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicLong
import java.util.zip.CheckedInputStream
import java.util.zip.CRC32
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipInputStream
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry
import org.apache.commons.compress.archivers.sevenz.SevenZFile

/**
 * Lógica compartida de extracción de ZIPs y copia de archivos sueltos
 * hacia un árbol SAF (DocumentFile).
 *
 * Única fuente de verdad para dos invariantes que antes estaban parcheados
 * solo en una de las dos implementaciones duplicadas (ModInstallWorker vs
 * ModInstallerPlugin.extractZipToDocumentFile):
 *
 *  1. "Delete-before-create": SAF NO sobreescribe. Si ya existe un archivo
 *     con el mismo nombre (típico al reinstalar/actualizar un mod), la
 *     mayoría de providers crean "archivo (1).ext" en vez de reemplazarlo,
 *     dejando copias viejas huérfanas mezcladas con las nuevas. Se borra
 *     primero.
 *  2. Fallo explícito a mitad de operación: createFile()/openOutputStream()
 *     devuelven null (no lanzan) si el permiso SAF fue revocado durante la
 *     extracción. Antes se saltaba la entrada en silencio y se reportaba
 *     éxito parcial; ahora se lanza SecurityException para que el caller
 *     (ModInstallWorker.doWork / ModInstallerPlugin) reporte el error real.
 *
 * Usada por ModInstallWorker (ruta WorkManager) y ModInstallerPlugin
 * (ruta sincrónica installMod / installModToDynosFolder).
 */
object SafZipExtractor {
    const val MAX_SENTINELS = 32

    /** Workers escribiendo a SAF en paralelo (cada llamada es un IPC al provider). */
    private val PARALLELISM = Runtime.getRuntime().availableProcessors().coerceIn(4, 8)
    private const val COPY_BUFFER = 256 * 1024
    /** En .7z, entradas <= este tamaño se leen a memoria y se escriben en paralelo. */
    private const val SMALL_ENTRY_LIMIT = 1L * 1024 * 1024
    private const val PROGRESS_INTERVAL_MS = 250L
    private val copyBuffers: ThreadLocal<ByteArray> =
        ThreadLocal.withInitial { ByteArray(COPY_BUFFER) }

    enum class PackageShape(val wireValue: String) {
        LOOSE_FILE("loose_file"),
        SINGLE_ROOT("single_root"),
        MULTIPLE_ROOTS("multiple_roots"),
        ROOT_FILES("root_files")
    }

    data class WrittenEntry(
        val relativePath: String,
        val kind: String = "file"
    )

    data class WriteManifest(
        val fileCount: Int,
        val packageShape: PackageShape,
        val sentinels: List<WrittenEntry>
    )

    /** Tracks newly-created SAF entries so an interrupted install can remove
     * its partial files without deleting files that existed beforehand. */
    class WriteJournal {
        private val newFiles = linkedSetOf<String>()
        private val newDirectories = linkedSetOf<String>()
        private var rolledBack = false
        private var directRoot: File? = null

        @Synchronized
        internal fun useDirectRoot(root: File) { directRoot = root.canonicalFile }

        @Synchronized
        internal fun recordFile(path: String, existedBefore: Boolean) {
            if (rolledBack) return
            if (!existedBefore) newFiles += sanitizeEntryName(path)
        }

        @Synchronized
        internal fun recordDirectory(path: String, existedBefore: Boolean) {
            if (rolledBack) return
            if (!existedBefore) newDirectories += sanitizeEntryName(path)
        }

        /**
         * Rollback is deliberately non-throwing. A DocumentsProvider may
         * disappear, revoke access or reject list/delete while WorkManager is
         * already cancelling; cleanup failure must never crash the process.
         */
        @Synchronized
        fun rollback(root: DocumentFile) {
            if (rolledBack) return
            rolledBack = true
            val files = newFiles.toList().asReversed()
            val directories = newDirectories
                .sortedByDescending { it.count { char -> char == '/' } }
            files.forEach { safeDeletePath(root, it, false) }
            directories.forEach { safeDeletePath(root, it, true) }
            newFiles.clear()
            newDirectories.clear()
        }

        private fun safeDeletePath(root: DocumentFile, path: String, directory: Boolean) {
            try {
                directRoot?.let { direct ->
                    val target = DirectInstallPaths.child(direct, path)
                    if (!directory || (target.isDirectory && target.list()?.isEmpty() == true)) {
                        if (target.exists() && !target.delete()) throw IOException("Cannot remove partial file")
                    }
                    return
                }
                val segments = path.split('/').filter(String::isNotEmpty)
                if (segments.isEmpty()) return
                var parent = root
                for (segment in segments.dropLast(1)) {
                    parent = parent.findFile(segment)?.takeIf { it.isDirectory } ?: return
                }
                val target = parent.findFile(segments.last()) ?: return
                if (!directory || (target.isDirectory && target.listFiles().isEmpty())) {
                    target.delete()
                }
            } catch (error: Exception) {
                Log.w("ModInstall", "Could not roll back SAF entry: $path", error)
            }
        }
    }

    /**
     * Keeps only the information needed to verify an installation later.
     * Memory use is bounded even for archives containing thousands of files.
     */
    private class ManifestBuilder(
        private val looseFile: Boolean = false
    ) {
        private var fileCount = 0
        private var hasRootFiles = false
        private var rootCountForShape = 0
        private var firstRoot: String? = null
        private val luaEntrypoints = sortedSetOf<String>()
        private val firstPathByRoot = sortedMapOf<String, String>()
        private val lexicographicPaths = sortedSetOf<String>()

        val currentFileCount: Int
            get() = fileCount

        fun record(relativePath: String) {
            val path = sanitizeEntryName(relativePath)
            if (path.isEmpty()) return

            fileCount++
            val slash = path.indexOf('/')
            if (slash < 0) {
                hasRootFiles = true
            } else {
                val root = path.substring(0, slash)
                if (firstRoot == null) {
                    firstRoot = root
                    rootCountForShape = 1
                } else if (firstRoot != root) {
                    rootCountForShape = 2
                }
                val previous = firstPathByRoot[root]
                if (previous == null || path < previous) firstPathByRoot[root] = path
                while (firstPathByRoot.size > MAX_SENTINELS) {
                    firstPathByRoot.remove(firstPathByRoot.lastKey())
                }
            }

            val basename = path.substringAfterLast('/')
            if (basename == "main.lua" || basename == "mod.lua") {
                keepSmallest(luaEntrypoints, path)
            }
            keepSmallest(lexicographicPaths, path)
        }

        fun build(): WriteManifest {
            val selected = linkedSetOf<String>()
            fun add(paths: Iterable<String>) {
                for (path in paths) {
                    if (selected.size >= MAX_SENTINELS) break
                    selected += path
                }
            }

            add(luaEntrypoints)
            if (looseFile) add(lexicographicPaths)
            add(firstPathByRoot.values)
            add(lexicographicPaths)

            val shape = when {
                looseFile -> PackageShape.LOOSE_FILE
                hasRootFiles -> PackageShape.ROOT_FILES
                rootCountForShape == 1 -> PackageShape.SINGLE_ROOT
                else -> PackageShape.MULTIPLE_ROOTS
            }
            return WriteManifest(
                fileCount = fileCount,
                packageShape = shape,
                sentinels = selected.map(::WrittenEntry)
            )
        }

        private fun keepSmallest(paths: java.util.SortedSet<String>, path: String) {
            paths += path
            if (paths.size > MAX_SENTINELS) paths.remove(paths.last())
        }
    }

    internal fun buildManifestForPaths(
        paths: Iterable<String>,
        looseFile: Boolean = false
    ): WriteManifest = ManifestBuilder(looseFile).apply {
        paths.forEach(::record)
    }.build()

    /**
     * Extrae el contenido de [zipFile] dentro de [targetDir] (raíz del árbol SAF).
     * Retorna el conteo, forma del paquete y una huella acotada de rutas
     * escritas que podrá verificarse más adelante contra el árbol SAF.
     *
     * [onProgress] (opcional, suspend) se invoca tras cada archivo escrito con
     * el conteo acumulado — el caller decide el throttling de progreso y
     * notificaciones. Es un callback suspend porque ModInstallWorker necesita
     * llamar setProgress/setForeground desde él. ModInstallerPlugin lo invoca
     * sin callback (o con uno no-suspend vía runBlocking).
     */

    @Throws(IOException::class, SecurityException::class)
    suspend fun extractZipToTree(
        zipFile: File,
        targetDir: DocumentFile,
        context: Context,
        journal: WriteJournal? = null,
        onProgress: (suspend (fileCount: Int) -> Unit)? = null
    ): WriteManifest {
        // ZipFile lee el directorio central (acceso aleatorio): permite
        // descomprimir varias entradas a la vez. Si el ZIP es raro y no abre,
        // se cae al extractor secuencial de siempre.
        return withContext(Dispatchers.IO) {
            val zf = try { ZipFile(zipFile) } catch (_: IOException) {
                return@withContext extractZipToTreeStreaming(zipFile, targetDir, context, journal, onProgress)
            }
            zf.use { extractZipFast(it, targetDir, context, journal, onProgress) }.also {
                requireTreeGrant(context, targetDir)
            }
        }
    }

    private suspend fun extractZipFast(
        zf: ZipFile,
        targetDir: DocumentFile,
        context: Context,
        journal: WriteJournal?,
        onProgress: (suspend (fileCount: Int) -> Unit)?
    ): WriteManifest {
        val plan = LinkedHashMap<String, ZipEntry>()
        val entries = zf.entries()
        while (entries.hasMoreElements()) {
            currentCoroutineContext().ensureActive()
            val ze = entries.nextElement()
            if (ze.isDirectory) continue
            val path = sanitizeEntryName(ze.name)
            if (path.isNotEmpty()) plan[path] = ze   // dedupe: la última gana
        }

        val writer = openSink(context, targetDir, journal)
        writer.prepareDirs(plan.keys.map { it.substringBeforeLast('/', "") }.toSet())

        // Los archivos grandes primero: mejor balance entre workers.
        val ordered = plan.entries.sortedByDescending { it.value.size }
        val manifest = ManifestBuilder()
        val progress = ProgressGate(onProgress)

        forEachParallel(ordered, PARALLELISM) { item ->
            val path = item.key
            val ze = item.value
            val job = currentCoroutineContext()[Job]
            val buf = copyBuffers.get()!!
            writer.writeFile(
                path.substringBeforeLast('/', ""),
                path.substringAfterLast('/'),
                path
            ) { out ->
                zf.getInputStream(ze).use { input ->
                    val checksum = CRC32()
                    val size = pump(CheckedInputStream(input, checksum), out, buf, job)
                    if ((ze.size >= 0 && size != ze.size) || (ze.crc >= 0 && checksum.value != ze.crc)) {
                        throw IOException("Corrupt ZIP entry: $path")
                    }
                }
            }
            val count = synchronized(manifest) {
                manifest.record(path)
                manifest.currentFileCount
            }
            progress.emit(count)
        }
        return manifest.build()
    }

    private fun pump(input: InputStream, out: OutputStream, buf: ByteArray, job: Job?): Long {
        var total = 0L
        while (true) {
            job?.ensureActive()
            val n = input.read(buf)
            if (n < 0) break
            out.write(buf, 0, n)
            total += n
            job?.ensureActive()
        }
        return total
    }

    /** Reparte [items] entre [parallelism] workers; el primer fallo cancela al resto. */
    internal suspend fun <T> forEachParallel(
        items: List<T>,
        parallelism: Int,
        block: suspend (T) -> Unit
    ) {
        if (items.isEmpty()) return
        coroutineScope {
            val next = AtomicInteger(0)
            List(minOf(parallelism, items.size)) {
                async(Dispatchers.IO) {
                    while (true) {
                        ensureActive()
                        val i = next.getAndIncrement()
                        if (i >= items.size) break
                        block(items[i])
                    }
                }
            }.awaitAll()
        }
    }

    /** Emite progreso como máximo cada [PROGRESS_INTERVAL_MS], de forma serializada. */
    private class ProgressGate(private val sink: (suspend (Int) -> Unit)?) {
        private val last = AtomicLong(0L)
        private val mutex = Mutex()
        private var emitted = -1

        suspend fun emit(value: Int) {
            val target = sink ?: return
            val now = SystemClock.elapsedRealtime()
            val prev = last.get()
            if (now - prev < PROGRESS_INTERVAL_MS || !last.compareAndSet(prev, now)) return
            mutex.withLock {
                if (value > emitted) { target(value); emitted = value }
            }
        }
    }


    // ─────────────────────────────────────────────────────────────────────
    // Ruta directa por java.io.File (la más rápida)
    // ─────────────────────────────────────────────────────────────────────

    private interface TreeSink {
        suspend fun prepareDirs(dirPaths: Collection<String>)
        fun writeFile(dirPath: String, name: String, entryPath: String, copy: (OutputStream) -> Unit)
    }

    /** ¿Puede la app escribir por ruta en almacenamiento compartido? */
    fun hasAllFilesAccess(context: Context): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            Build.VERSION.SDK_INT <= 28 && context.checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                android.content.pm.PackageManager.PERMISSION_GRANTED
        }

    /**
     * Si [targetDir] vive en el almacenamiento principal fuera de Android/
     * (p. ej. /sdcard/com.maniscat2.sm64coopdx/mods) y la app tiene acceso a
     * todos los archivos, devuelve su File real. Si no, null => se usa SAF.
     * Android/data y Android/obb nunca se tocan por ruta (el sistema lo bloquea).
     */
    internal fun resolveDirectDir(context: Context, targetDir: DocumentFile): File? = try {
        val uri = targetDir.uri
        if (uri.authority != "com.android.externalstorage.documents" || !hasAllFilesAccess(context)) {
            null
        } else {
            val docId = if (DocumentsContract.isDocumentUri(context, uri))
                DocumentsContract.getDocumentId(uri) else DocumentsContract.getTreeDocumentId(uri)
            @Suppress("DEPRECATION")
            val dir = DirectInstallPaths.root(Environment.getExternalStorageDirectory(), docId)
            dir?.takeIf { it.isDirectory && it.canWrite() && GameFolderAccess.hasGrant(context, uri, write = true) }

        }
    } catch (_: Exception) {
        null
    }

    private fun requireTreeGrant(context: Context, root: DocumentFile) {
        if (!GameFolderAccess.hasGrant(context, root.uri, write = true)) {
            throw SecurityException("Lost selected folder permission")
        }
    }

    private fun openSink(context: Context, targetDir: DocumentFile, journal: WriteJournal?): TreeSink {
        requireTreeGrant(context, targetDir)
        val direct = resolveDirectDir(context, targetDir)
        if (direct != null) {
            Log.i("ModInstall", "Direct file extraction: ${direct.path}")
            journal?.useDirectRoot(direct)
            return DirectTreeWriter(direct, journal)
        }
        return SafTreeWriter(context, targetDir, journal)
    }

    private class DirectTreeWriter(
        private val root: File,
        private val journal: WriteJournal?
    ) : TreeSink {
        override suspend fun prepareDirs(dirPaths: Collection<String>) {
            val all = HashSet<String>()
            for (p in dirPaths) {
                var cur = p
                while (cur.isNotEmpty() && all.add(cur)) cur = cur.substringBeforeLast('/', "")
            }
            // Padres antes que hijos.
            for (path in all.sortedBy { it.count { c -> c == '/' } }) {
                currentCoroutineContext().ensureActive()
                val dir = DirectInstallPaths.child(root, path)
                val existedBefore = dir.isDirectory
                if (!existedBefore) {
                    if (dir.exists()) throw IOException("File occupies directory: $path")
                    if (!dir.mkdir() && !dir.isDirectory) {
                        throw IOException("Cannot create directory: $path")
                    }
                }
                journal?.recordDirectory(path, existedBefore)
            }
        }

        override fun writeFile(
            dirPath: String, name: String, entryPath: String, copy: (OutputStream) -> Unit
        ) {
            val target = DirectInstallPaths.child(root, entryPath)
            if (target.isDirectory) throw IOException("Directory occupies file: $entryPath")
            val existedBefore = target.exists()
            journal?.recordFile(entryPath, existedBefore)
            FileOutputStream(target).use {   // sobreescribe/trunca
                copy(it)
            }
        }
    }

    /**
     * Escritor SAF de bajo costo. Usa DocumentsContract directamente:
     *  - lista cada carpeta existente UNA sola vez (en vez de findFile() por archivo),
     *  - nunca lista carpetas que creó en esta instalación (están vacías),
     *  - crea carpetas en paralelo por niveles,
     *  - 2 llamadas IPC por archivo (createDocument + openOutputStream).
     * Mantiene "delete-before-create", fallo explícito si se pierde el permiso
     * y el journal de rollback.
     */
    private class SafTreeWriter(
        context: Context,
        targetDir: DocumentFile,
        private val journal: WriteJournal?
    ) : TreeSink {
        private val resolver: ContentResolver = context.contentResolver
        private val treeUri: Uri = GameFolderAccess.grantUri(targetDir.uri)

        class Kid(val docId: String, val isDir: Boolean)

        inner class Node(val docId: String, private val fresh: Boolean) {
            val kids: ConcurrentHashMap<String, Kid> by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
                if (fresh) ConcurrentHashMap() else listChildren(docId)
            }
        }

        private val nodes = ConcurrentHashMap<String, Node>()

        init {
            nodes[""] = Node(DocumentsContract.getDocumentId(targetDir.uri), fresh = false)
        }

        private fun docUri(docId: String): Uri =
            DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)

        private fun listChildren(parentId: String): ConcurrentHashMap<String, Kid> {
            val map = ConcurrentHashMap<String, Kid>()
            val uri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentId)
            val cursor = resolver.query(
                uri,
                arrayOf(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_MIME_TYPE
                ),
                null, null, null
            ) ?: throw SecurityException("Lost SAF access during extraction: cannot list directory")
            cursor.use { c ->
                while (c.moveToNext()) {
                    val name = c.getString(1) ?: continue
                    val id = c.getString(0) ?: continue
                    map[name] = Kid(
                        id,
                        c.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR
                    )
                }
            }
            return map
        }

        /** Crea (o reutiliza) todas las carpetas necesarias, nivel por nivel. */
        override suspend fun prepareDirs(dirPaths: Collection<String>) {
            val all = HashSet<String>()
            for (p in dirPaths) {
                var cur = p
                while (cur.isNotEmpty() && all.add(cur)) cur = cur.substringBeforeLast('/', "")
            }
            val levels = all.groupBy { path -> path.count { it == '/' } }.toSortedMap()
            for ((_, paths) in levels) {
                forEachParallel(paths, PARALLELISM) { ensureDir(it) }
            }
        }

        private fun ensureDir(path: String) {
            if (nodes.containsKey(path)) return
            val parent = nodes[path.substringBeforeLast('/', "")]
                ?: throw IOException("Parent directory not prepared for $path")
            val name = path.substringAfterLast('/')

            var existing = parent.kids[name]
            if (existing != null && !existing.isDir) {
                throw IOException("File occupies directory: $path")
            }
            val existedBefore = existing != null
            val node = if (existing != null) {
                Node(existing.docId, fresh = false)
            } else {
                val uri = DocumentsContract.createDocument(
                    resolver, docUri(parent.docId),
                    DocumentsContract.Document.MIME_TYPE_DIR, name
                ) ?: throw SecurityException(
                    "Lost SAF access during extraction: cannot create directory $path"
                )
                val id = DocumentsContract.getDocumentId(uri)
                parent.kids[name] = Kid(id, true)
                Node(id, fresh = true)
            }
            journal?.recordDirectory(path, existedBefore)
            nodes[path] = node
        }

        /** Escribe un archivo; [copy] vuelca el contenido en el OutputStream. */
        override fun writeFile(dirPath: String, name: String, entryPath: String, copy: (OutputStream) -> Unit) {
            val dir = nodes[dirPath] ?: throw IOException("Directory not prepared: $dirPath")
            val existing = dir.kids[name]
            if (existing != null) {
                if (existing.isDir) throw IOException("Directory occupies file: $entryPath")
                if (!DocumentsContract.deleteDocument(resolver, docUri(existing.docId))) {
                    throw IOException("Cannot replace existing file: $entryPath")
                }
                dir.kids.remove(name)
            }
            val uri = DocumentsContract.createDocument(
                resolver, docUri(dir.docId), "application/octet-stream", name
            ) ?: throw SecurityException(
                "Lost SAF access during extraction: cannot create $name"
            )
            dir.kids[name] = Kid(DocumentsContract.getDocumentId(uri), false)
            journal?.recordFile(entryPath, existing != null)
            val os = resolver.openOutputStream(uri) ?: throw SecurityException(
                "Lost SAF access during extraction: cannot open $name"
            )
            os.use {
                copy(it)
                it.flush()
            }
        }
    }

    /** Extractor secuencial original; solo se usa si ZipFile no puede abrir el archivo. */
    @Throws(IOException::class, SecurityException::class)
    private suspend fun extractZipToTreeStreaming(
        zipFile: File,
        targetDir: DocumentFile,
        context: Context,
        journal: WriteJournal? = null,
        onProgress: (suspend (fileCount: Int) -> Unit)? = null
    ): WriteManifest {
        val manifest = ManifestBuilder()
        val writer = openSink(context, targetDir, journal)
        val progress = ProgressGate(onProgress)
        val job = currentCoroutineContext()[Job]
        ZipInputStream(BufferedInputStream(FileInputStream(zipFile))).use { zis ->
            var entry = zis.nextEntry
            while (entry != null) {
                job?.ensureActive()
                if (!entry.isDirectory) {
                    val path = sanitizeEntryName(entry.name)
                    if (path.isNotEmpty()) {
                        val parent = path.substringBeforeLast('/', "")
                        writer.prepareDirs(listOf(parent))
                        writer.writeFile(parent, path.substringAfterLast('/'), path) { out ->
                            pump(zis, out, copyBuffers.get()!!, job)
                        }
                        manifest.record(path)
                        progress.emit(manifest.currentFileCount)
                    }
                }
                entry = zis.nextEntry
            }
        }
        requireTreeGrant(context, targetDir)
        return manifest.build()
    }

    /**
     * Copia un archivo suelto (no-ZIP, ej. .lua) directo a la raíz del árbol
     * SAF seleccionado, sin intentar extraerlo. Preserva el nombre original
     * del archivo (que ya trae la extensión correcta, ver ModDownloadWorker /
     * capa Dart que arma el fileName).
     *
     * Mantiene el tipo nullable por compatibilidad con callers existentes;
     * los fallos de escritura, permiso y cancelación se propagan al caller.
     */
    fun copyFileToTree(
        sourceFile: File,
        targetDir: DocumentFile,
        context: Context,
        journal: WriteJournal? = null,
        targetName: String = sourceFile.name,
        checkCancelled: () -> Unit = {}
    ): WriteManifest? {
        val name = sanitizeEntryName(targetName)
        require(name == targetName && name.isNotEmpty() && !name.contains('/')) { "Invalid target name" }
        checkCancelled()
        val writer = openSink(context, targetDir, journal)
        writer.writeFile("", name, name) { out ->
            FileInputStream(sourceFile).use { input ->
                val buffer = copyBuffers.get()!!
                while (true) {
                    checkCancelled()
                    val read = input.read(buffer)
                    if (read < 0) break
                    out.write(buffer, 0, read)
                }
            }
        }
        checkCancelled()
        requireTreeGrant(context, targetDir)
        return ManifestBuilder(looseFile = true).apply { record(name) }.build()
    }

    /**
     * Suma el tamaño total en bytes de todas las entradas no-directorio de
     * un .7z, en un pase de solo-metadata antes de la extracción real —
     * mismo patrón que [countZipEntries] para ZIP.
     *
     * Se usa para calcular el progreso de extracción sobre TODO el archivo
     * (no solo la entrada que se está copiando en ese momento). Antes,
     * [extractSevenZToTree] reportaba el porcentaje de la entrada ACTUAL,
     * que se reinicia a ~0 con cada archivo nuevo dentro del .7z — eso
     * rompía el throttle de progreso de [ModInstallWorker] en cuanto el
     * primer archivo terminaba (ver comentario en extractSevenZToTree).
     */
    @Throws(IOException::class)
    fun countSevenZTotalBytes(zipFile: File): Long {
        var total = 0L
        try {
            SevenZFile.builder().setFile(zipFile).get().use { szf ->
                for (entry in szf.entries) {
                    if (!entry.isDirectory) total += entry.size
                }
            }
        } catch (e: Exception) {
            Log.w("ModInstall", "countSevenZTotalBytes failed", e)
            return 0L
        }
        return total
    }

    @Throws(IOException::class)
    fun countZipEntries(zipFile: File): Int {
        try {
            ZipFile(zipFile).use { zf ->
                var count = 0
                val entries = zf.entries()
                while (entries.hasMoreElements()) {
                    if (!entries.nextElement().isDirectory) count++
                }
                return count
            }
        } catch (_: Exception) {
            return countZipEntriesStreaming(zipFile)
        }
    }

    private fun countZipEntriesStreaming(zipFile: File): Int {
        var count = 0
        try {
            ZipInputStream(BufferedInputStream(FileInputStream(zipFile))).use { zis ->
                var entry: ZipEntry? = zis.nextEntry
                while (entry != null) {
                    if (!entry.isDirectory) {
                        count++
                    }
                    entry = zis.nextEntry
                }
            }
        } catch (_: Exception) {
            return 0
        }
        return count
    }

    /**
     * Detecta el nombre del directorio de nivel superior en el ZIP, si todas
     * las entradas comparten uno. Retorna null si las entradas viven en la
     * raíz o hay más de un directorio top-level.
     */
    fun detectTopLevelDir(zipFile: File): String? {
        try {
            ZipFile(zipFile).use { zf ->
                var common: String? = null
                val entries = zf.entries()
                while (entries.hasMoreElements()) {
                    val name = sanitizeEntryName(entries.nextElement().name)
                    if (name.isNotEmpty() && !name.endsWith("/")) {
                        val slashIdx = name.indexOf('/')
                        if (slashIdx <= 0) return null
                        val top = name.substring(0, slashIdx)
                        if (common == null) common = top else if (common != top) return null
                    }
                }
                return common
            }
        } catch (_: Exception) {
            return detectTopLevelDirStreaming(zipFile)
        }
    }

    private fun detectTopLevelDirStreaming(zipFile: File): String? {
        var commonPrefix: String? = null

        try {
            ZipInputStream(BufferedInputStream(FileInputStream(zipFile))).use { zis ->
                var entry: ZipEntry? = zis.nextEntry
                while (entry != null) {
                    val name = sanitizeEntryName(entry.name)
                    if (name.isNotEmpty() && !name.endsWith("/")) {
                        val slashIdx = name.indexOf('/')
                        if (slashIdx > 0) {
                            val topDir = name.substring(0, slashIdx)
                            if (commonPrefix == null) {
                                commonPrefix = topDir
                            } else if (commonPrefix != topDir) {
                                return null
                            }
                        } else {
                            return null
                        }
                    }
                    entry = zis.nextEntry
                }
            }
        } catch (e: Exception) { Log.w("ModInstall", "detectTopLevelDir failed", e) }

        return commonPrefix
    }

    /**
     * Sanitiza el nombre de una entrada ZIP para evitar path traversal.
     */
    fun sanitizeEntryName(name: String): String {
        var sanitized = name.trim().replace("\\", "/").replace("\u0000", "")
        while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
        val parts = sanitized.split("/").filter { it.isNotEmpty() && it != "." && it != ".." }
        return parts.joinToString("/")
    }

    private fun getOrCreateDir(
        cache: MutableMap<String, DocumentFile>,
        root: DocumentFile,
        path: String,
        journal: WriteJournal? = null
    ): DocumentFile {
        val cached = cache[path]
        if (cached != null) return cached

        val parts = path.split("/").filter { it.isNotEmpty() }
        var current: DocumentFile = root
        var currentPath = ""

        for (part in parts) {
            currentPath = if (currentPath.isEmpty()) part else "$currentPath/$part"

            val cachedDir = cache[currentPath]
            if (cachedDir != null) {
                current = cachedDir
                continue
            }

            val existing = current.findFile(part)
            val existedBefore = existing != null && existing.isDirectory
            current = if (existing != null && existing.isDirectory) {
                existing
            } else {
                current.createDirectory(part) ?: throw SecurityException(
                    "Lost SAF access during extraction: cannot create directory $currentPath"
                )
            }

            journal?.recordDirectory(currentPath, existedBefore)

            cache[currentPath] = current
        }

        return current
    }

    private fun guessMimeType(fileName: String): String {
        return when (fileName.substringAfterLast('.', "").lowercase()) {
            "lua" -> "text/x-lua"
            "zip" -> "application/zip"
            "7z" -> "application/x-7z-compressed"
            else -> "application/octet-stream"
        }
    }

    fun isSevenZipFile(file: File): Boolean {
        return file.extension.equals("7z", ignoreCase = true)
    }

    /**
     * Extrae el contenido de un archivo .7z dentro de [targetDir] (raíz del árbol
     * SAF), igual que extractZipToTree pero usando SevenZFile (Apache Commons
     * Compress) en vez de ZipInputStream.
     *
     * [totalBytes]: suma total de bytes de todas las entradas del archivo,
     * obtenida de antemano con [countSevenZTotalBytes] (mismo patrón que
     * [countZipEntries] para el path de ZIP). Retorna el mismo manifiesto
     * verificable y acotado que la ruta ZIP. Con esto, [onProgress] reporta
     * el porcentaje sobre TODO el archivo, no sobre la entrada individual
     * que se está copiando — ese era el bug real detrás de la notificación
     * y la barra de progreso quedándose "congeladas": antes el porcentaje
     * se reiniciaba a ~0 con cada archivo nuevo del .7z, y el throttle de
     * [ModInstallWorker] (que solo notifica en saltos de +10% respecto al
     * último valor reportado) quedaba varado en cuanto el PRIMER archivo
     * llegaba a 100% — ningún archivo posterior podía volver a cruzar ese
     * umbral porque su propio porcentaje individual nunca superaba 100.
     * La extracción seguía completándose bien en segundo plano (por eso se
     * veían los archivos aparecer en el explorador de archivos), pero la UI
     * y la notificación se quedaban mostrando el último valor que sí logró
     * cruzar el umbral, sin actualizarse nunca más.
     *
     * Si [totalBytes] es 0 o negativo (conteo falló, o archivo vacío),
     * [onProgress] no se invoca — el caller debe caer a modo indeterminado,
     * mismo criterio que ya usa el path de ZIP cuando countZipEntries falla.
     */
    @Throws(IOException::class, SecurityException::class)
    suspend fun extractSevenZToTree(
        zipFile: File,
        targetDir: DocumentFile,
        context: Context,
        totalBytes: Long = 0L,
        journal: WriteJournal? = null,
        onProgress: (suspend (percent: Int) -> Unit)? = null
    ): WriteManifest = withContext(Dispatchers.IO) {
        val manifest = ManifestBuilder()
        val writer = openSink(context, targetDir, journal)
        val progress = ProgressGate(onProgress)
        val doneBytes = AtomicLong(0L)

        suspend fun report() {
            if (totalBytes > 0) {
                progress.emit(((doneBytes.get() * 100) / totalBytes).coerceIn(0L, 100L).toInt())
            }
        }

        SevenZFile.builder().setFile(zipFile).get().use { szf ->
            // Pase de metadata: crear todas las carpetas por adelantado, en paralelo.
            val dirs = HashSet<String>()
            for (e in szf.entries) {
                if (e.isDirectory) continue
                val p = sanitizeEntryName(e.name)
                if (p.isNotEmpty()) dirs += p.substringBeforeLast('/', "")
            }
            writer.prepareDirs(dirs)

            coroutineScope {
                // Entradas pequeñas: se leen a memoria (lectura 7z es secuencial) y
                // se escriben a SAF en paralelo. Cola acotada => memoria acotada.
                val queue = Channel<Pair<String, ByteArray>>(16)
                val writers = List(PARALLELISM) {
                    async(Dispatchers.IO) {
                        for ((path, bytes) in queue) {
                            ensureActive()
                            val currentJob = currentCoroutineContext()[Job]
                            writer.writeFile(
                                path.substringBeforeLast('/', ""),
                                path.substringAfterLast('/'),
                                path
                            ) { out -> pump(ByteArrayInputStream(bytes), out, copyBuffers.get()!!, currentJob) }
                            synchronized(manifest) { manifest.record(path) }
                            doneBytes.addAndGet(bytes.size.toLong())
                            report()
                        }
                    }
                }

                val producer = async {
                    try {
                        val seen = HashSet<String>()
                        var entry: SevenZArchiveEntry? = szf.nextEntry
                        while (entry != null) {
                            ensureActive()
                            val current: SevenZArchiveEntry = entry
                            val path = sanitizeEntryName(current.name)
                            if (!current.isDirectory && path.isNotEmpty() && seen.add(path)) {
                                val size = current.size
                                require(size >= 0) { "Invalid 7z entry size" }
                                if (size <= SMALL_ENTRY_LIMIT) {
                                    val bytes = ByteArray(size.toInt())
                                    var off = 0
                                    while (off < bytes.size) {
                                        ensureActive()
                                        val n = szf.read(bytes, off, bytes.size - off)
                                        if (n <= 0) throw IOException("Unexpected end of 7z entry: $path")
                                        off += n
                                    }
                                    queue.send(path to bytes)
                                } else {
                                    val job = currentCoroutineContext()[Job]
                                    val buf = copyBuffers.get()!!
                                    writer.writeFile(
                                        path.substringBeforeLast('/', ""),
                                        path.substringAfterLast('/'),
                                        path
                                    ) { out ->
                                        var read = 0L
                                        while (read < size) {
                                            val n = szf.read(
                                                buf, 0, minOf(buf.size.toLong(), size - read).toInt()
                                            )
                                            if (n <= 0) throw IOException("Unexpected end of 7z entry: $path")
                                            out.write(buf, 0, n)
                                            read += n
                                            doneBytes.addAndGet(n.toLong())
                                            job?.ensureActive()
                                        }
                                    }
                                    synchronized(manifest) { manifest.record(path) }
                                    report()
                                }
                            }
                            entry = szf.nextEntry
                        }
                    } finally {
                        queue.close()
                    }
                }
                (writers + producer).awaitAll()
            }
        }

        requireTreeGrant(context, targetDir)
        manifest.build()
    }
}

package mods.sm64cdpy

import android.content.Context
import android.util.Log
import androidx.documentfile.provider.DocumentFile
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
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

    /**
     * Extrae el contenido de [zipFile] dentro de [targetDir] (raíz del árbol SAF).
     * Retorna el número de archivos extraídos.
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
        onProgress: (suspend (fileCount: Int) -> Unit)? = null
    ): Int {
        var fileCount = 0
        val createdDirs = mutableMapOf<String, DocumentFile>()

        ZipInputStream(BufferedInputStream(FileInputStream(zipFile))).use { zis ->
            var entry: ZipEntry? = zis.nextEntry
            while (entry != null) {
                if (!entry.isDirectory) {
                    val entryName = sanitizeEntryName(entry.name)
                    if (entryName.isNotEmpty() && !entryName.endsWith("/")) {
                        val slashIdx = entryName.lastIndexOf('/')
                        val parentDir: DocumentFile
                        val fileName: String

                        if (slashIdx > 0) {
                            val dirPath = entryName.substring(0, slashIdx)
                            val simpleName = entryName.substring(slashIdx + 1)
                            parentDir = getOrCreateDir(createdDirs, targetDir, dirPath)
                            fileName = simpleName
                        } else {
                            parentDir = targetDir
                            fileName = entryName
                        }

                        if (parentDir == targetDir || (parentDir.exists() && parentDir.isDirectory)) {
                            parentDir.findFile(fileName)?.delete()

                            val outputFile = parentDir.createFile(
                                "application/octet-stream", fileName
                            ) ?: throw SecurityException(
                                "Lost SAF access during extraction: cannot create $fileName"
                            )

                            context.contentResolver
                                .openOutputStream(outputFile.uri)?.use { os ->
                                    zis.copyTo(os)
                                    os.flush()
                                }
                                ?: throw SecurityException(
                                    "Lost SAF access during extraction: cannot open $fileName"
                                )

                            fileCount++
                            onProgress?.invoke(fileCount)
                        }
                    }
                }
                entry = zis.nextEntry
            }
        }

        return fileCount
    }

    /**
     * Copia un archivo suelto (no-ZIP, ej. .lua) directo a la raíz del árbol
     * SAF seleccionado, sin intentar extraerlo. Preserva el nombre original
     * del archivo (que ya trae la extensión correcta, ver ModDownloadWorker /
     * capa Dart que arma el fileName).
     *
     * Retorna false si no se pudo crear o escribir el archivo destino — el
     * caller decide cómo reportar el fallo (ModInstallWorker lo convierte en
     * Result.failure, así que el error no es silencioso).
     */
    fun copyFileToTree(
        sourceFile: File,
        targetDir: DocumentFile,
        context: Context
    ): Boolean {
        return try {
            val mimeType = guessMimeType(sourceFile.name)
            targetDir.findFile(sourceFile.name)?.delete()
            val outputFile = targetDir.createFile(mimeType, sourceFile.name)
                ?: return false

            context.contentResolver.openOutputStream(outputFile.uri)?.use { os ->
                FileInputStream(sourceFile).use { input ->
                    input.copyTo(os)
                }
                os.flush()
            } ?: return false

            true
        } catch (_: Exception) {
            false
        }
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
                var entry: SevenZArchiveEntry? = szf.nextEntry
                while (entry != null) {
                    if (!entry.isDirectory) {
                        total += entry.size
                    }
                    entry = szf.nextEntry
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
        path: String
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
            current = if (existing != null && existing.isDirectory) {
                existing
            } else {
                current.createDirectory(part) ?: current
            }

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
     * [countZipEntries] para el path de ZIP). Con esto, [onProgress] reporta
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
        onProgress: (suspend (percent: Int) -> Unit)? = null
    ): Int {
        var fileCount = 0
        var bytesReadSoFar = 0L
        val createdDirs = mutableMapOf<String, DocumentFile>()

        SevenZFile.builder().setFile(zipFile).get().use { szf ->
            var entry: SevenZArchiveEntry? = szf.nextEntry
            while (entry != null) {
                if (!entry.isDirectory) {
                    val entryName = sanitizeEntryName(entry.name)
                    if (entryName.isNotEmpty() && !entryName.endsWith("/")) {
                        val slashIdx = entryName.lastIndexOf('/')
                        val parentDir: DocumentFile
                        val fileName: String

                        if (slashIdx > 0) {
                            val dirPath = entryName.substring(0, slashIdx)
                            val simpleName = entryName.substring(slashIdx + 1)
                            parentDir = getOrCreateDir(createdDirs, targetDir, dirPath)
                            fileName = simpleName
                        } else {
                            parentDir = targetDir
                            fileName = entryName
                        }

                        if (parentDir == targetDir || (parentDir.exists() && parentDir.isDirectory)) {
                            parentDir.findFile(fileName)?.delete()

                            val outputFile = parentDir.createFile(
                                "application/octet-stream", fileName
                            ) ?: throw SecurityException(
                                "Lost SAF access during 7z extraction: cannot create $fileName"
                            )

                            context.contentResolver
                                .openOutputStream(outputFile.uri)?.use { os ->
                                    val entrySize = entry.size
                                    val buffer = ByteArray(8192)
                                    var read: Long = 0

                                    // Mismo fix de loop infinito que antes (condición de
                                    // corte por bytes leídos, no por valor de retorno),
                                    // más el tracking de bytesReadSoFar ACUMULADO entre
                                    // entradas (fuera de este scope) para el progreso real.
                                    while (read < entrySize) {
                                        val toRead = minOf(
                                            buffer.size.toLong(),
                                            entrySize - read
                                        ).toInt()
                                        val n = szf.read(buffer, 0, toRead)
                                        if (n <= 0) break
                                        os.write(buffer, 0, n)
                                        read += n
                                        bytesReadSoFar += n
                                        if (totalBytes > 0) {
                                            onProgress?.invoke(
                                                ((bytesReadSoFar * 100) / totalBytes).toInt()
                                            )
                                        }
                                    }
                                    os.flush()
                                }
                                ?: throw SecurityException(
                                    "Lost SAF access during 7z extraction: cannot open $fileName"
                                )

                            fileCount++
                        }
                    }
                }
                entry = szf.nextEntry
            }
        }

        return fileCount
    }
}

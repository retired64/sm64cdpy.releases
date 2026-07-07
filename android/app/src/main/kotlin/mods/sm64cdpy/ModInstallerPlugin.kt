package mods.sm64cdpy

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.*
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream

/**
 * Plugin nativo para gestionar la carpeta de mods mediante Storage Access Framework (SAF).
 *
 * Flujo:
 *  1. Usuario va a Settings  "Seleccionar carpeta de mods"
 *  2. Se abre el explorador de archivos del sistema (ACTION_OPEN_DOCUMENT_TREE)
 *  3. El usuario selecciona la carpeta destino (ej: /storage/emulated/0/...)
 *  4. La URI se persiste con takePersistableUriPermission
 *  5. Futuras descargas se instalan automáticamente en esa carpeta
 */
class ModInstallerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        const val CHANNEL = "mods.sm64cdpy/mod_installer"
        const val PREF_NAME = "mod_installer_prefs"
        const val KEY_TREE_URI = "tree_uri"
        const val REQUEST_CODE_TREE = 9001
    }

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ── ActivityAware ───────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, data ->
            if (requestCode == REQUEST_CODE_TREE) {
                handleTreeResult(resultCode, data)
                true
            } else {
                false
            }
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    // ── MethodCallHandler ───────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "openDirectoryPicker" -> openDirectoryPicker(result)
            "getSavedDirectoryUri" -> getSavedDirectoryUri(result)
            "installMod" -> installMod(call, result)
            "isDirectorySelected" -> isDirectorySelected(result)
            "clearDirectorySelection" -> clearDirectorySelection(result)
            else -> result.notImplemented()
        }
    }

    // ── Métodos expuestos ──────────────────────────────────────────────────

    /**
     * Abre el picker de directorios del sistema (ACTION_OPEN_DOCUMENT_TREE).
     */
    private fun openDirectoryPicker(result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        pendingResult = result

        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                )
                // Sugerir ruta inicial (opcional, el sistema lo ignora si no existe)
                // No forzamos EXTRA_INITIAL_URI para evitar errores en algunos dispositivos
            }
            act.startActivityForResult(intent, REQUEST_CODE_TREE)
        } catch (e: Exception) {
            pendingResult = null
            result.error("PICKER_ERROR", "Failed to open directory picker: ${e.message}", null)
        }
    }

    /**
     * Devuelve la URI del directorio guardado, o null si nunca se seleccionó.
     */
    private fun getSavedDirectoryUri(result: Result) {
        val prefs = getPrefs()
        val uriString = prefs.getString(KEY_TREE_URI, null)
        if (uriString != null) {
            // Verificar que la URI sigue siendo accesible
            val uri = Uri.parse(uriString)
            if (isTreeAccessible(uri)) {
                result.success(uriString)
            } else {
                // Ya no es accesible — limpiar
                prefs.edit().remove(KEY_TREE_URI).apply()
                result.success(null)
            }
        } else {
            result.success(null)
        }
    }

    /**
     * Verifica si ya hay un directorio seleccionado.
     */
    private fun isDirectorySelected(result: Result) {
        val prefs = getPrefs()
        val uriString = prefs.getString(KEY_TREE_URI, null)
        if (uriString != null) {
            val uri = Uri.parse(uriString)
            result.success(isTreeAccessible(uri))
        } else {
            result.success(false)
        }
    }

    /**
     * Limpia la selección de directorio (revoca permisos).
     */
    private fun clearDirectorySelection(result: Result) {
        val prefs = getPrefs()
        val uriString = prefs.getString(KEY_TREE_URI, null)
        if (uriString != null) {
            try {
                val uri = Uri.parse(uriString)
                val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                activity?.contentResolver?.releasePersistableUriPermission(uri, flags)
            } catch (_: Exception) { }
        }
        prefs.edit().remove(KEY_TREE_URI).apply()
        result.success(true)
    }

    /**
     * Instala un mod: descomprime un ZIP en un subdirectorio dentro del árbol SAF.
     *
     * Parámetros:
     *  - zipPath (String): ruta absoluta al archivo ZIP descargado
     *  - modName (String): nombre del subdirectorio a crear (nombre del mod sanitizado)
     *
     * Retorna un mapa con:
     *  - success (bool)
     *  - targetDir (String): nombre del directorio creado (si success)
     *  - fileCount (int): cantidad de archivos extraídos
     *  - error (String): mensaje de error (si !success)
     */
    private fun installMod(call: MethodCall, result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        val prefs = getPrefs()
        val treeUriString = prefs.getString(KEY_TREE_URI, null)
        if (treeUriString == null) {
            result.error("NO_DIRECTORY", "No mods directory selected. Please select one in Settings first.", null)
            return
        }

        val treeUri = Uri.parse(treeUriString)
        if (!isTreeAccessible(treeUri)) {
            prefs.edit().remove(KEY_TREE_URI).apply()
            result.error(
                "DIR_NOT_ACCESSIBLE",
                "The selected directory is no longer accessible. Please select it again in Settings.",
                null
            )
            return
        }

        val zipPath = call.argument<String>("zipPath")
        val modName = call.argument<String>("modName")

        if (zipPath == null || modName == null) {
            result.error("INVALID_ARGS", "zipPath and modName are required", null)
            return
        }

        val zipFile = java.io.File(zipPath)
        if (!zipFile.exists()) {
            result.error("FILE_NOT_FOUND", "ZIP file not found at: $zipPath", null)
            return
        }

        Thread {
            try {
                val treeDoc = DocumentFile.fromTreeUri(act, treeUri)
                if (treeDoc == null) {
                    act.runOnUiThread {
                        result.error("TREE_ERROR", "Could not access the selected directory tree.", null)
                    }
                    return@Thread
                }

                // Extraer ZIP directamente en la raíz del árbol SAF.
                // El ZIP ya contiene su propia estructura de carpetas
                // (ej: character-select-coop/main.lua).
                // No creamos subdirectorios adicionales para no romper la
                // estructura que el juego espera: mods/<carpeta_del_mod>/main.lua
                val fileCount = extractZipToDocumentFile(zipFile, treeDoc, act)
                val topDir = detectTopLevelDir(zipFile)
                val displayDir = topDir ?: modName
                zipFile.delete() // Eliminar ZIP tras extracción exitosa

                act.runOnUiThread {
                    result.success(mapOf(
                        "success" to true,
                        "targetDir" to displayDir,
                        "fileCount" to fileCount
                    ))
                }
            } catch (e: Exception) {
                act.runOnUiThread {
                    result.error("INSTALL_ERROR", e.message ?: "Unknown error during installation", null)
                }
            }
        }.start()
    }

    // ── Internals ───────────────────────────────────────────────────────────

    private fun getPrefs(): SharedPreferences {
        return activity?.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
            ?: throw IllegalStateException("Activity not available")
    }

    /**
     * Procesa el resultado del picker de directorios.
     */
    private fun handleTreeResult(resultCode: Int, data: Intent?) {
        val result = pendingResult ?: return
        pendingResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null) // Usuario canceló
            return
        }

        val treeUri = data.data!!

        // Persistir permisos para reinicios del dispositivo
        try {
            val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            activity?.contentResolver?.takePersistableUriPermission(treeUri, takeFlags)

            // Guardar URI
            getPrefs().edit().putString(KEY_TREE_URI, treeUri.toString()).apply()

            // Obtener nombre del directorio seleccionado para mostrar en UI
            val doc = DocumentFile.fromTreeUri(activity!!, treeUri)
            val displayName = doc?.name ?: treeUri.lastPathSegment ?: "Unknown"

            result.success(treeUri.toString())
        } catch (e: Exception) {
            result.error("PERSIST_ERROR", "Failed to persist directory permission: ${e.message}", null)
        }
    }

    /**
     * Verifica si el árbol en [treeUri] sigue siendo accesible.
     */
    private fun isTreeAccessible(treeUri: Uri): Boolean {
        return try {
            val doc = activity?.let { DocumentFile.fromTreeUri(it, treeUri) }
            doc != null && doc.exists()
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Extrae el contenido de [zipFile] dentro de [targetDir] (DocumentFile del árbol SAF).
     * Retorna el número de archivos extraídos.
     */
    @Throws(IOException::class)
    private fun extractZipToDocumentFile(zipFile: java.io.File, targetDir: DocumentFile, context: Context): Int {
        var fileCount = 0
        val createdDirs = mutableMapOf<String, DocumentFile>()

        ZipInputStream(BufferedInputStream(FileInputStream(zipFile))).use { zis ->
            var entry: ZipEntry? = zis.nextEntry
            while (entry != null) {
                if (!entry.isDirectory) {
                    val entryName = sanitizeEntryName(entry.name)
                    if (entryName.isEmpty() || entryName.endsWith("/")) {
                        entry = zis.nextEntry
                        continue
                    }

                    // Determinar subdirectorio padre
                    val slashIdx = entryName.lastIndexOf('/')
                    val parentDir: DocumentFile
                    val fileName: String

                    if (slashIdx > 0) {
                        val dirPath = entryName.substring(0, slashIdx)
                        val simpleName = entryName.substring(slashIdx + 1)
                        parentDir = getOrCreateDir(createdDirs, targetDir, dirPath, context)
                        fileName = simpleName
                    } else {
                        parentDir = targetDir
                        fileName = entryName
                    }

                    if (parentDir == targetDir || (parentDir.exists() && parentDir.isDirectory)) {
                        val outputFile = parentDir.createFile("application/octet-stream", fileName)
                        if (outputFile != null) {
                            context.contentResolver.openOutputStream(outputFile.uri)?.use { os ->
                                zis.copyTo(os)
                                os.flush()
                            }
                            fileCount++
                        }
                    }
                }
                entry = zis.nextEntry
            }
        }

        return fileCount
    }

    /**
     * Obtiene o crea un subdirectorio en el árbol SAF.
     */
    private fun getOrCreateDir(
        cache: MutableMap<String, DocumentFile>,
        root: DocumentFile,
        path: String,
        context: Context
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

    /**
     * Detecta el nombre del directorio de nivel superior en el ZIP.
     * Si todas las entradas comparten un prefijo común de un nivel
     * (ej: "char-select/main.lua", "char-select/actors/..." → "char-select"),
     * devuelve ese nombre. Si no hay prefijo común (archivos sueltos en raíz),
     * devuelve null.
     */
    private fun detectTopLevelDir(zipFile: java.io.File): String? {
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
                                return null // Múltiples directorios de nivel superior
                            }
                        } else {
                            // Hay un archivo en la raíz → no hay prefijo común
                            return null
                        }
                    }
                    entry = zis.nextEntry
                }
            }
        } catch (_: Exception) { }

        return commonPrefix
    }

    /**
     * Sanitiza el nombre de una entrada ZIP para evitar path traversal.
     */
    private fun sanitizeEntryName(name: String): String {
        var sanitized = name.trim()
        // Eliminar barras iniciales
        while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
        // Eliminar segmentos ".."
        sanitized = sanitized.replace("../", "").replace("..\\", "")
        // Normalizar separadores
        sanitized = sanitized.replace("\\", "/")
        // Eliminar NUL bytes
        sanitized = sanitized.replace("\u0000", "")
        return sanitized
    }
}

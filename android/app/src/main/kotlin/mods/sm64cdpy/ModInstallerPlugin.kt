package mods.sm64cdpy

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.documentfile.provider.DocumentFile
import androidx.lifecycle.Observer
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.workDataOf
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.*
import java.util.UUID
import kotlinx.coroutines.runBlocking

/**
 * Plugin nativo para gestionar la carpeta de mods mediante Storage Access Framework (SAF).
 *
 * Flujo:
 *  1. Usuario va a Settings  "Seleccionar carpeta de mods"
 *  2. Se abre el explorador de archivos del sistema (ACTION_OPEN_DOCUMENT_TREE)
 *  3. El usuario selecciona la carpeta destino (ej: /storage/emulated/0/...)
 *  4. La URI se persiste con takePersistableUriPermission
 *  5. Futuras descargas se instalan automáticamente en esa carpeta
 *
 * Background install (WorkManager):
 *  - installModBackground(): encola un OneTimeWorkRequest con ModInstallWorker
 *  - El worker ejecuta la extracción con foreground service y notificación
 *  - El progreso se reporta via EventChannel "mod_install_events"
 */
class ModInstallerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        const val CHANNEL = "mods.sm64cdpy/mod_installer"
        const val EVENT_CHANNEL = "mods.sm64cdpy/mod_install_events"
        const val PREF_NAME = "mod_installer_prefs"
        const val KEY_TREE_URI = "tree_uri"
        const val KEY_DYNOS_TREE_URI = "dynos_tree_uri"
        const val REQUEST_CODE_TREE = 9001
        const val REQUEST_CODE_DYNOS_TREE = 9003
        const val REQUEST_CODE_NOTIFICATION_PERMISSION = 9002
        const val UNIQUE_WORK_PREFIX = "mod_install_"
    }

    private lateinit var channel: MethodChannel
    private var eventChannel: EventChannel? = null
    private val eventSinks = mutableListOf<EventChannel.EventSink>()
    private var activity: Activity? = null
    private var pendingModPickerResult: Result? = null
    private var pendingDynosPickerResult: Result? = null
    private var pendingPermissionResult: Result? = null

    private val workObservers = mutableMapOf<UUID, Observer<WorkInfo>>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel!!.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                eventSinks.add(sink)
            }

            override fun onCancel(args: Any?) {
                // onCancel does not provide the sink — dead sinks are
                // pruned during sendEvent() when they throw on success()
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        eventSinks.clear()
        cleanupObservers()
    }

    // ── ActivityAware ───────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, data ->
            if (requestCode == REQUEST_CODE_TREE) {
                handleTreeResult(resultCode, data)
                true
            } else if (requestCode == REQUEST_CODE_DYNOS_TREE) {
                handleDynosTreeResult(resultCode, data)
                true
            } else {
                false
            }
        }
        binding.addRequestPermissionsResultListener { requestCode, _, grantResults ->
            if (requestCode == REQUEST_CODE_NOTIFICATION_PERMISSION) {
                val result = pendingPermissionResult ?: return@addRequestPermissionsResultListener false
                pendingPermissionResult = null
                val granted = grantResults.isNotEmpty() &&
                        grantResults[0] == PackageManager.PERMISSION_GRANTED
                result.success(granted)
                return@addRequestPermissionsResultListener true
            }
            false
        }
    }

    override fun onDetachedFromActivity() {
        cleanupObservers()
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
            "installModToDynosFolder" -> installModToDynosFolder(call, result)
            "installModBackground" -> installModBackground(call, result)
            "downloadAndInstallMod" -> downloadAndInstallMod(call, result)
            "cancelModOperation" -> cancelModOperation(call, result)
            "isDirectorySelected" -> isDirectorySelected(result)
            "clearDirectorySelection" -> clearDirectorySelection(result)
            "hasNotificationPermission" -> hasNotificationPermission(result)
            "requestNotificationPermission" -> requestNotificationPermission(result)
            "shouldShowNotificationRationale" -> shouldShowNotificationRationale(result)
            "copyFileToModsFolder" -> copyFileToModsFolder(call, result)
            "openDynosPicker" -> openDynosPicker(result)
            "getSavedDynosUri" -> getSavedDynosUri(result)
            "isDynosDirectorySelected" -> isDynosDirectorySelected(result)
            "copyFileToDynosFolder" -> copyFileToDynosFolder(call, result)
            "clearDynosSelection" -> clearDynosSelection(result)
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

        pendingModPickerResult = result

        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                )
            }
            act.startActivityForResult(intent, REQUEST_CODE_TREE)
        } catch (e: Exception) {
            pendingModPickerResult = null
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
            val uri = Uri.parse(uriString)
            if (isTreeAccessible(uri)) {
                result.success(uriString)
            } else {
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
     * Checks if POST_NOTIFICATIONS permission is granted.
     * Always returns true on Android < 13.
     */
    private fun hasNotificationPermission(result: Result) {
        val act = activity
        if (act == null) {
            result.success(false)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }
        val granted = ContextCompat.checkSelfPermission(
            act, Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
        result.success(granted)
    }

    /**
     * Checks if we should show a rationale explaining why notifications are needed.
     */
    private fun shouldShowNotificationRationale(result: Result) {
        val act = activity
        if (act == null) {
            result.success(false)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(false)
            return
        }
        val showRationale = ActivityCompat.shouldShowRequestPermissionRationale(
            act, Manifest.permission.POST_NOTIFICATIONS
        )
        result.success(showRationale)
    }

    /**
     * Requests POST_NOTIFICATIONS permission via system dialog.
     * On Android < 13, returns true immediately (no dialog needed).
     */
    private fun requestNotificationPermission(result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(
            act,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_CODE_NOTIFICATION_PERMISSION
        )
    }

    /**
     * Copies a local file into the SAF mods folder tree.
     * Used when auto-install is OFF — just place the ZIP in the mods folder
     * without extracting it, so the user can manage it manually later.
     */
    private fun copyFileToModsFolder(call: MethodCall, result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        val prefs = getPrefs()
        val treeUriString = prefs.getString(KEY_TREE_URI, null)
        if (treeUriString == null) {
            result.error("NO_DIRECTORY", "No mods directory selected.", null)
            return
        }

        val treeUri = Uri.parse(treeUriString)
        if (!isTreeAccessible(treeUri)) {
            prefs.edit().remove(KEY_TREE_URI).apply()
            result.error(
                "DIR_NOT_ACCESSIBLE",
                "The selected directory is no longer accessible.",
                null
            )
            return
        }

        val sourcePath = call.argument<String>("sourcePath")
        val targetName = call.argument<String>("targetName")
        if (sourcePath == null || targetName == null) {
            result.error("INVALID_ARGS", "sourcePath and targetName are required", null)
            return
        }

        val sourceFile = java.io.File(sourcePath)
        if (!sourceFile.exists()) {
            result.error("FILE_NOT_FOUND", "Source file not found: $sourcePath", null)
            return
        }

        try {
            val treeDoc = DocumentFile.fromTreeUri(act, treeUri)
                ?: throw java.io.IOException("Could not access the selected directory tree.")

            val outputFile = treeDoc.createFile("application/octet-stream", targetName)
                ?: throw java.io.IOException("Failed to create file in SAF directory.")

            act.contentResolver.openOutputStream(outputFile.uri)?.use { os ->
                sourceFile.inputStream().use { input ->
                    input.copyTo(os)
                }
                os.flush()
            }

            sourceFile.delete()
            result.success(true)
        } catch (e: Exception) {
            result.error("COPY_ERROR", e.message ?: "Failed to copy file to mods folder", null)
        }
    }

    /**
     * Instala un mod: descomprime un ZIP en un subdirectorio dentro del árbol SAF.
     * (Método original — ejecución sincrónica en hilo nativo.)
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

                val fileCount = runBlocking {
                    SafZipExtractor.extractZipToTree(zipFile, treeDoc, act)
                }
                val topDir = SafZipExtractor.detectTopLevelDir(zipFile)
                val displayDir = topDir ?: modName
                zipFile.delete()

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

    /**
     * Instala un mod (extrae el ZIP) directamente en la carpeta DynOS
     * seleccionada por el usuario. Clon de installMod() pero leyendo
     * KEY_DYNOS_TREE_URI en vez de KEY_TREE_URI.
     */
    private fun installModToDynosFolder(call: MethodCall, result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        val prefs = getPrefs()
        val treeUriString = prefs.getString(KEY_DYNOS_TREE_URI, null)
        if (treeUriString == null) {
            result.error("NO_DIRECTORY", "No DynOS directory selected. Please select one in Settings first.", null)
            return
        }

        val treeUri = Uri.parse(treeUriString)
        if (!isTreeAccessible(treeUri)) {
            prefs.edit().remove(KEY_DYNOS_TREE_URI).apply()
            result.error(
                "DIR_NOT_ACCESSIBLE",
                "The selected DynOS directory is no longer accessible. Please select it again in Settings.",
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
                        result.error("TREE_ERROR", "Could not access the selected DynOS directory tree.", null)
                    }
                    return@Thread
                }

                val fileCount = runBlocking {
                    SafZipExtractor.extractZipToTree(zipFile, treeDoc, act)
                }
                val topDir = SafZipExtractor.detectTopLevelDir(zipFile)
                val displayDir = topDir ?: modName
                zipFile.delete()

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

    /**
     * Instalación en segundo plano via WorkManager (NO BLOQUEA la UI).
     *
     * Encola un OneTimeWorkRequest con ModInstallWorker que ejecuta la extracción
     * con foreground service + notificación. El progreso se reporta via EventChannel.
     *
     * Retorna inmediatamente el workId (UUID string).
     */
    private fun installModBackground(call: MethodCall, result: Result) {
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

        val workName = UNIQUE_WORK_PREFIX + modName

        val inputData = workDataOf(
            ModInstallWorker.KEY_ZIP_PATH to zipPath,
            ModInstallWorker.KEY_MOD_NAME to modName,
            ModInstallWorker.KEY_TREE_URI to treeUriString
        )

        val request = OneTimeWorkRequestBuilder<ModInstallWorker>()
            .setInputData(inputData)
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .addTag(workName)
            .build()

        val workId = request.id

        val observer = Observer<WorkInfo> { workInfo ->
            if (workInfo != null) {
                val eventData = mutableMapOf<String, Any?>(
                    "workId" to workId.toString(),
                    "modName" to modName,
                    "state" to workInfo.state.name
                )

                val progress = workInfo.progress
                eventData["current"] = progress.getInt(
                    ModInstallWorker.PROGRESS_CURRENT, 0
                )
                eventData["total"] = progress.getInt(
                    ModInstallWorker.PROGRESS_TOTAL, 0
                )

                if (workInfo.state == WorkInfo.State.SUCCEEDED) {
                    val output = workInfo.outputData
                    eventData["type"] = "completed"
                    eventData["fileCount"] = output.getInt(
                        ModInstallWorker.OUTPUT_FILE_COUNT, 0
                    )
                    eventData["targetDir"] = output.getString(
                        ModInstallWorker.OUTPUT_TARGET_DIR
                    ) ?: modName
                } else if (workInfo.state == WorkInfo.State.FAILED) {
                    eventData["type"] = "error"
                    eventData["error"] = workInfo.outputData.getString("error")
                        ?: "Installation failed"
                } else if (workInfo.state == WorkInfo.State.RUNNING) {
                    eventData["type"] = "progress"
                } else {
                    eventData["type"] = "pending"
                }

                sendEvent(eventData)

                if (workInfo.state.isFinished) {
                    val obs = workObservers.remove(workId)
                    if (obs != null) {
                        WorkManager.getInstance(act)
                            .getWorkInfoByIdLiveData(workId)
                            .removeObserver(obs)
                    }
                }
            }
        }

        workObservers[workId] = observer
        WorkManager.getInstance(act)
            .getWorkInfoByIdLiveData(workId)
            .observeForever(observer)

        WorkManager.getInstance(act).enqueue(request)

        result.success(workId.toString())
    }

    /**
     * Descarga e instalación en cadena via WorkManager.
     *
     * Encadena ModDownloadWorker → ModInstallWorker.
     * El ZIP descargado se pasa como input al worker de instalación.
     * Ambos workers muestran foreground notifications con cancel button.
     *
     * Retorna inmediatamente un mapa con downloadWorkId e installWorkId.
     */
     private fun downloadAndInstallMod(call: MethodCall, result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        val prefs = getPrefs()
        val destination = call.argument<String>("installDestination") ?: "mods"
        val treeUriPrefKey = if (destination == "dynos") KEY_DYNOS_TREE_URI else KEY_TREE_URI
        val destLabel = if (destination == "dynos") "DynOS" else "mods"

        val treeUriString = prefs.getString(treeUriPrefKey, null)
        if (treeUriString == null) {
            result.error("NO_DIRECTORY", "No $destLabel directory selected. Please select one in Settings first.", null)
            return
        }

        val treeUri = Uri.parse(treeUriString)
        if (!isTreeAccessible(treeUri)) {
            prefs.edit().remove(treeUriPrefKey).apply()
            result.error(
                "DIR_NOT_ACCESSIBLE",
                "The selected $destLabel directory is no longer accessible. Please select it again in Settings.",
                null
            )
            return
        }

        val url = call.argument<String>("url")
        val modName = call.argument<String>("modName")
        val fileName = call.argument<String>("fileName")

        if (url == null || modName == null || fileName == null) {
            result.error("INVALID_ARGS", "url, modName and fileName are required", null)
            return
        }

        val chainName = "mod_chain_$modName"

        val downloadRequest = OneTimeWorkRequestBuilder<ModDownloadWorker>()
            .setInputData(workDataOf(
                ModDownloadWorker.KEY_URL to url,
                ModDownloadWorker.KEY_MOD_NAME to modName,
                ModDownloadWorker.KEY_FILE_NAME to fileName
            ))
            // Antes no había Constraints: sin internet, el Worker arrancaba
            // igual, fallaba al conectar, y consumía uno de sus reintentos
            // limitados en vano. Con esto, WorkManager directamente espera
            // a que haya red antes de arrancar — no gasta reintentos en
            // fallos que sabemos de antemano que van a ocurrir.
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .addTag("mod_dl_$modName")
            .addTag(chainName)
            .build()

        val installRequest = OneTimeWorkRequestBuilder<ModInstallWorker>()
            .setInputData(workDataOf(
                ModInstallWorker.KEY_MOD_NAME to modName,
                ModInstallWorker.KEY_TREE_URI to treeUriString
            ))
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .addTag("mod_install_$modName")
            .addTag(chainName)
            .build()

        val downloadId = downloadRequest.id
        val installId = installRequest.id

        val dlObserver = Observer<WorkInfo> { workInfo ->
            if (workInfo != null) {
                val eventData = mutableMapOf<String, Any?>(
                    "workId" to downloadId.toString(),
                    "modName" to modName,
                    "phase" to "downloading",
                    "state" to workInfo.state.name
                )

                val progress = workInfo.progress
                eventData["progress"] = progress.getInt(ModDownloadWorker.PROGRESS, 0)

                if (workInfo.state == WorkInfo.State.SUCCEEDED) {
                    eventData["type"] = "download_completed"
                } else if (workInfo.state == WorkInfo.State.FAILED) {
                    eventData["type"] = "error"
                    eventData["error"] = workInfo.outputData.getString("error")
                        ?: "Download failed"
                } else if (workInfo.state == WorkInfo.State.CANCELLED) {
                    eventData["type"] = "cancelled"
                } else if (workInfo.state == WorkInfo.State.RUNNING) {
                    eventData["type"] = "download_progress"
                } else {
                    eventData["type"] = "pending"
                }

                sendEvent(eventData)

                if (workInfo.state.isFinished) {
                    val obs = workObservers.remove(downloadId)
                    if (obs != null) {
                        WorkManager.getInstance(act)
                            .getWorkInfoByIdLiveData(downloadId)
                            .removeObserver(obs)
                    }
                }
            }
        }

        val instObserver = Observer<WorkInfo> { workInfo ->
            if (workInfo != null) {
                val eventData = mutableMapOf<String, Any?>(
                    "workId" to installId.toString(),
                    "modName" to modName,
                    "phase" to "installing",
                    "state" to workInfo.state.name
                )

                val progress = workInfo.progress
                eventData["current"] = progress.getInt(
                    ModInstallWorker.PROGRESS_CURRENT, 0
                )
                eventData["total"] = progress.getInt(
                    ModInstallWorker.PROGRESS_TOTAL, 0
                )

                if (workInfo.state == WorkInfo.State.SUCCEEDED) {
                    val output = workInfo.outputData
                    eventData["type"] = "install_completed"
                    eventData["fileCount"] = output.getInt(
                        ModInstallWorker.OUTPUT_FILE_COUNT, 0
                    )
                    eventData["targetDir"] = output.getString(
                        ModInstallWorker.OUTPUT_TARGET_DIR
                    ) ?: modName
                } else if (workInfo.state == WorkInfo.State.FAILED) {
                    eventData["type"] = "error"
                    eventData["error"] =
                        workInfo.outputData.getString("error")
                            ?: "Installation failed"
                } else if (workInfo.state == WorkInfo.State.CANCELLED) {
                    eventData["type"] = "cancelled"
                } else if (workInfo.state == WorkInfo.State.RUNNING) {
                    eventData["type"] = "install_progress"
                } else {
                    eventData["type"] = "pending"
                }

                sendEvent(eventData)

                if (workInfo.state.isFinished) {
                    val obs = workObservers.remove(installId)
                    if (obs != null) {
                        WorkManager.getInstance(act)
                            .getWorkInfoByIdLiveData(installId)
                            .removeObserver(obs)
                    }
                }
            }
        }

        workObservers[downloadId] = dlObserver
        workObservers[installId] = instObserver

        WorkManager.getInstance(act)
            .getWorkInfoByIdLiveData(downloadId)
            .observeForever(dlObserver)

        WorkManager.getInstance(act)
            .getWorkInfoByIdLiveData(installId)
            .observeForever(instObserver)

        // beginUniqueWork + REPLACE: si el usuario dispara la instalación del
        // mismo mod dos veces (doble tap, o un flujo de "actualizar" mientras
        // la instalación anterior seguía corriendo), la cadena vieja se
        // cancela y arranca una limpia — en vez de dos cadenas escribiendo
        // en paralelo sobre la misma carpeta SAF, que es una receta para
        // archivos a medio escribir o corrupción silenciosa.
        WorkManager.getInstance(act)
            .beginUniqueWork(chainName, ExistingWorkPolicy.REPLACE, downloadRequest)
            .then(installRequest)
            .enqueue()

        result.success(mapOf(
            "downloadWorkId" to downloadId.toString(),
            "installWorkId" to installId.toString()
        ))
    }

    /**
     * Cancela todas las operaciones asociadas a un mod por nombre.
     */
    private fun cancelModOperation(call: MethodCall, result: Result) {
        val modName = call.argument<String>("modName")
        if (modName == null) {
            result.error("INVALID_ARGS", "modName is required", null)
            return
        }

        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        val wm = WorkManager.getInstance(act)
        wm.cancelAllWorkByTag("mod_dl_$modName")
        wm.cancelAllWorkByTag("mod_install_$modName")
        wm.cancelAllWorkByTag("mod_chain_$modName")

        result.success(true)
    }

    // ── Métodos DynOS ───────────────────────────────────────────────────────

    /**
     * Abre el picker de directorios del sistema para la carpeta de dynos.
     */
    private fun openDynosPicker(result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        pendingDynosPickerResult = result

        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                )
            }
            act.startActivityForResult(intent, REQUEST_CODE_DYNOS_TREE)
        } catch (e: Exception) {
            pendingDynosPickerResult = null
            result.error("PICKER_ERROR", "Failed to open DynOS directory picker: ${e.message}", null)
        }
    }

    /**
     * Devuelve la URI del directorio dynos guardado, o null.
     */
    private fun getSavedDynosUri(result: Result) {
        val prefs = getPrefs()
        val uriString = prefs.getString(KEY_DYNOS_TREE_URI, null)
        if (uriString != null) {
            val uri = Uri.parse(uriString)
            if (isTreeAccessible(uri)) {
                result.success(uriString)
            } else {
                prefs.edit().remove(KEY_DYNOS_TREE_URI).apply()
                result.success(null)
            }
        } else {
            result.success(null)
        }
    }

    /**
     * Verifica si ya hay un directorio dynos seleccionado.
     */
    private fun isDynosDirectorySelected(result: Result) {
        val prefs = getPrefs()
        val uriString = prefs.getString(KEY_DYNOS_TREE_URI, null)
        if (uriString != null) {
            val uri = Uri.parse(uriString)
            result.success(isTreeAccessible(uri))
        } else {
            result.success(false)
        }
    }

    /**
     * Copia un archivo local al directorio SAF de dynos.
     */
    private fun copyFileToDynosFolder(call: MethodCall, result: Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        val prefs = getPrefs()
        val treeUriString = prefs.getString(KEY_DYNOS_TREE_URI, null)
        if (treeUriString == null) {
            result.error("NO_DIRECTORY", "No DynOS directory selected.", null)
            return
        }

        val treeUri = Uri.parse(treeUriString)
        if (!isTreeAccessible(treeUri)) {
            prefs.edit().remove(KEY_DYNOS_TREE_URI).apply()
            result.error("DIR_NOT_ACCESSIBLE", "The selected DynOS directory is no longer accessible.", null)
            return
        }

        val sourcePath = call.argument<String>("sourcePath")
        val targetName = call.argument<String>("targetName")
        if (sourcePath == null || targetName == null) {
            result.error("INVALID_ARGS", "sourcePath and targetName are required", null)
            return
        }

        val sourceFile = java.io.File(sourcePath)
        if (!sourceFile.exists()) {
            result.error("FILE_NOT_FOUND", "Source file not found: $sourcePath", null)
            return
        }

        try {
            val treeDoc = DocumentFile.fromTreeUri(act, treeUri)
                ?: throw java.io.IOException("Could not access the selected DynOS directory tree.")

            val outputFile = treeDoc.createFile("application/octet-stream", targetName)
                ?: throw java.io.IOException("Failed to create file in DynOS SAF directory.")

            act.contentResolver.openOutputStream(outputFile.uri)?.use { os ->
                sourceFile.inputStream().use { input ->
                    input.copyTo(os)
                }
                os.flush()
            }

            sourceFile.delete()
            result.success(true)
        } catch (e: Exception) {
            result.error("COPY_ERROR", e.message ?: "Failed to copy file to DynOS folder", null)
        }
    }

    /**
     * Limpia la selección de directorio dynos (revoca permisos).
     */
    private fun clearDynosSelection(result: Result) {
        val prefs = getPrefs()
        val uriString = prefs.getString(KEY_DYNOS_TREE_URI, null)
        if (uriString != null) {
            try {
                val uri = Uri.parse(uriString)
                val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                activity?.contentResolver?.releasePersistableUriPermission(uri, flags)
            } catch (_: Exception) { }
        }
        prefs.edit().remove(KEY_DYNOS_TREE_URI).apply()
        result.success(true)
    }

    /**
     * Procesa el resultado del picker de directorios dynos.
     */
    private fun handleDynosTreeResult(resultCode: Int, data: Intent?) {
        val result = pendingDynosPickerResult ?: return
        pendingDynosPickerResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        val treeUri = data.data!!

        try {
            val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            activity?.contentResolver?.takePersistableUriPermission(treeUri, takeFlags)

            getPrefs().edit().putString(KEY_DYNOS_TREE_URI, treeUri.toString()).apply()

            result.success(treeUri.toString())
        } catch (e: Exception) {
            result.error("PERSIST_ERROR", "Failed to persist DynOS directory permission: ${e.message}", null)
        }
    }

    // ── EventChannel helper ────────────────────────────────────────────────

    private fun sendEvent(data: Map<String, Any?>) {
        val dead = mutableListOf<EventChannel.EventSink>()
        for (sink in eventSinks) {
            try {
                sink.success(data)
            } catch (_: Exception) {
                dead.add(sink)
            }
        }
        eventSinks.removeAll(dead)
    }

    private fun cleanupObservers() {
        val wm = activity?.let { WorkManager.getInstance(it) } ?: return
        for ((workId, observer) in workObservers) {
            try {
                wm.getWorkInfoByIdLiveData(workId).removeObserver(observer)
            } catch (_: Exception) { }
        }
        workObservers.clear()
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
        val result = pendingModPickerResult ?: return
        pendingModPickerResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        val treeUri = data.data!!

        try {
            val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            activity?.contentResolver?.takePersistableUriPermission(treeUri, takeFlags)

            getPrefs().edit().putString(KEY_TREE_URI, treeUri.toString()).apply()

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

}

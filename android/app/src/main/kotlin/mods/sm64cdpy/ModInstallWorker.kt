package mods.sm64cdpy

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.documentfile.provider.DocumentFile
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import androidx.work.CoroutineWorker
import java.io.File
import kotlinx.coroutines.CancellationException

class ModInstallWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        const val KEY_ZIP_PATH = "zipPath"
        const val KEY_MOD_NAME = "modName"
        const val KEY_DISPLAY_TITLE = "displayTitle"
        const val KEY_NOTIFICATION_TITLE = "notificationTitle"
        const val KEY_TREE_URI = "treeUri"
        const val KEY_INSTALL_DESTINATION = "installDestination"
        const val CHANNEL_ID = "mod_install_channel"
        const val RESULT_CHANNEL_ID = "mod_install_results_v1"

        const val PROGRESS_CURRENT = "current"
        const val PROGRESS_TOTAL = "total"
        const val OUTPUT_FILE_COUNT = "fileCount"
        const val OUTPUT_TARGET_DIR = "targetDir"
        const val OUTPUT_RECEIPT_FILE = "receiptFile"
        const val OUTPUT_INSTALL_EVENT_KIND = "installEventKind"

        /**
         * En Android 14 (API 34) es obligatorio declarar el foregroundServiceType
         * al promover un Worker a servicio en primer plano; si se omite, el
         * sistema mata el proceso con InvalidForegroundServiceTypeException.
         */
        fun buildForegroundInfo(notificationId: Int, notification: Notification): ForegroundInfo {
            return ForegroundInfo(
                notificationId,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        }
    }

    private val notificationId: Int by lazy {
        id.hashCode() and 0x7FFFFFFF
    }

    override suspend fun doWork(): Result {
        // Phase 2 will use this validated metadata to write the durable
        // receipt. Reading it now verifies that it reached the install Worker.
        val identity = try {
            InstallIdentityMetadata.fromData(inputData)
        } catch (e: IllegalArgumentException) {
            return Result.failure(workDataOf("error" to (e.message ?: "Invalid install identity")))
        }
        val destination = inputData.getString(KEY_INSTALL_DESTINATION) ?: "mods"
        val zipPath = inputData.getString(KEY_ZIP_PATH) ?: return Result.failure()
        val modName = inputData.getString(KEY_MOD_NAME) ?: return Result.failure()
        val displayTitle = inputData.getString(KEY_DISPLAY_TITLE) ?: modName
        val notificationTitle = inputData.getString(KEY_NOTIFICATION_TITLE) ?: displayTitle
        val treeUriString = inputData.getString(KEY_TREE_URI) ?: return Result.failure()

        val treeUri = Uri.parse(treeUriString)
        val zipFile = File(zipPath)

        if (!zipFile.exists()) {
            return Result.failure(
                workDataOf("error" to "ZIP file not found: $zipPath")
            )
        }

        val treeDoc = DocumentFile.fromTreeUri(applicationContext, treeUri)
        if (treeDoc == null) {
            deleteSource(zipFile)
            return Result.failure(
                workDataOf("error" to "Could not access the selected directory tree.")
            )
        }

        val writeJournal = SafZipExtractor.WriteJournal()

        try {
            // El archivo descargado no siempre es un ZIP (ej. mods sueltos en .lua,
            // o .7z para packs de texturas grandes como Render96 HD).
            if (!isZipFile(zipFile) && !SafZipExtractor.isSevenZipFile(zipFile)) {
                setForeground(
                    buildForegroundInfo(notificationId, buildNotification(displayTitle, 0, 0, true))
                )

                val manifest = SafZipExtractor.copyFileToTree(
                    zipFile, treeDoc, applicationContext, writeJournal
                )
                if (manifest == null) {
                    writeJournal.rollback(treeDoc)
                    deleteSource(zipFile)
                    return Result.failure(
                        workDataOf(
                            "error" to "Could not copy file to the selected directory."
                        )
                    )
                }

                return completeInstallation(
                    source = zipFile,
                    identity = identity,
                    destination = destination,
                    displayTitle = displayTitle,
                    notificationTitle = notificationTitle,
                    manifest = manifest,
                    targetDir = "",
                    treeDoc = treeDoc,
                    writeJournal = writeJournal
                )
            }

            // ── 7z extraction (SevenZFile, Apache Commons Compress) ──────────
            if (SafZipExtractor.isSevenZipFile(zipFile)) {
                // Pre-pase de solo metadata para conocer el total de bytes de
                // TODO el archivo — mismo patrón que countZipEntries() para el
                // path de ZIP. Antes no existía: el progreso se calculaba solo
                // sobre la entrada individual en curso, que se reinicia con
                // cada archivo nuevo del .7z y rompía el throttle de abajo en
                // cuanto el primer archivo llegaba a 100% (ver comentario en
                // SafZipExtractor.extractSevenZToTree).
                val totalBytes = SafZipExtractor.countSevenZTotalBytes(zipFile)
                val indeterminate = totalBytes <= 0

                setForeground(
                    buildForegroundInfo(
                        notificationId,
                        buildNotification(modName, 0, 100, indeterminate)
                    )
                )

                var lastProgress = 0
                val manifest = SafZipExtractor.extractSevenZToTree(
                    zipFile, treeDoc, applicationContext, totalBytes, writeJournal
                ) { pct ->
                    // Throttle: notifica cada cambio ≥10%. Ahora pct es el
                    // porcentaje REAL sobre todo el archivo (monótono
                    // creciente 0→100 una sola vez por toda la extracción),
                    // no por-archivo-individual, así que este umbral ya no
                    // se queda varado a mitad de la extracción.
                    if (!indeterminate && pct - lastProgress >= 10) {
                        lastProgress = pct
                        setProgress(
                            workDataOf(
                                PROGRESS_CURRENT to pct,
                                PROGRESS_TOTAL to 100
                            )
                        )
                        setForeground(
                            buildForegroundInfo(
                                notificationId,
                                buildNotification(modName, pct, 100, false)
                            )
                        )
                    }
                }

                if (manifest.fileCount == 0) {
                    writeJournal.rollback(treeDoc)
                    deleteSource(zipFile)
                    return Result.failure(
                        workDataOf(
                            "error" to "No files were extracted. The downloaded 7z file may be invalid."
                        )
                    )
                }

                setProgress(
                    workDataOf(
                        PROGRESS_CURRENT to 100,
                        PROGRESS_TOTAL to 100
                    )
                )
                setForeground(
                    buildForegroundInfo(notificationId, buildNotification(modName, 100, 100, false))
                )

                return completeInstallation(
                    source = zipFile,
                    identity = identity,
                    destination = destination,
                    displayTitle = displayTitle,
                    notificationTitle = notificationTitle,
                    manifest = manifest,
                    targetDir = displayTitle,
                    treeDoc = treeDoc,
                    writeJournal = writeJournal
                )
            }

            // ── ZIP extraction (ZipInputStream) ───────────────────────────────
            val totalEntries = SafZipExtractor.countZipEntries(zipFile)
            val indeterminate = totalEntries <= 0

            setForeground(
                buildForegroundInfo(notificationId, buildNotification(modName, 0, totalEntries, indeterminate))
            )

            var lastProgress = 0
            val manifest = SafZipExtractor.extractZipToTree(
                zipFile, treeDoc, applicationContext, writeJournal
            ) { count ->
                if (!indeterminate && count - lastProgress >= 3) {
                    lastProgress = count
                    setProgress(
                        workDataOf(
                            PROGRESS_CURRENT to count,
                            PROGRESS_TOTAL to totalEntries
                        )
                    )
                    setForeground(
                        buildForegroundInfo(
                            notificationId,
                            buildNotification(modName, count, totalEntries, false)
                        )
                    )
                }
            }

            // Flush final de progreso (antes vivía al final de
            // extractWithProgress): garantiza que la barra llegue al total
            // real aunque el último tramo haya sido menor al umbral de
            // 3 archivos del throttling.
            if (!indeterminate && lastProgress < manifest.fileCount) {
                setProgress(
                    workDataOf(
                        PROGRESS_CURRENT to manifest.fileCount,
                        PROGRESS_TOTAL to totalEntries
                    )
                )
                setForeground(
                    buildForegroundInfo(notificationId, buildNotification(modName, manifest.fileCount, totalEntries, false))
                )
            }

            val topDir = SafZipExtractor.detectTopLevelDir(zipFile)
            val displayDir = topDir ?: displayTitle

            if (manifest.fileCount == 0) {
                writeJournal.rollback(treeDoc)
                deleteSource(zipFile)
                return Result.failure(
                    workDataOf(
                        "error" to "No files were extracted. The downloaded file may not be a valid ZIP archive."
                    )
                )
            }

            return completeInstallation(
                source = zipFile,
                identity = identity,
                destination = destination,
                displayTitle = displayTitle,
                notificationTitle = notificationTitle,
                manifest = manifest,
                targetDir = displayDir,
                treeDoc = treeDoc,
                writeJournal = writeJournal
            )
        } catch (e: CancellationException) {
            writeJournal.rollback(treeDoc)
            deleteSource(zipFile)
            throw e
        } catch (e: SecurityException) {
            // El permiso persistente sobre el árbol SAF puede ser revocado por
            // el sistema (limpieza de storage, reinstalación de la app, o el
            // usuario cambiándolo en Ajustes) sin que la app se entere hasta
            // que intenta escribir. Sin este catch específico caía en el
            // genérico de abajo con un e.message poco útil ("Permission
            // denied") que no le dice al usuario qué hacer.
            writeJournal.rollback(treeDoc)
            deleteSource(zipFile)
            return Result.failure(
                workDataOf(
                    "error" to "Lost access to the selected mods folder. Please re-select it in Settings."
                )
            )
        } catch (e: Exception) {
            writeJournal.rollback(treeDoc)
            deleteSource(zipFile)
            return Result.failure(
                workDataOf("error" to (e.message ?: "Unknown error during installation"))
            )
        }
    }

    private fun completeInstallation(
        source: File,
        identity: InstallIdentityMetadata?,
        destination: String,
        displayTitle: String,
        notificationTitle: String,
        manifest: SafZipExtractor.WriteManifest,
        targetDir: String,
        treeDoc: DocumentFile,
        writeJournal: SafZipExtractor.WriteJournal
    ): Result {
        if (isStopped) {
            writeJournal.rollback(treeDoc)
            deleteSource(source)
            return Result.failure(workDataOf("error" to "Installation was cancelled"))
        }

        val receipt = if (identity != null) {
            try {
                InstallationReceiptStore.writeConfirmed(
                    context = applicationContext,
                    identity = identity,
                    destination = destination,
                    displayTitle = displayTitle,
                    installWorkerId = id.toString(),
                    manifest = manifest
                )
            } catch (error: Exception) {
                writeJournal.rollback(treeDoc)
                deleteSource(source)
                return Result.failure(
                    workDataOf(
                        "error" to (error.message
                            ?: "Files were copied, but the installation receipt could not be saved")
                    )
                )
            }
        } else {
            // Compatibility only for a Worker enqueued by an older app build.
            // A legacy title is not enough to fabricate a durable identity.
            null
        }

        if (isStopped) {
            receipt?.let {
                try {
                    InstallationReceiptStore.rollbackIfCurrent(applicationContext, it)
                } catch (_: Exception) {
                    // WorkManager remains cancelled. A later repository read can
                    // quarantine any receipt that cannot be rolled back safely.
                }
            }
            writeJournal.rollback(treeDoc)
            deleteSource(source)
            return Result.failure(workDataOf("error" to "Installation was cancelled"))
        }

        deleteSource(source)
        showCompletionNotification(notificationTitle)
        return Result.success(
            workDataOf(
                OUTPUT_FILE_COUNT to manifest.fileCount,
                OUTPUT_TARGET_DIR to targetDir,
                OUTPUT_RECEIPT_FILE to receipt?.receiptFileName,
                OUTPUT_INSTALL_EVENT_KIND to receipt?.eventKind
            )
        )
    }

    private fun deleteSource(file: File) {
        file.delete()
        val parent = file.parentFile
        if (parent?.parentFile?.name == "mod_downloads") parent.delete()
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        val ctx = applicationContext
        return buildForegroundInfo(
            notificationId,
            buildNotification(ctx.getString(R.string.notification_preparing), 0, 0, true)
        )
    }

    private fun buildNotification(
        modName: String,
        current: Int,
        total: Int,
        indeterminate: Boolean
    ): Notification {
        val ctx = applicationContext
        val contentText = if (indeterminate) {
            ctx.getString(R.string.notification_extracting, modName)
        } else {
            ctx.getString(R.string.notification_extracting_progress, modName, current, total)
        }

        val cancelIntent = WorkManager.getInstance(applicationContext)
            .createCancelPendingIntent(id)

        return NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_sm64cdpy)
            .setContentTitle(ctx.getString(R.string.notification_installing_mod))
            .setContentText(contentText)
            .setOngoing(true)
            .setProgress(total, current, indeterminate)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .addAction(android.R.drawable.ic_delete, ctx.getString(R.string.notification_cancel), cancelIntent)
            .build()
    }

    private fun showCompletionNotification(modName: String) {
        val openAppIntent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentIntent = PendingIntent.getActivity(
            applicationContext,
            notificationId,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notification = NotificationCompat.Builder(applicationContext, RESULT_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_sm64cdpy)
            .setContentTitle(applicationContext.getString(R.string.notification_install_complete))
            .setContentText(modName)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .setOngoing(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .build()
        try {
            // ID distinto al foreground: WorkManager retira su notificación al
            // terminar el Worker, pero no debe borrar la confirmación final.
            NotificationManagerCompat.from(applicationContext)
                .notify(notificationId xor 0x40000000, notification)
        } catch (_: SecurityException) {
            // POST_NOTIFICATIONS puede estar denegado; Flutter sigue mostrando
            // el resultado cuando la interfaz está visible.
        }
    }

    /**
     * Determina si el archivo descargado es realmente un ZIP en base a su
     * extensión. No basta con confiar en que "vino del instalador de mods":
     * el mismo Worker recibe tanto ZIPs como archivos sueltos (ej. .lua).
     */
    private fun isZipFile(file: File): Boolean {
        return file.extension.equals("zip", ignoreCase = true)
    }

}

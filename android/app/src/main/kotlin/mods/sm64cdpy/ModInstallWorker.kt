package mods.sm64cdpy

import android.app.Notification
import android.content.Context
import android.content.pm.ServiceInfo
import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.app.NotificationCompat
import androidx.documentfile.provider.DocumentFile
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import androidx.work.CoroutineWorker
import java.io.File

class ModInstallWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        const val KEY_ZIP_PATH = "zipPath"
        const val KEY_MOD_NAME = "modName"
        const val KEY_TREE_URI = "treeUri"
        const val CHANNEL_ID = "mod_install_channel"

        const val PROGRESS_CURRENT = "current"
        const val PROGRESS_TOTAL = "total"
        const val OUTPUT_FILE_COUNT = "fileCount"
        const val OUTPUT_TARGET_DIR = "targetDir"

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
        (inputData.getString(KEY_MOD_NAME) ?: "").hashCode() and 0x7FFFFFFF
    }

    override suspend fun doWork(): Result {
        val zipPath = inputData.getString(KEY_ZIP_PATH) ?: return Result.failure()
        val modName = inputData.getString(KEY_MOD_NAME) ?: return Result.failure()
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
            return Result.failure(
                workDataOf("error" to "Could not access the selected directory tree.")
            )
        }

        try {
            // El archivo descargado no siempre es un ZIP (ej. mods sueltos en .lua,
            // o .7z para packs de texturas grandes como Render96 HD).
            if (!isZipFile(zipFile) && !SafZipExtractor.isSevenZipFile(zipFile)) {
                setForeground(
                    buildForegroundInfo(notificationId, buildNotification(modName, 0, 0, true))
                )

                val copied = SafZipExtractor.copyFileToTree(zipFile, treeDoc, applicationContext)
                if (!copied) {
                    return Result.failure(
                        workDataOf(
                            "error" to "Could not copy file to the selected directory."
                        )
                    )
                }

                zipFile.delete()

                return Result.success(
                    workDataOf(
                        OUTPUT_FILE_COUNT to 1,
                        OUTPUT_TARGET_DIR to ""
                    )
                )
            }

            // ── 7z extraction (SevenZFile, Apache Commons Compress) ──────────
            if (SafZipExtractor.isSevenZipFile(zipFile)) {
                setForeground(
                    buildForegroundInfo(notificationId, buildNotification(modName, 0, 0, true))
                )

                var lastProgress = 0
                val fileCount = SafZipExtractor.extractSevenZToTree(
                    zipFile, treeDoc, applicationContext
                ) { pct ->
                    // Throttle: notifica cada cambio ≥10%
                    if (pct - lastProgress >= 10) {
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

                if (fileCount == 0) {
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

                zipFile.delete()

                return Result.success(
                    workDataOf(
                        OUTPUT_FILE_COUNT to fileCount,
                        OUTPUT_TARGET_DIR to modName
                    )
                )
            }

            // ── ZIP extraction (ZipInputStream) ───────────────────────────────
            val totalEntries = SafZipExtractor.countZipEntries(zipFile)
            val indeterminate = totalEntries <= 0

            setForeground(
                buildForegroundInfo(notificationId, buildNotification(modName, 0, totalEntries, indeterminate))
            )

            var lastProgress = 0
            val fileCount = SafZipExtractor.extractZipToTree(
                zipFile, treeDoc, applicationContext
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
            if (!indeterminate && lastProgress < fileCount) {
                setProgress(
                    workDataOf(
                        PROGRESS_CURRENT to fileCount,
                        PROGRESS_TOTAL to totalEntries
                    )
                )
                setForeground(
                    buildForegroundInfo(notificationId, buildNotification(modName, fileCount, totalEntries, false))
                )
            }

            val topDir = SafZipExtractor.detectTopLevelDir(zipFile)
            val displayDir = topDir ?: modName

            if (fileCount == 0) {
                return Result.failure(
                    workDataOf(
                        "error" to "No files were extracted. The downloaded file may not be a valid ZIP archive."
                    )
                )
            }

            zipFile.delete()

            return Result.success(
                workDataOf(
                    OUTPUT_FILE_COUNT to fileCount,
                    OUTPUT_TARGET_DIR to displayDir
                )
            )
        } catch (e: SecurityException) {
            // El permiso persistente sobre el árbol SAF puede ser revocado por
            // el sistema (limpieza de storage, reinstalación de la app, o el
            // usuario cambiándolo en Ajustes) sin que la app se entere hasta
            // que intenta escribir. Sin este catch específico caía en el
            // genérico de abajo con un e.message poco útil ("Permission
            // denied") que no le dice al usuario qué hacer.
            return Result.failure(
                workDataOf(
                    "error" to "Lost access to the selected mods folder. Please re-select it in Settings."
                )
            )
        } catch (e: Exception) {
            return Result.failure(
                workDataOf("error" to (e.message ?: "Unknown error during installation"))
            )
        }
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
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle(ctx.getString(R.string.notification_installing_mod))
            .setContentText(contentText)
            .setOngoing(true)
            .setProgress(total, current, indeterminate)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .addAction(android.R.drawable.ic_delete, ctx.getString(R.string.notification_cancel), cancelIntent)
            .build()
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

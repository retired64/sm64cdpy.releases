package mods.sm64cdpy

import android.app.Notification
import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL

class ModDownloadWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        const val KEY_URL = "url"
        const val KEY_MOD_NAME = "modName"
        const val KEY_FILE_NAME = "fileName"
        const val DOWNLOAD_CHANNEL_ID = "mod_download_channel"
        const val NOTIFICATION_ID = 4243
        const val PROGRESS = "progress"
        const val OUTPUT_ZIP_PATH = "zipPath"
    }

    override suspend fun doWork(): Result {
        val url = inputData.getString(KEY_URL) ?: return Result.failure()
        val modName = inputData.getString(KEY_MOD_NAME) ?: return Result.failure()
        val fileName = inputData.getString(KEY_FILE_NAME) ?: return Result.failure()

        setForeground(
            ForegroundInfo(
                NOTIFICATION_ID,
                buildNotification(modName, 0, true)
            )
        )

        val outputFile = File(applicationContext.cacheDir, fileName)
        outputFile.parentFile?.mkdirs()

        try {
            downloadFile(url, outputFile, modName)

            if (isStopped) {
                outputFile.delete()
                return Result.failure()
            }

            setProgress(workDataOf(PROGRESS to 100))

            setForeground(
                ForegroundInfo(
                    NOTIFICATION_ID,
                    buildNotification(modName, null, null)
                )
            )

            return Result.success(
                workDataOf(OUTPUT_ZIP_PATH to outputFile.absolutePath)
            )
        } catch (e: Exception) {
            outputFile.delete()
            if (isStopped) return Result.failure()
            return Result.retry()
        }
    }

    private suspend fun downloadFile(urlStr: String, outputFile: File, modName: String) {
        var connection: HttpURLConnection? = null
        var inputStream: BufferedInputStream? = null
        var outputStream: FileOutputStream? = null
        var lastUpdateTime = 0L

        try {
            val url = URL(urlStr)
            connection = url.openConnection() as HttpURLConnection
            connection.instanceFollowRedirects = true
            connection.connectTimeout = 15000
            connection.readTimeout = 30000
            connection.setRequestProperty("Accept-Encoding", "identity")
            connection.connect()

            if (connection.responseCode in 300..399) {
                val redirectUrl = connection.getHeaderField("Location")
                connection.disconnect()
                if (redirectUrl != null) {
                    connection = URL(redirectUrl).openConnection() as HttpURLConnection
                    connection.instanceFollowRedirects = false
                    connection.connectTimeout = 15000
                    connection.readTimeout = 30000
                    connection.connect()
                }
            }

            val contentLength = connection.contentLength
            val total = if (contentLength > 0) contentLength else -1
            var downloaded = 0L

            inputStream = BufferedInputStream(connection.inputStream)
            outputStream = FileOutputStream(outputFile)

            val buffer = ByteArray(8192)
            var bytesRead: Int

            while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                if (isStopped) {
                    return
                }

                outputStream.write(buffer, 0, bytesRead)
                downloaded += bytesRead

                val now = System.currentTimeMillis()
                if (now - lastUpdateTime >= 500) {
                    lastUpdateTime = now

                    if (total > 0) {
                        val pct = (downloaded * 100 / total).toInt()
                        setProgress(workDataOf(PROGRESS to pct))
                        setForeground(
                            ForegroundInfo(
                                NOTIFICATION_ID,
                                buildNotification(modName, pct, null)
                            )
                        )
                    }
                }
            }

            outputStream.flush()
        } finally {
            inputStream?.close()
            outputStream?.close()
            connection?.disconnect()
        }
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        return ForegroundInfo(
            NOTIFICATION_ID,
            buildNotification(null, 0, true)
        )
    }

    private fun buildNotification(
        modName: String?,
        progressPct: Int?,
        indeterminate: Boolean?
    ): Notification {
        val title = "Downloading mod"
        val text = if (modName != null && progressPct != null) {
            "$modName · $progressPct%"
        } else if (modName != null) {
            modName
        } else {
            "Preparing download..."
        }

        val isIndeterminate = indeterminate ?: (progressPct == null)

        val cancelIntent = WorkManager.getInstance(applicationContext)
            .createCancelPendingIntent(id)

        return NotificationCompat.Builder(applicationContext, DOWNLOAD_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setProgress(100, progressPct ?: 0, isIndeterminate)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .addAction(android.R.drawable.ic_delete, "Cancel", cancelIntent)
            .build()
    }
}

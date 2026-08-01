package mods.sm64cdpy

import android.app.Notification
import android.content.Context
import android.content.pm.ServiceInfo
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
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

        /** Tras esta cantidad de reintentos de WorkManager, dejamos de reintentar. */
        private const val MAX_RETRY_ATTEMPTS = 5

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

    /** Errores de servidor que NO tiene sentido reintentar (4xx: URL rota, mod eliminado, etc.). */
    private class PermanentDownloadError(message: String) : IOException(message)

    override suspend fun doWork(): Result {
        val url = inputData.getString(KEY_URL) ?: return Result.failure()
        val modName = inputData.getString(KEY_MOD_NAME) ?: return Result.failure()
        val fileName = inputData.getString(KEY_FILE_NAME) ?: return Result.failure()

        val outputFile = File(applicationContext.cacheDir, fileName)
        outputFile.parentFile?.mkdirs()

        try {
            // OJO: antes esta llamada vivía ANTES del try/catch. Si el sistema
            // rechazaba la promoción a primer plano (p.ej. Android 14 sin el
            // foregroundServiceType correcto), la excepción no tenía ninguna
            // red de seguridad y tumbaba el proceso completo. Ahora vive
            // adentro, y además ya declaramos el tipo correcto abajo.
            setForeground(
                buildForegroundInfo(NOTIFICATION_ID, buildNotification(modName, 0, true))
            )

            downloadFile(url, outputFile, modName)

            if (isStopped) {
                outputFile.delete()
                return Result.failure()
            }

            setProgress(workDataOf(PROGRESS to 100))

            setForeground(
                buildForegroundInfo(NOTIFICATION_ID, buildNotification(modName, null, null))
            )

            return Result.success(
                workDataOf(OUTPUT_ZIP_PATH to outputFile.absolutePath)
            )
        } catch (e: PermanentDownloadError) {
            // 4xx / URL inválida: reintentar no va a arreglar nada, y dejar
            // el work en retry infinito solo gasta batería y datos del usuario.
            outputFile.delete()
            return Result.failure(workDataOf("error" to (e.message ?: "Download failed")))
        } catch (e: Exception) {
            outputFile.delete()
            if (isStopped) return Result.failure()

            // Reintentos con techo: sin esto, un error transitorio persistente
            // (servidor caído, DNS fallando) reintenta indefinidamente en
            // background. runAttemptCount es 0-indexed la primera vez.
            return if (runAttemptCount + 1 >= MAX_RETRY_ATTEMPTS) {
                Result.failure(
                    workDataOf(
                        "error" to "Download failed after $MAX_RETRY_ATTEMPTS attempts: ${e.message}"
                    )
                )
            } else {
                Result.retry()
            }
        }
    }

    private suspend fun downloadFile(urlStr: String, outputFile: File, modName: String) {
        var connection: HttpURLConnection? = null
        var inputStream: BufferedInputStream? = null
        var outputStream: FileOutputStream? = null
        var lastUpdateTime = 0L

        try {
            val url = URL(urlStr)
            var httpConn = url.openConnection() as HttpURLConnection
            httpConn.instanceFollowRedirects = false
            httpConn.connectTimeout = 15000
            httpConn.readTimeout = 30000
            httpConn.setRequestProperty("Accept-Encoding", "identity")

            var redirectsLeft = 5
            while (redirectsLeft > 0 && httpConn.responseCode in 300..399) {
                val redirectUrl = httpConn.getHeaderField("Location")
                httpConn.disconnect()
                if (redirectUrl == null) break
                httpConn = URL(redirectUrl).openConnection() as HttpURLConnection
                httpConn.instanceFollowRedirects = false
                httpConn.connectTimeout = 15000
                httpConn.readTimeout = 30000
                httpConn.setRequestProperty("Accept-Encoding", "identity")
                httpConn.connect()
                redirectsLeft--
            }
            connection = httpConn

            val responseCode = httpConn.responseCode
            if (responseCode in 400..499) {
                // 404/403/410, etc: el asset no existe o no es accesible.
                // Reintentar no cambia el resultado — falla permanente.
                throw PermanentDownloadError("Server returned HTTP $responseCode for $urlStr")
            }
            if (responseCode !in 200..299) {
                throw IOException("Server returned HTTP $responseCode for $urlStr")
            }

            val contentLength = httpConn.contentLength
            val total = if (contentLength > 0) contentLength else -1
            var downloaded = 0L

            inputStream = BufferedInputStream(httpConn.inputStream)
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
                            buildForegroundInfo(NOTIFICATION_ID, buildNotification(modName, pct, null))
                        )
                    }
                }
            }

            outputStream.flush()

            // El servidor puede cerrar la conexión antes de tiempo (proxy,
            // timeout de red, etc.) sin que read() lance excepción — solo
            // devuelve -1 antes de lo esperado. Sin esta validación, un
            // ZIP truncado pasa como "descarga exitosa" y falla recién en
            // el ModInstallWorker con un mensaje confuso.
            if (total > 0 && downloaded != total.toLong()) {
                throw IOException(
                    "Truncated download: got $downloaded of $total bytes"
                )
            }
        } finally {
            inputStream?.close()
            outputStream?.close()
            connection?.disconnect()
        }
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        return buildForegroundInfo(NOTIFICATION_ID, buildNotification(null, 0, true))
    }

    private fun buildNotification(
        modName: String?,
        progressPct: Int?,
        indeterminate: Boolean?
    ): Notification {
        val ctx = applicationContext
        val title = ctx.getString(R.string.notification_downloading_mod)
        val text = if (modName != null && progressPct != null) {
            ctx.getString(R.string.notification_downloading_progress, modName, progressPct)
        } else if (modName != null) {
            modName
        } else {
            ctx.getString(R.string.notification_preparing_download)
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
            .addAction(android.R.drawable.ic_delete, ctx.getString(R.string.notification_cancel), cancelIntent)
            .build()
    }
}

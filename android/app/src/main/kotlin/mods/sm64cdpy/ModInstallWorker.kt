package mods.sm64cdpy

import android.app.Notification
import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.app.NotificationCompat
import androidx.documentfile.provider.DocumentFile
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import androidx.work.CoroutineWorker
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream

class ModInstallWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        const val KEY_ZIP_PATH = "zipPath"
        const val KEY_MOD_NAME = "modName"
        const val KEY_TREE_URI = "treeUri"
        const val NOTIFICATION_ID = 4242
        const val CHANNEL_ID = "mod_install_channel"

        const val PROGRESS_CURRENT = "current"
        const val PROGRESS_TOTAL = "total"
        const val OUTPUT_FILE_COUNT = "fileCount"
        const val OUTPUT_TARGET_DIR = "targetDir"
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
            val totalEntries = countZipEntries(zipFile)
            val indeterminate = totalEntries <= 0

            setForeground(
                ForegroundInfo(
                    NOTIFICATION_ID,
                    buildNotification(modName, 0, totalEntries, indeterminate)
                )
            )

            val fileCount = extractWithProgress(zipFile, treeDoc, modName, totalEntries)
            val topDir = detectTopLevelDir(zipFile)
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
        } catch (e: Exception) {
            return Result.failure(
                workDataOf("error" to (e.message ?: "Unknown error during installation"))
            )
        }
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        return ForegroundInfo(
            NOTIFICATION_ID,
            buildNotification("Preparing...", 0, 0, true)
        )
    }

    private fun buildNotification(
        modName: String,
        current: Int,
        total: Int,
        indeterminate: Boolean
    ): Notification {
        val contentText = if (indeterminate) {
            "Extracting $modName..."
        } else {
            "Extracting $modName · $current/$total files"
        }

        val cancelIntent = WorkManager.getInstance(applicationContext)
            .createCancelPendingIntent(id)

        return NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle("Installing mod")
            .setContentText(contentText)
            .setOngoing(true)
            .setProgress(total, current, indeterminate)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .addAction(android.R.drawable.ic_delete, "Cancel", cancelIntent)
            .build()
    }

    @Throws(IOException::class)
    private suspend fun extractWithProgress(
        zipFile: File,
        targetDir: DocumentFile,
        modName: String,
        totalEntries: Int
    ): Int {
        var fileCount = 0
        val createdDirs = mutableMapOf<String, DocumentFile>()
        var lastProgress = 0
        val indeterminate = totalEntries <= 0

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
                            val outputFile = parentDir.createFile(
                                "application/octet-stream", fileName
                            )
                            if (outputFile != null) {
                                applicationContext.contentResolver
                                    .openOutputStream(outputFile.uri)?.use { os ->
                                        zis.copyTo(os)
                                        os.flush()
                                    }
                                fileCount++

                                if (!indeterminate && fileCount - lastProgress >= 3) {
                                    lastProgress = fileCount
                                    setProgress(
                                        workDataOf(
                                            PROGRESS_CURRENT to fileCount,
                                            PROGRESS_TOTAL to totalEntries
                                        )
                                    )
                                    setForeground(
                                        ForegroundInfo(
                                            NOTIFICATION_ID,
                                            buildNotification(
                                                modName, fileCount, totalEntries, false
                                            )
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
                entry = zis.nextEntry
            }
        }

        if (!indeterminate && lastProgress < fileCount) {
            setProgress(
                workDataOf(
                    PROGRESS_CURRENT to fileCount,
                    PROGRESS_TOTAL to totalEntries
                )
            )
            setForeground(
                ForegroundInfo(
                    NOTIFICATION_ID,
                    buildNotification(modName, fileCount, totalEntries, false)
                )
            )
        }

        return fileCount
    }

    @Throws(IOException::class)
    private fun countZipEntries(zipFile: File): Int {
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

    private fun detectTopLevelDir(zipFile: File): String? {
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
        } catch (_: Exception) { }

        return commonPrefix
    }

    private fun sanitizeEntryName(name: String): String {
        var sanitized = name.trim()
        while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
        sanitized = sanitized.replace("../", "").replace("..\\", "")
        sanitized = sanitized.replace("\\", "/")
        sanitized = sanitized.replace("\u0000", "")
        return sanitized
    }
}

package mods.sm64cdpy

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ModInstallerPlugin())
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val installChannel = NotificationChannel(
                ModInstallWorker.CHANNEL_ID,
                "Mod Installation",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows progress while installing mods"
                setShowBadge(false)
            }

            val downloadChannel = NotificationChannel(
                ModDownloadWorker.DOWNLOAD_CHANNEL_ID,
                "Mod Downloads",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows progress while downloading mods"
                setShowBadge(false)
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(installChannel)
            manager.createNotificationChannel(downloadChannel)
        }
    }
}

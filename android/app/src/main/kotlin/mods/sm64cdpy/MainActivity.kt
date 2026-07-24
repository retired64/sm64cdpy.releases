package mods.sm64cdpy

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val GAME_PACKAGE = "com.maniscat2.sm64coopdx"
        private const val CHANNEL = "sm64cdpy/launcher"
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ModInstallerPlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isInstalled" -> {
                        try {
                            packageManager.getPackageInfo(GAME_PACKAGE, 0)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "launch" -> {
                        try {
                            val intent = packageManager.getLaunchIntentForPackage(GAME_PACKAGE)
                            if (intent != null) {
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val installChannel = NotificationChannel(
                ModInstallWorker.CHANNEL_ID,
                getString(R.string.channel_mod_installation),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.channel_mod_installation_desc)
                setShowBadge(false)
            }

            val downloadChannel = NotificationChannel(
                ModDownloadWorker.DOWNLOAD_CHANNEL_ID,
                getString(R.string.channel_mod_download),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.channel_mod_download_desc)
                setShowBadge(false)
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(installChannel)
            manager.createNotificationChannel(downloadChannel)
        }
    }
}

package mods.sm64cdpy

import android.content.Intent
import android.media.AudioManager
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
        // Los botones físicos ajustan el mismo volumen que los efectos del menú.
        // Esto elige el canal; no cambia ni fuerza el volumen del usuario.
        volumeControlStream = AudioManager.STREAM_MUSIC
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ModInstallerPlugin())
        flutterEngine.plugins.add(MarioAssetsPlugin())
        flutterEngine.plugins.add(Player3DPlugin())
        flutterEngine.plugins.add(RomPreparationPlugin())
        flutterEngine.plugins.add(MangaMenuAudioPlugin())
        flutterEngine.plugins.add(AmbientMusicPlugin())
        flutterEngine.plugins.add(CoopSessionPlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refreshNotificationLanguage" -> {
                        AppLanguage.refreshChannels(this)
                        result.success(null)
                    }
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
        AppLanguage.refreshChannels(this)
    }
}

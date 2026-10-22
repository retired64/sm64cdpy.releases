package mods.sm64cdpy

import android.media.AudioAttributes
import android.media.SoundPool
import android.os.SystemClock
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Efectos breves precargados por engine; nunca se reproduce audio al terminar una carga. */
class MangaMenuAudioPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var pool: SoundPool? = null
    private val samples = mutableMapOf<String, Int>()
    private val ready = java.util.concurrent.ConcurrentHashMap.newKeySet<Int>()
    private var lastPlay = 0L

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "sm64cdpy/manga_menu_audio").also {
            it.setMethodCallHandler(this)
        }
        val soundPool = SoundPool.Builder().setMaxStreams(1).setAudioAttributes(
            AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build()
        ).build()
        pool = soundPool
        soundPool.setOnLoadCompleteListener { _, id, status ->
            if (status == 0) ready.add(id)
        }
        for ((name, file) in mapOf("press" to "menu-button-press.wav", "slide" to "slide.mp3")) {
            try {
                val key = binding.flutterAssets.getAssetFilePathByName("assets/audio/manga/$file")
                binding.applicationContext.assets.openFd(key).use { descriptor ->
                    samples[name] = soundPool.load(descriptor, 1)
                }
            } catch (_: Exception) {
                // El menú sigue funcionando si falta un recurso o no puede decodificarse.
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "prepare" -> result.success(null)
            "stop" -> {
                pool?.autoPause()
                result.success(null)
            }
            "play" -> {
                val name = call.argument<String>("sound")
                val id = samples[name]
                val now = SystemClock.elapsedRealtime()
                if (id != null && ready.contains(id) && now - lastPlay >= 75) {
                    lastPlay = now
                    pool?.play(id, 0.65f, 0.65f, 1, 0, 1f)
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        pool?.setOnLoadCompleteListener(null)
        pool?.release()
        pool = null
        samples.clear()
        ready.clear()
    }
}

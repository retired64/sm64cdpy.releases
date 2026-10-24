package mods.sm64cdpy

import android.media.AudioAttributes
import android.media.SoundPool
import android.os.SystemClock
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Efectos breves precargados por engine; nunca se reproduce audio al terminar una carga. */
class MangaMenuAudioPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var pool: SoundPool? = null
    private val samples = mutableMapOf<String, Int>()
    private val ready = java.util.concurrent.ConcurrentHashMap.newKeySet<Int>()
    private val streams = mutableMapOf<String, Int>()
    private var lastPlay = 0L

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "sm64cdpy/manga_menu_audio").also {
            it.setMethodCallHandler(this)
        }
        val soundPool = SoundPool.Builder().setMaxStreams(1).setAudioAttributes(
            AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build()
        ).build()
        pool = soundPool
        soundPool.setOnLoadCompleteListener { _, id, status ->
            if (status == 0) {
                ready.add(id)
                Log.d("MangaMenuAudio", "Sample preparado: $id")
            } else {
                Log.w("MangaMenuAudio", "No se pudo decodificar sample $id: $status")
            }
        }
        for ((name, file) in mapOf(
            "press" to "menu-button-press.wav",
            "slide" to "slide.mp3",
            "home_slide" to "home-cards-slide.mp3",
        )) {
            try {
                val key = binding.flutterAssets.getAssetFilePathByName("assets/audio/manga/$file")
                binding.applicationContext.assets.openFd(key).use { descriptor ->
                    val id = soundPool.load(descriptor, 1)
                    if (id != 0) {
                        samples[name] = id
                    } else {
                        Log.w("MangaMenuAudio", "SoundPool rechazó el efecto $name")
                    }
                }
            } catch (error: Exception) {
                // Conservar navegación, pero permitir diagnosticar el fallo en logcat.
                Log.w("MangaMenuAudio", "No se pudo cargar el efecto $name", error)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "prepare" -> result.success(null)
            "stop" -> {
                pool?.autoPause()
                streams.clear()
                result.success(null)
            }
            "stopSound" -> {
                val name = call.argument<String>("sound")
                if (name != null) streams.remove(name)?.let { pool?.stop(it) }
                result.success(null)
            }
            "play" -> {
                val name = call.argument<String>("sound")
                // Ganancia por efecto: nunca modifica AudioManager ni el volumen global.
                val requestedVolume = call.argument<Number>("volume")?.toFloat() ?: 0.65f
                val volume = if (requestedVolume.isFinite()) requestedVolume.coerceIn(0f, 1f) else 0.65f
                val id = samples[name]
                val now = SystemClock.elapsedRealtime()
                if (volume > 0f && id != null && ready.contains(id) && now - lastPlay >= 75) {
                    lastPlay = now
                    try {
                        val stream = pool?.play(id, volume, volume, 1, 0, 1f) ?: 0
                        if (stream != 0 && name != null) {
                            // Solo un stream: no se acumulan efectos al deslizar rápido.
                            streams.clear()
                            streams[name] = stream
                        }
                        if (stream == 0) Log.w("MangaMenuAudio", "Reproducción rechazada: $name")
                    } catch (error: RuntimeException) {
                        Log.w("MangaMenuAudio", "No se pudo reproducir $name", error)
                    }
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
        streams.clear()
    }
}

package mods.sm64cdpy

import android.app.Activity
import android.app.Application
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Una pista por engine, por streaming y solo mientras su Activity está visible. */
class AmbientMusicPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler,
    Application.ActivityLifecycleCallbacks {
    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private var channel: MethodChannel? = null
    private var activity: Activity? = null
    private var player: MediaPlayer? = null
    private var manager: AudioManager? = null
    private var request: AudioFocusRequest? = null
    private var prepared = false
    private var enabled = false
    private var foreground = false
    private var focused = false
    private var blocked = false
    private var ducked = false
    private var failed = false
    private var volume = 0.18f
    private val attributes = AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()
    private val focusListener = AudioManager.OnAudioFocusChangeListener { change ->
        when (change) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                focused = true
                blocked = false
                ducked = false
                reconcile()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                ducked = true
                applyVolume()
            }
            else -> {
                focused = false
                blocked = true
                pause()
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        manager = binding.applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        channel = MethodChannel(binding.binaryMessenger, "sm64cdpy/ambient_music").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "configure") { result.notImplemented(); return }
        val next = call.argument<Boolean>("enabled") == true
        if (next != enabled) { blocked = false; failed = false }
        enabled = next
        val value = call.argument<Number>("volume")?.toFloat() ?: 0.18f
        volume = if (value.isFinite()) value.coerceIn(0f, 1f) else 0.18f
        reconcile()
        result.success(null)
    }

    private fun reconcile() {
        if (!enabled || !foreground || volume <= 0f) {
            pause()
            abandonFocus()
            return
        }
        if (failed || blocked) return
        if (player == null) {
            val engine = binding ?: return
            val created = try { MediaPlayer() } catch (error: RuntimeException) {
                Log.w("AmbientMusic", "Reproductor no disponible", error)
                failed = true
                return
            }
            player = created
            try {
                created.setAudioAttributes(attributes)
                val key = engine.flutterAssets.getAssetFilePathByName("assets/audio/manga/ambiente2.opus")
                engine.applicationContext.assets.openFd(key).use {
                    created.setDataSource(it.fileDescriptor, it.startOffset, it.length)
                }
                created.setOnPreparedListener {
                    if (player === it) {
                        prepared = true
                        it.isLooping = true
                        reconcile()
                    }
                }
                created.setOnErrorListener { _, what, extra ->
                    Log.w("AmbientMusic", "Error de pista: $what/$extra")
                    failed = true
                    releasePlayer()
                    abandonFocus()
                    true
                }
                created.prepareAsync()
            } catch (error: Exception) {
                Log.w("AmbientMusic", "No se pudo preparar la pista", error)
                failed = true
                releasePlayer()
            }
            return
        }
        if (!prepared) return
        if (!focused) {
            @Suppress("DEPRECATION")
            val granted = try { if (Build.VERSION.SDK_INT >= 26) {
                val focus = request ?: AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(attributes)
                    .setOnAudioFocusChangeListener(focusListener, Handler(Looper.getMainLooper()))
                    .build().also { request = it }
                manager?.requestAudioFocus(focus)
            } else {
                manager?.requestAudioFocus(focusListener, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN)
            } } catch (error: RuntimeException) {
                Log.w("AmbientMusic", "Foco de audio no disponible", error)
                return
            }
            focused = granted == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
        if (!focused) return
        try {
            applyVolume()
            if (player?.isPlaying == false) player?.start()
        } catch (error: IllegalStateException) {
            Log.w("AmbientMusic", "Reproducción no disponible", error)
            failed = true
            releasePlayer()
            abandonFocus()
        }
    }

    private fun applyVolume() {
        if (prepared) {
            val gain = volume * if (ducked) 0.2f else 1f
            try { player?.setVolume(gain, gain) } catch (error: IllegalStateException) {
                Log.w("AmbientMusic", "Ganancia no disponible", error)
                failed = true
                releasePlayer()
                abandonFocus()
            }
        }
    }

    private fun pause() {
        try {
            if (prepared && player?.isPlaying == true) player?.pause()
        } catch (error: IllegalStateException) {
            Log.w("AmbientMusic", "Pausa no disponible", error)
            failed = true
            releasePlayer()
        }
    }

    @Suppress("DEPRECATION")
    private fun abandonFocus() {
        if (Build.VERSION.SDK_INT >= 26) request?.let { manager?.abandonAudioFocusRequest(it) }
        else manager?.abandonAudioFocus(focusListener)
        focused = false
        ducked = false
    }

    private fun releasePlayer() {
        prepared = false
        player?.setOnPreparedListener(null)
        player?.setOnErrorListener(null)
        player?.release()
        player = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activity?.application?.registerActivityLifecycleCallbacks(this)
        // El callback onResume confirmará que se puede solicitar foco de audio.
        foreground = binding.activity.hasWindowFocus()
        reconcile()
    }
    private fun detachActivity() {
        foreground = false
        pause()
        abandonFocus()
        activity?.application?.unregisterActivityLifecycleCallbacks(this)
        activity = null
    }
    override fun onDetachedFromActivityForConfigChanges() = detachActivity()
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
    override fun onDetachedFromActivity() = detachActivity()
    override fun onActivityResumed(activity: Activity) {
        if (activity === this.activity) { foreground = true; blocked = false; reconcile() }
    }
    override fun onActivityPaused(activity: Activity) {
        if (activity === this.activity) { foreground = false; pause(); abandonFocus() }
    }
    override fun onActivityCreated(activity: Activity, state: Bundle?) {}
    override fun onActivityStarted(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, state: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        detachActivity()
        channel?.setMethodCallHandler(null)
        channel = null
        releasePlayer()
        this.binding = null
        manager = null
        request = null
    }
}

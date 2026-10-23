package mods.sm64cdpy

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.view.View
import android.view.ViewGroup
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

/** Hosts the compatibility WebRTC engine and projects its state to Flutter. */
class CoopSessionPlugin : FlutterPlugin, ActivityAware, EventChannel.StreamHandler {
    companion object {
        private const val METHOD_CHANNEL = "sm64cdpy/coop_session"
        private const val EVENT_CHANNEL = "sm64cdpy/coop_session_events"
        private const val GAME_PACKAGE = "com.maniscat2.sm64coopdx"
        private val CODE = Regex("^[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$")
    }

    private data class PendingStart(val mode: String, val code: String, val relayOnly: Boolean)

    private lateinit var context: Context
    private lateinit var methods: MethodChannel
    private lateinit var events: EventChannel
    private val main = Handler(Looper.getMainLooper())
    private var activity: Activity? = null
    private var webView: SessionWebView? = null
    private var sink: EventChannel.EventSink? = null
    private var ready = false
    private var pendingStart: PendingStart? = null
    private var ticker: ScheduledExecutorService? = null
    private var revision = 0L
    private var snapshot = mutableMapOf<String, Any?>(
        "phase" to "idle",
        "revision" to 0L,
        "initialized" to false,
        "friends" to emptyList<Map<String, Any?>>(),
        "trackers" to 0,
    )
    private val bridge = CoopGameBridge(object : CoopGameBridge.Listener {
        override fun onPacket(peer: String, data: ByteArray) {
            val encoded = Base64.encodeToString(data, Base64.NO_WRAP)
            evaluate("window.coopEngine?.onNativePacket(${JSONObject.quote(peer)},${JSONObject.quote(encoded)})")
        }

        override fun onGameSeen() {
            evaluate("window.coopEngine?.onGameSeen()")
            update(mapOf("gameIn" to true))
        }

        override fun onLog(message: String) {
            evaluate("window.coopEngine?.onNativeLog(${JSONObject.quote(message.take(500))})")
        }
    })
    private val stopReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == CoopSessionService.ACTION_STOP_REQUESTED) stop("notification")
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methods = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        events = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        methods.setMethodCallHandler(::onMethod)
        events.setStreamHandler(this)
        val filter = IntentFilter(CoopSessionService.ACTION_STOP_REQUESTED)
        if (Build.VERSION.SDK_INT >= 33) context.registerReceiver(stopReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        else @Suppress("DEPRECATION") context.registerReceiver(stopReceiver, filter)
    }

    private fun onMethod(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "snapshot" -> result.success(snapshot.toMap())
                "generateCode" -> result.success(generateCode())
                "start" -> result.success(start(call))
                "stop" -> { stop("user"); result.success(snapshot.toMap()) }
                "openGame" -> result.success(openGame())
                "gameInstalled" -> result.success(gameInstalled())
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("coop_error", error.message, error.javaClass.simpleName)
        }
    }

    private fun start(call: MethodCall): Map<String, Any?> {
        if (bridge.active()) throw IllegalStateException("A session is already active")
        val mode = call.argument<String>("mode").orEmpty()
        val code = normalizeCode(call.argument<String>("code").orEmpty())
        val relayOnly = call.argument<Boolean>("relayOnly") == true
        require(mode == "host" || mode == "join") { "Invalid session mode" }
        require(CODE.matches(code)) { "Invalid room code" }
        val port = bridge.start(mode)
        pendingStart = PendingStart(mode, code, relayOnly)
        update(
            mapOf(
                "sessionId" to UUID.randomUUID().toString(),
                "mode" to mode,
                "code" to code,
                "phase" to "preparing",
                "port" to port,
                "gameIn" to false,
                "gameHosting" to false,
                "message" to null,
                "friends" to emptyList<Map<String, Any?>>(),
                "trackers" to 0,
                "initialized" to true,
            ),
        )
        CoopSessionService.show(
            context,
            if (mode == "host") "Hosting · code $code" else "Playing with a friend",
            "Getting online…",
            if (mode == "host") code else "",
        )
        startTicker()
        launchPending()
        return snapshot.toMap()
    }

    private fun launchPending() {
        val request = pendingStart ?: return
        if (!ready) return
        pendingStart = null
        val json = JSONObject().apply {
            put("mode", request.mode)
            put("code", request.code)
            put("relayOnly", request.relayOnly)
        }
        evaluate("window.coopEngine.start($json)")
    }

    private fun stop(reason: String) {
        if (!bridge.active() && snapshot["phase"] == "idle") return
        update(mapOf("phase" to "stopping"))
        evaluate("window.coopEngine?.stop(${JSONObject.quote(reason)})")
        main.postDelayed({ finishStop() }, 450)
    }

    private fun finishStop() {
        pendingStart = null
        bridge.stop()
        ticker?.shutdownNow()
        ticker = null
        CoopSessionService.end(context)
        update(
            mapOf(
                "phase" to "stopped",
                "friends" to emptyList<Map<String, Any?>>(),
                "trackers" to 0,
                "message" to null,
            ),
        )
    }

    private fun startTicker() {
        ticker?.shutdownNow()
        ticker = Executors.newSingleThreadScheduledExecutor { runnable ->
            Thread(runnable, "coop-web-ticker").apply { isDaemon = true }
        }.also { executor ->
            executor.scheduleWithFixedDelay(
                {
                    evaluate("window.coopEngine?.tick()")
                    if (snapshot["mode"] == "host") {
                        val hosting = CoopGameBridge.gameHosting()
                        if (snapshot["gameHosting"] != hosting) {
                            update(mapOf("gameHosting" to hosting, "gameIn" to hosting))
                            evaluate("window.coopEngine?.setGameIn(${if (hosting) "true" else "false"})")
                        }
                    }
                },
                250,
                250,
                TimeUnit.MILLISECONDS,
            )
        }
    }

    private fun createWebView(activity: Activity) {
        if (webView != null) return
        val view = SessionWebView(activity).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.mediaPlaybackRequiresUserGesture = false
            setBackgroundColor(android.graphics.Color.TRANSPARENT)
            alpha = 0.01f
            addJavascriptInterface(JsBridge(), "NativeCoop")
            webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView?, url: String?) {
                    ready = true
                    update(mapOf("initialized" to true))
                    launchPending()
                }
            }
            loadUrl("file:///android_asset/flutter_assets/assets/coop/index.html")
        }
        val root = activity.findViewById<ViewGroup>(android.R.id.content)
        root.addView(view, FrameLayout.LayoutParams(1, 1))
        webView = view
    }

    private fun destroyWebView() {
        ready = false
        webView?.let { view ->
            (view.parent as? ViewGroup)?.removeView(view)
            view.removeJavascriptInterface("NativeCoop")
            view.destroy()
        }
        webView = null
    }

    private fun evaluate(script: String) {
        main.post { webView?.evaluateJavascript(script, null) }
    }

    private fun update(values: Map<String, Any?>) {
        main.post {
            revision++
            snapshot.putAll(values)
            snapshot["revision"] = revision
            sink?.success(snapshot.toMap())
            val phase = snapshot["phase"] as? String ?: return@post
            if (bridge.active() && phase !in listOf("idle", "stopped")) {
                val host = snapshot["mode"] == "host"
                val code = snapshot["code"] as? String ?: ""
                val friends = (snapshot["friends"] as? List<*>)?.size ?: 0
                CoopSessionService.show(
                    context,
                    if (host) "Hosting · code $code" else "Playing with a friend",
                    when (phase) {
                        "connected" -> if (friends == 1) "1 friend connected" else "$friends friends connected"
                        "reconnecting" -> "Reconnecting…"
                        "failed" -> (snapshot["message"] as? String).orEmpty()
                        else -> "Getting online…"
                    },
                    if (host) code else "",
                )
            }
        }
    }

    private fun generateCode(): String {
        val alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
        val random = java.security.SecureRandom()
        val raw = CharArray(8) { alphabet[random.nextInt(32)] }.concatToString()
        return "${raw.take(4)}-${raw.drop(4)}"
    }

    private fun normalizeCode(input: String): String {
        val raw = input.uppercase().filter { it.isLetterOrDigit() }.map {
            when (it) { 'I', 'L' -> '1'; 'O' -> '0'; else -> it }
        }.joinToString("")
        return if (raw.length == 8) "${raw.take(4)}-${raw.drop(4)}" else input.uppercase()
    }

    private fun gameInstalled(): Boolean = try {
        @Suppress("DEPRECATION")
        context.packageManager.getPackageInfo(GAME_PACKAGE, 0)
        true
    } catch (_: Exception) {
        false
    }

    private fun openGame(): Boolean {
        val intent = context.packageManager.getLaunchIntentForPackage(GAME_PACKAGE) ?: return false
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        return true
    }

    private inner class JsBridge {
        @JavascriptInterface fun ready() {
            main.post { ready = true; launchPending() }
        }

        @JavascriptInterface fun publish(stateJson: String) {
            try {
                val json = JSONObject(stateJson)
                val friendsJson = json.optJSONArray("friends")
                val friends = ArrayList<Map<String, Any?>>()
                if (friendsJson != null) repeat(friendsJson.length()) { index ->
                    val friend = friendsJson.getJSONObject(index)
                    friends.add(
                        mapOf(
                            "id" to friend.optString("id"),
                            "route" to friend.optString("route").takeIf { it.isNotEmpty() },
                            "reconnecting" to friend.optBoolean("reconnecting"),
                            "game" to if (friend.has("game") && !friend.isNull("game")) friend.optBoolean("game") else null,
                        ),
                    )
                }
                update(
                    mapOf(
                        "phase" to json.optString("phase", "failed"),
                        "trackers" to json.optInt("trackers", 0),
                        "message" to json.optString("message").takeIf { it.isNotEmpty() },
                        "friends" to friends,
                    ),
                )
            } catch (error: Exception) {
                update(mapOf("phase" to "failed", "message" to "Invalid engine state: ${error.message}"))
            }
        }

        @JavascriptInterface fun packet(peer: String, data: String, sentAt: Long) {
            if (peer.length !in 1..64 || data.length > 8192) return
            try { bridge.fromRemote(peer, Base64.decode(data, Base64.NO_WRAP)) } catch (_: IllegalArgumentException) {}
        }

        @JavascriptInterface fun peerOpen(peer: String) {
            if (peer.length in 1..64) try { bridge.openPeer(peer) } catch (error: Exception) { log("peer socket: ${error.message}") }
        }

        @JavascriptInterface fun peerClose(peer: String) {
            if (peer.length in 1..64) bridge.closePeer(peer)
        }

        @JavascriptInterface fun setLink(peer: String, up: Boolean) {
            if (peer.length in 1..64) bridge.setLink(peer, up)
        }

        @JavascriptInterface fun log(message: String) {
            android.util.Log.d("CoopSession", message.take(500))
        }

        @JavascriptInterface fun failed(message: String) {
            update(mapOf("phase" to "failed", "message" to message.take(300)))
        }
    }

    private class SessionWebView(context: Context) : WebView(context) {
        override fun onVisibilityChanged(changedView: View, visibility: Int) = super.onVisibilityChanged(changedView, VISIBLE)
        override fun onWindowVisibilityChanged(visibility: Int) = super.onWindowVisibilityChanged(VISIBLE)
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        sink = eventSink
        eventSink.success(snapshot.toMap())
    }

    override fun onCancel(arguments: Any?) { sink = null }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        createWebView(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() { destroyWebView(); activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { onAttachedToActivity(binding) }
    override fun onDetachedFromActivity() { destroyWebView(); activity = null }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stop("engine detached")
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        try { context.unregisterReceiver(stopReceiver) } catch (_: Exception) {}
    }
}

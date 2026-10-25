package mods.sm64cdpy

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.util.Base64
import android.view.View
import android.view.ViewGroup
import android.webkit.JavascriptInterface
import android.webkit.RenderProcessGoneDetail
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
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
    private var stopRunnable: Runnable? = null
    private var diagnosticTicks = 0
    private var upDelaySamples = 0L
    private var upDelayTotalMs = 0L
    private var upDelayMaxMs = 0L
    private var revision = 0L
    private var snapshot = mutableMapOf<String, Any?>(
        "phase" to "idle",
        "revision" to 0L,
        "initialized" to false,
        "friends" to emptyList<Map<String, Any?>>(),
        "trackers" to 0,
        "toGame" to 0L,
        "toPage" to 0L,
        "upDelaySamples" to 0L,
        "upDelayAverageMs" to 0L,
        "upDelayMaxMs" to 0L,
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
                "batteryOptimizationStatus" -> result.success(batteryOptimizationState())
                "requestBatteryOptimizationExemption" -> result.success(requestBatteryOptimizationExemption())
                "openBatteryOptimizationSettings" -> result.success(openBatteryOptimizationSettings())
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
        try {
            resetDiagnostics()
            webView?.setKeepRunning(true)
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
                    "toGame" to 0L,
                    "toPage" to 0L,
                    "upDelaySamples" to 0L,
                    "upDelayAverageMs" to 0L,
                    "upDelayMaxMs" to 0L,
                    "initialized" to true,
                ),
            )
            CoopSessionService.show(
                context,
                host = mode == "host",
                phase = "preparing",
                code = if (mode == "host") code else "",
            )
            startTicker()
            launchPending()
            return snapshot.toMap()
        } catch (error: Exception) {
            pendingStart = null
            webView?.setKeepRunning(false)
            ticker?.shutdownNow()
            ticker = null
            bridge.stop()
            CoopSessionService.end(context)
            throw error
        }
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
        update(mapOf("phase" to "stopping"), refreshNotification = false)
        evaluate("window.coopEngine?.stop(${JSONObject.quote(reason)})")
        stopRunnable?.let(main::removeCallbacks)
        val pending = Runnable { finishStop() }
        stopRunnable = pending
        main.postDelayed(pending, 450)
    }

    private fun finishStop(finalPhase: String = "stopped", finalMessage: String? = null) {
        stopRunnable?.let(main::removeCallbacks)
        stopRunnable = null
        pendingStart = null
        webView?.setKeepRunning(false)
        bridge.stop()
        ticker?.shutdownNow()
        ticker = null
        CoopSessionService.end(context)
        update(
            mapOf(
                "phase" to finalPhase,
                "friends" to emptyList<Map<String, Any?>>(),
                "trackers" to 0,
                "message" to finalMessage,
            ),
        )
    }

    private fun failAndStop(message: String) {
        val safeMessage = message.take(300)
        if (!bridge.active()) {
            update(mapOf("phase" to "failed", "message" to safeMessage))
            return
        }
        update(mapOf("phase" to "stopping", "message" to safeMessage), refreshNotification = false)
        evaluate("window.coopEngine?.stop()")
        stopRunnable?.let(main::removeCallbacks)
        val pending = Runnable { finishStop(finalPhase = "failed", finalMessage = safeMessage) }
        stopRunnable = pending
        main.postDelayed(pending, 450)
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
                    diagnosticTicks = (diagnosticTicks + 1) % 4
                    if (diagnosticTicks == 0) publishDiagnostics()
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
            settings.javaScriptCanOpenWindowsAutomatically = false
            settings.setSupportMultipleWindows(false)
            settings.mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
            settings.allowContentAccess = false
            if (Build.VERSION.SDK_INT >= 26) {
                settings.safeBrowsingEnabled = true
                setRendererPriorityPolicy(WebView.RENDERER_PRIORITY_IMPORTANT, false)
            }
            setBackgroundColor(android.graphics.Color.TRANSPARENT)
            alpha = 0.01f
            addJavascriptInterface(JsBridge(), "NativeCoop")
            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean =
                    request?.url?.toString() != "file:///android_asset/flutter_assets/assets/coop/index.html"

                override fun onPageFinished(view: WebView?, url: String?) {
                    ready = true
                    update(mapOf("initialized" to true))
                    launchPending()
                }

                override fun onRenderProcessGone(view: WebView?, detail: RenderProcessGoneDetail?): Boolean {
                    main.post { recoverWebView() }
                    return true
                }
            }
            loadUrl("file:///android_asset/flutter_assets/assets/coop/index.html")
        }
        val root = activity.findViewById<ViewGroup>(android.R.id.content)
        root.addView(view, FrameLayout.LayoutParams(1, 1))
        webView = view
        view.setKeepRunning(bridge.active())
    }

    private fun destroyWebView(terminateSession: Boolean = false) {
        if (terminateSession && bridge.active()) terminateSessionForLifecycle()
        ready = false
        webView?.let { view ->
            (view.parent as? ViewGroup)?.removeView(view)
            view.removeJavascriptInterface("NativeCoop")
            view.destroy()
        }
        webView = null
    }

    private fun recoverWebView() {
        val wasActive = bridge.active()
        destroyWebView(terminateSession = wasActive)
        activity?.let(::createWebView)
    }

    private fun terminateSessionForLifecycle() {
        stopRunnable?.let(main::removeCallbacks)
        stopRunnable = null
        pendingStart = null
        webView?.setKeepRunning(false)
        bridge.stop()
        ticker?.shutdownNow()
        ticker = null
        CoopSessionService.end(context)
        update(
            mapOf(
                "phase" to "failed",
                "friends" to emptyList<Map<String, Any?>>(),
                "trackers" to 0,
                "message" to AppLanguage.context(context).getString(R.string.coop_session_interrupted),
            ),
        )
    }

    private fun evaluate(script: String) {
        main.post { webView?.evaluateJavascript(script, null) }
    }

    private fun update(values: Map<String, Any?>, refreshNotification: Boolean = true) {
        main.post {
            revision++
            snapshot.putAll(values)
            snapshot["revision"] = revision
            sink?.success(snapshot.toMap())
            val phase = snapshot["phase"] as? String ?: return@post
            if (refreshNotification && bridge.active() && phase !in listOf("idle", "stopped")) {
                val host = snapshot["mode"] == "host"
                val code = snapshot["code"] as? String ?: ""
                val friends = (snapshot["friends"] as? List<*>)?.size ?: 0
                CoopSessionService.show(
                    context,
                    host = host,
                    phase = phase,
                    code = if (host) code else "",
                    friends = friends,
                    failure = (snapshot["message"] as? String).orEmpty(),
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
            when (it) { 'I', 'L' -> '1'; 'O' -> '0'; 'U' -> 'V'; else -> it }
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

    private fun batteryOptimizationState(settingsOpened: Boolean = false): Map<String, Any> {
        if (Build.VERSION.SDK_INT < 23) {
            return mapOf("supported" to false, "ignored" to true, "settingsOpened" to settingsOpened)
        }
        val power = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return mapOf(
            "supported" to true,
            "ignored" to power.isIgnoringBatteryOptimizations(context.packageName),
            "settingsOpened" to settingsOpened,
        )
    }

    private fun requestBatteryOptimizationExemption(): Map<String, Any> {
        if (Build.VERSION.SDK_INT < 23 || batteryOptimizationState()["ignored"] == true) {
            return batteryOptimizationState()
        }
        val direct = Intent(
            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
            Uri.parse("package:${context.packageName}"),
        )
        val opened = launchSettings(direct) || launchSettings(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
        return batteryOptimizationState(settingsOpened = opened)
    }

    private fun openBatteryOptimizationSettings(): Map<String, Any> {
        if (Build.VERSION.SDK_INT < 23) return batteryOptimizationState()
        val opened = launchSettings(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)) ||
            launchSettings(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${context.packageName}")),
            )
        return batteryOptimizationState(settingsOpened = opened)
    }

    private fun launchSettings(intent: Intent): Boolean = try {
        val owner = activity
        if (owner == null) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val starter = owner ?: context
        if (intent.resolveActivity(context.packageManager) == null) false
        else { starter.startActivity(intent); true }
    } catch (_: Exception) {
        false
    }

    @Synchronized
    private fun resetDiagnostics() {
        diagnosticTicks = 0
        upDelaySamples = 0
        upDelayTotalMs = 0
        upDelayMaxMs = 0
    }

    @Synchronized
    private fun recordUpDelay(sentAt: Long) {
        if (sentAt <= 0) return
        val delay = (System.currentTimeMillis() - sentAt).coerceAtLeast(0)
        upDelaySamples++
        upDelayTotalMs += delay
        upDelayMaxMs = maxOf(upDelayMaxMs, delay)
    }

    @Synchronized
    private fun publishDiagnostics() {
        val bridgeStats = bridge.stats()
        update(
            mapOf(
                "toGame" to bridgeStats.toGame,
                "toPage" to bridgeStats.toPage,
                "upDelaySamples" to upDelaySamples,
                "upDelayAverageMs" to if (upDelaySamples > 0) upDelayTotalMs / upDelaySamples else 0,
                "upDelayMaxMs" to upDelayMaxMs,
            ),
            refreshNotification = false,
        )
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
                if (json.optString("phase") == "stopped" && stopRunnable != null) return
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
            try {
                recordUpDelay(sentAt)
                bridge.fromRemote(peer, Base64.decode(data, Base64.NO_WRAP))
            } catch (_: IllegalArgumentException) {}
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
            main.post { failAndStop(message) }
        }
    }

    private class SessionWebView(context: Context) : WebView(context) {
        private var keepRunning = false

        fun setKeepRunning(value: Boolean) {
            if (keepRunning == value) return
            keepRunning = value
            if (value) {
                onVisibilityChanged(this, VISIBLE)
                onWindowVisibilityChanged(VISIBLE)
            }
        }

        override fun onVisibilityChanged(changedView: View, visibility: Int) =
            super.onVisibilityChanged(changedView, if (keepRunning) VISIBLE else visibility)

        override fun onWindowVisibilityChanged(visibility: Int) =
            super.onWindowVisibilityChanged(if (keepRunning) VISIBLE else visibility)
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

    override fun onDetachedFromActivityForConfigChanges() { destroyWebView(terminateSession = true); activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { onAttachedToActivity(binding) }
    override fun onDetachedFromActivity() { destroyWebView(terminateSession = true); activity = null }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (bridge.active()) terminateSessionForLifecycle()
        destroyWebView()
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        try { context.unregisterReceiver(stopReceiver) } catch (_: Exception) {}
    }
}

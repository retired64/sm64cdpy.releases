package mods.sm64cdpy

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.webkit.JavascriptInterface
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import java.util.concurrent.Executors

/** Android-only local WebGL surface. It has no network navigation capability. */
class Player3DPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(
            VIEW_TYPE,
            Player3DViewFactory(binding.binaryMessenger),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) = Unit

    companion object {
        const val VIEW_TYPE = "mods.sm64cdpy/player3d"
    }
}

private class Player3DViewFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        Player3DView(context, messenger, viewId, args as? Map<*, *>)
}

@SuppressLint("SetJavaScriptEnabled")
private class Player3DView(
    private val context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    initial: Map<*, *>?,
) : PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "mods.sm64cdpy/player3d/$viewId")
    private val worker = Executors.newSingleThreadExecutor()
    private var inputs: Player3DSource.Inputs? = null
    private var profile = normalize(initial)
    private var bridgeReady = false
    private var disposed = false
    private var lastState: Map<String, String> = mapOf("state" to "loading", "detail" to "")
    private val webView = WebView(context).apply {
        setBackgroundColor(Color.TRANSPARENT)
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = false
        settings.allowFileAccess = false
        settings.allowContentAccess = false
        settings.cacheMode = WebSettings.LOAD_NO_CACHE
        settings.mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
        settings.setSupportMultipleWindows(false)
        addJavascriptInterface(Bridge(), "Player3DBridge")
        webViewClient = LocalClient()
    }

    init {
        channel.setMethodCallHandler(this)
        worker.execute {
            try {
                val prepared = Player3DSource.prepare(context)
                context.mainExecutor.execute {
                    if (!disposed) {
                        inputs = prepared
                        webView.loadUrl("https://player3d.local/index.html")
                    }
                }
            } catch (error: Exception) {
                emit("error", error.message ?: "source_failed")
            }
        }
    }

    override fun getView() = webView

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "update" -> {
                profile = normalize(call.arguments as? Map<*, *>)
                if (bridgeReady) pushProfile()
                result.success(null)
            }
            "getState" -> result.success(lastState)
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        disposed = true
        bridgeReady = false
        channel.setMethodCallHandler(null)
        webView.removeJavascriptInterface("Player3DBridge")
        webView.stopLoading()
        webView.loadUrl("about:blank")
        webView.destroy()
        worker.shutdownNow()
    }

    private fun normalize(value: Map<*, *>?): Map<String, Any> {
        val model = ((value?.get("model") as? Number)?.toInt() ?: 0).coerceIn(0, 4)
        val colors = (value?.get("colors") as? List<*>)?.mapNotNull { (it as? Number)?.toInt()?.and(0xffffff) }
            ?.takeIf { it.size == 8 } ?: List(8) { 0x808080 }
        return mapOf("model" to model, "colors" to colors)
    }

    private fun pushProfile() {
        val json = org.json.JSONObject(profile).toString()
        webView.evaluateJavascript("window.player3dUpdate(${org.json.JSONObject.quote(json)})", null)
    }

    private fun emit(state: String, detail: String = "") {
        context.mainExecutor.execute {
            if (!disposed) {
                val value = mapOf("state" to state, "detail" to detail)
                lastState = value
                channel.invokeMethod("state", value)
            }
        }
    }

    private inner class Bridge {
        @JavascriptInterface
        fun postState(json: String) {
            val value = runCatching { org.json.JSONObject(json) }.getOrNull() ?: return
            val state = value.optString("state")
            if (state == "bridge-ready") {
                bridgeReady = true
                context.mainExecutor.execute { if (!disposed) pushProfile() }
            } else emit(state, value.optString("detail"))
        }
    }

    private inner class LocalClient : WebViewClient() {
        override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean =
            !isLocal(request.url)

        override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? {
            if (!isLocal(request.url)) return forbidden()
            val path = request.url.path.orEmpty().removePrefix("/")
            return try {
                when (path) {
                    "", "index.html" -> asset("index.html", "text/html")
                    "app.js" -> asset("app.js", "application/javascript")
                    "player3d-index.js" -> asset("player3d-index.js", "application/javascript")
                    "player3d-renderer.js" -> asset("player3d-renderer.js", "application/javascript")
                    "game.bin" -> file(requireNotNull(inputs).game, "application/octet-stream")
                    "rom.bin" -> file(requireNotNull(inputs).rom, "application/octet-stream")
                    else -> forbidden()
                }
            } catch (_: Exception) {
                forbidden()
            }
        }

        private fun isLocal(uri: Uri) = uri.scheme == "https" && uri.host == "player3d.local"

        private fun asset(name: String, mime: String) = response(
            context.assets.open("flutter_assets/assets/player3d/$name"), mime,
        )

        private fun file(file: File, mime: String) = response(FileInputStream(file), mime)

        private fun response(stream: InputStream, mime: String) = WebResourceResponse(
            mime,
            "UTF-8",
            200,
            "OK",
            mapOf("Cache-Control" to "no-store", "Access-Control-Allow-Origin" to "https://player3d.local"),
            stream,
        )

        private fun forbidden() = WebResourceResponse(
            "text/plain", "UTF-8", 404, "Not Found", emptyMap(), "".byteInputStream(),
        )
    }
}

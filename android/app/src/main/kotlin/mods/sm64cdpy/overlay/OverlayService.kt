package mods.sm64cdpy.overlay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager
import androidx.core.app.NotificationCompat

class OverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "overlay_service_channel"
        const val NOTIFICATION_ID = 9001
        const val PREFS_NAME = "overlay_prefs"
        const val KEY_BUBBLE_X = "bubble_x"
        const val KEY_BUBBLE_Y = "bubble_y"

        private const val DRAG_THRESHOLD_DP = 8f

        fun isRunning(context: Context): Boolean {
            return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean("is_running", false)
        }
    }

    private var windowManager: WindowManager? = null
    private var bubbleView: BubbleView? = null
    private var bubbleParams: WindowManager.LayoutParams? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification()
        startForeground(NOTIFICATION_ID, notification)

        setRunningFlag(true)
        addBubble()

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        removeBubble()
        setRunningFlag(false)
        super.onDestroy()
    }

    // ── Notification ────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Mod Manager Overlay",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows the floating bubble for quick mod access"
                setShowBadge(false)
            }
            val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = if (openAppIntent != null) {
            PendingIntent.getActivity(
                this,
                0,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            null
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Mod Manager")
            .setContentText("Tap the bubble to browse mods")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .build()
    }

    // ── Bubble ──────────────────────────────────────────────────────────────

    private fun addBubble() {
        if (bubbleView != null) return

        val wm = windowManager ?: return
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        bubbleView = BubbleView(this)

        val density = resources.displayMetrics.density
        val defaultX = (resources.displayMetrics.widthPixels - 60 * density).toInt()
        val defaultY = (resources.displayMetrics.heightPixels / 2).toInt()

        val savedX = prefs.getInt(KEY_BUBBLE_X, defaultX)
        val savedY = prefs.getInt(KEY_BUBBLE_Y, defaultY)

        bubbleParams = WindowManager.LayoutParams(
            60.dpToPx(),
            60.dpToPx(),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = savedX
            y = savedY
        }

        bubbleView?.setOnTouchListener(OverlayTouchListener())

        try {
            wm.addView(bubbleView, bubbleParams)
        } catch (e: Exception) {
            bubbleView = null
            bubbleParams = null
        }
    }

    private fun removeBubble() {
        val wm = windowManager
        val view = bubbleView
        if (wm != null && view != null) {
            try {
                wm.removeView(view)
            } catch (_: Exception) { }
        }
        bubbleView = null
        bubbleParams = null
    }

    // ── Drag handling ───────────────────────────────────────────────────────

    private inner class OverlayTouchListener : android.view.View.OnTouchListener {
        private var initialX = 0
        private var initialY = 0
        private var initialTouchX = 0f
        private var initialTouchY = 0f
        private val dragThreshold = (DRAG_THRESHOLD_DP * resources.displayMetrics.density).toInt()
        private var hasMoved = false

        override fun onTouch(v: android.view.View, event: MotionEvent): Boolean {
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = bubbleParams?.x ?: 0
                    initialY = bubbleParams?.y ?: 0
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    hasMoved = false
                    return true
                }

                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - initialTouchX).toInt()
                    val dy = (event.rawY - initialTouchY).toInt()

                    if (hasMoved || Math.abs(dx) > dragThreshold || Math.abs(dy) > dragThreshold) {
                        hasMoved = true
                        val params = bubbleParams ?: return true
                        params.x = initialX + dx
                        params.y = initialY + dy
                        try {
                            windowManager?.updateViewLayout(bubbleView, params)
                        } catch (_: Exception) { }
                    }
                    return true
                }

                MotionEvent.ACTION_UP -> {
                    if (!hasMoved) {
                        onBubbleTap()
                    } else {
                        savePosition()
                    }
                    return true
                }

                MotionEvent.ACTION_CANCEL -> {
                    savePosition()
                    return true
                }
            }
            return false
        }
    }

    private fun onBubbleTap() {
        // TODO Fase 1 — will toggle Flutter panel
    }

    private fun savePosition() {
        val params = bubbleParams ?: return
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putInt(KEY_BUBBLE_X, params.x)
            .putInt(KEY_BUBBLE_Y, params.y)
            .apply()
    }

    private fun setRunningFlag(running: Boolean) {
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean("is_running", running)
            .apply()
    }

    private fun Int.dpToPx(): Int = (this * resources.displayMetrics.density).toInt()
}

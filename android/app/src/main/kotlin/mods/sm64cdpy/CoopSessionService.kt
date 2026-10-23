package mods.sm64cdpy

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

class CoopSessionService : Service() {
    companion object {
        const val CHANNEL_ID = "coop_session"
        const val ACTION_SHOW = "mods.sm64cdpy.coop.SHOW"
        const val ACTION_COPY = "mods.sm64cdpy.coop.COPY"
        const val ACTION_STOP = "mods.sm64cdpy.coop.STOP"
        const val ACTION_STOP_REQUESTED = "mods.sm64cdpy.coop.STOP_REQUESTED"
        private const val NOTIFICATION_ID = 7787

        fun show(context: Context, title: String, text: String, code: String) {
            val intent = Intent(context, CoopSessionService::class.java).apply {
                action = ACTION_SHOW
                putExtra("title", title.take(80))
                putExtra("text", text.take(200))
                putExtra("code", code.take(16))
            }
            if (Build.VERSION.SDK_INT >= 26) context.startForegroundService(intent) else context.startService(intent)
        }

        fun end(context: Context) {
            context.stopService(Intent(context, CoopSessionService::class.java))
        }
    }

    private var code = ""
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= 26) {
            val channel = NotificationChannel(CHANNEL_ID, "Multiplayer session", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Keeps the multiplayer connection active while the game is open"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_COPY -> {
                if (code.isNotEmpty()) {
                    (getSystemService(CLIPBOARD_SERVICE) as ClipboardManager)
                        .setPrimaryClip(ClipData.newPlainText("Join code", code))
                }
                return START_NOT_STICKY
            }
            ACTION_STOP -> {
                sendBroadcast(Intent(ACTION_STOP_REQUESTED).setPackage(packageName))
                return START_NOT_STICKY
            }
        }
        code = intent?.getStringExtra("code").orEmpty()
        val notification = buildNotification(
            intent?.getStringExtra("title") ?: "Playing with friends",
            intent?.getStringExtra("text").orEmpty(),
        )
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            notification,
            if (Build.VERSION.SDK_INT >= 34) android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE else 0,
        )
        holdLocks()
        return START_NOT_STICKY
    }

    private fun buildNotification(title: String, text: String): Notification {
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val stop = PendingIntent.getService(
            this,
            1,
            Intent(this, CoopSessionService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_sm64cdpy)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(open)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .addAction(0, "Stop", stop)
        if (code.isNotEmpty()) {
            val copy = PendingIntent.getService(
                this,
                2,
                Intent(this, CoopSessionService::class.java).setAction(ACTION_COPY),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            builder.addAction(0, "Copy code", copy)
        }
        return builder.build()
    }

    private fun holdLocks() {
        if (wakeLock == null) {
            wakeLock = (getSystemService(POWER_SERVICE) as PowerManager)
                .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "sm64cdpy:coop-session")
                .apply { setReferenceCounted(false); acquire(6 * 60 * 60 * 1000L) }
        }
        if (wifiLock == null) {
            val manager = applicationContext.getSystemService(WIFI_SERVICE) as? WifiManager
            wifiLock = manager?.createWifiLock(
                if (Build.VERSION.SDK_INT >= 29) WifiManager.WIFI_MODE_FULL_LOW_LATENCY else WifiManager.WIFI_MODE_FULL_HIGH_PERF,
                "sm64cdpy:coop-session",
            )?.apply { setReferenceCounted(false); acquire() }
        }
    }

    override fun onDestroy() {
        wakeLock?.takeIf { it.isHeld }?.release()
        wifiLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
        wifiLock = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

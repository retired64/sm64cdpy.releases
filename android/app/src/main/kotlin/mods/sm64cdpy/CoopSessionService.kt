package mods.sm64cdpy

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.IntentFilter
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

        fun show(
            context: Context,
            host: Boolean,
            phase: String,
            code: String,
            friends: Int = 0,
            failure: String = "",
        ) {
            val intent = Intent(context, CoopSessionService::class.java).apply {
                action = ACTION_SHOW
                putExtra("host", host)
                putExtra("phase", phase.take(24))
                putExtra("code", code.take(16))
                putExtra("friends", friends.coerceAtLeast(0))
                putExtra("failure", failure.take(200))
            }
            if (Build.VERSION.SDK_INT >= 26) context.startForegroundService(intent) else context.startService(intent)
        }

        fun end(context: Context) {
            context.stopService(Intent(context, CoopSessionService::class.java))
        }
    }

    private var lastShow: Intent? = null
    private val languageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Intent.ACTION_LOCALE_CHANGED) {
                AppLanguage.refreshChannels(this@CoopSessionService)
            }
            lastShow?.let { onStartCommand(it, 0, 0) }
        }
    }
    private fun localizedText(id: Int, vararg args: Any): String =
        AppLanguage.context(this).getString(id, *args)

    private var code = ""
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onCreate() {
        super.onCreate()
        val filter = IntentFilter(AppLanguage.ACTION_CHANGED).apply {
            addAction(Intent.ACTION_LOCALE_CHANGED)
        }
        if (Build.VERSION.SDK_INT >= 33) registerReceiver(languageReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        else @Suppress("DEPRECATION") registerReceiver(languageReceiver, filter)
        if (Build.VERSION.SDK_INT >= 26) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                localizedText(R.string.channel_coop_session),
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = localizedText(R.string.channel_coop_session_desc)
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
                        .setPrimaryClip(ClipData.newPlainText(localizedText(R.string.coop_notification_copy), code))
                }
                return START_NOT_STICKY
            }
            ACTION_STOP -> {
                sendBroadcast(Intent(ACTION_STOP_REQUESTED).setPackage(packageName))
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf(startId)
                return START_NOT_STICKY
            }
        }
        lastShow = intent
        code = intent?.getStringExtra("code").orEmpty()
        val host = intent?.getBooleanExtra("host", false) == true
        val phase = intent?.getStringExtra("phase").orEmpty()
        val friends = intent?.getIntExtra("friends", 0) ?: 0
        val notification = buildNotification(
            if (host) localizedText(R.string.coop_notification_hosting, code)
            else localizedText(R.string.coop_notification_joining),
            when (phase) {
                "connected" -> AppLanguage.context(this).resources.getQuantityString(
                    R.plurals.coop_notification_friends,
                    friends,
                    friends,
                )
                "reconnecting" -> localizedText(R.string.coop_notification_reconnecting)
                "failed" -> localizedText(R.string.coop_notification_failed)
                "stopping" -> localizedText(R.string.coop_notification_stopping)
                else -> localizedText(R.string.coop_notification_preparing)
            },
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
            .addAction(0, localizedText(R.string.coop_notification_stop), stop)
        if (code.isNotEmpty()) {
            val copy = PendingIntent.getService(
                this,
                2,
                Intent(this, CoopSessionService::class.java).setAction(ACTION_COPY),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            builder.addAction(0, localizedText(R.string.coop_notification_copy), copy)
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
        unregisterReceiver(languageReceiver)
        lastShow = null
        wakeLock?.takeIf { it.isHeld }?.release()
        wifiLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
        wifiLock = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

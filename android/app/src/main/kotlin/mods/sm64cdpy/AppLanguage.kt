package mods.sm64cdpy

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import android.os.LocaleList
import java.util.Locale

/** Hive owns the choice. Flutter mirrors it before publishing a locale change. */
internal object AppLanguage {
    const val ACTION_CHANGED = "mods.sm64cdpy.LANGUAGE_CHANGED"

    fun context(base: Context): Context {
        val tag = base.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getString("flutter.app_locale", "system")
        val configuration = Configuration(base.resources.configuration)
        val language = when (tag) {
            "en_US" -> "en-US"
            "es_419" -> "es-419"
            "pt_BR" -> "pt-BR"
            "fr", "it" -> tag
            else -> null
        }
        // Use device locales when following the system, not a previous override.
        configuration.setLocales(if (language == null) Resources.getSystem().configuration.locales
            else LocaleList(Locale.forLanguageTag(language)))
        return base.createConfigurationContext(configuration)
    }

    fun refreshChannels(base: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val localized = context(base)
            val manager = base.getSystemService(NotificationManager::class.java)
            val channels = listOf(
                Triple(ModInstallWorker.CHANNEL_ID, R.string.channel_mod_installation, R.string.channel_mod_installation_desc),
                Triple(ModDownloadWorker.DOWNLOAD_CHANNEL_ID, R.string.channel_mod_download, R.string.channel_mod_download_desc),
                Triple(ModInstallWorker.RESULT_CHANNEL_ID, R.string.channel_mod_results, R.string.channel_mod_results_desc),
                Triple(CoopSessionService.CHANNEL_ID, R.string.channel_coop_session, R.string.channel_coop_session_desc),
            )
            channels.forEach { (id, name, description) ->
                val result = id == ModInstallWorker.RESULT_CHANNEL_ID
                val channel = NotificationChannel(id, localized.getString(name),
                    if (result) NotificationManager.IMPORTANCE_HIGH else NotificationManager.IMPORTANCE_LOW)
                channel.description = localized.getString(description)
                channel.setShowBadge(result)
                if (result) channel.enableVibration(true)
                // Existing channel importance and user choices are preserved by Android.
                manager.createNotificationChannel(channel)
            }
        }
        base.sendBroadcast(Intent(ACTION_CHANGED).setPackage(base.packageName))
    }
}

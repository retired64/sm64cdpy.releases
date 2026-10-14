package mods.sm64cdpy

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.WorkQuery

/** user is authority; existing installation keys are atomic derived projections. */
internal object GameFolderStore {
    const val KEY = "game_user_tree_uri"
    private fun prefs(context: Context) = context.getSharedPreferences(ModInstallerPlugin.PREF_NAME, Context.MODE_PRIVATE)

    private fun requireIdle(context: Context) {
        val query = WorkQuery.Builder.fromStates(listOf(WorkInfo.State.ENQUEUED, WorkInfo.State.RUNNING, WorkInfo.State.BLOCKED)).build()
        require(WorkManager.getInstance(context).getWorkInfos(query).get().none { info ->
            info.tags.any { it == ModInstallWorker::class.java.name || it == ModDownloadWorker::class.java.name }
        }) { "installing" }
    }

    fun connect(context: Context, uri: Uri, flags: Int) = synchronized(InstallationSafAccessCoordinator.lock) {
        requireIdle(context)
        val granted = flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        require(granted == (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)) { "access" }
        val grant = GameFolderAccess.grantUri(uri)
        val alreadyGranted = GameFolderAccess.hasGrant(context, grant, write = true)
        context.contentResolver.takePersistableUriPermission(grant, granted)
        val preferences = prefs(context)
        try {
            val root = GameFolderAccess.resolve(context, grant) ?: error("access")
            require(root.isDirectory && root.name == "user" && root.canRead() && root.canWrite()) { "folder" }
            require(root.findFile("sm64config.txt") != null || root.findFile("mods") != null ||
                root.findFile("dynos") != null || root.listFiles().any { it.isFile && it.name?.endsWith(".z64", true) == true }) { "folder" }
            fun directory(parent: DocumentFile, name: String): DocumentFile {
                val child = parent.findFile(name) ?: parent.createDirectory(name) ?: error("access")
                require(child.isDirectory && child.name == name && child.canRead() && child.canWrite()) { "folder" }
                return child
            }
            val mods = directory(root, "mods")
            val packs = directory(directory(root, "dynos"), "packs")
            synchronized(InstallationSafAccessCoordinator.selectionLock) {
                requireIdle(context)
            val keys = listOf(KEY, ModInstallerPlugin.KEY_TREE_URI, ModInstallerPlugin.KEY_DYNOS_TREE_URI,
                "unified_game_folder_version", ModInstallerPlugin.KEY_TREE_PERMISSION_REVOKED, ModInstallerPlugin.KEY_DYNOS_TREE_PERMISSION_REVOKED)
            val previous = keys.associateWith { preferences.all[it] }
            val editor = preferences.edit().putString(KEY, grant.toString())
                .putString(ModInstallerPlugin.KEY_TREE_URI, mods.uri.toString())
                .putString(ModInstallerPlugin.KEY_DYNOS_TREE_URI, packs.uri.toString())
                .putInt("unified_game_folder_version", 1)
                .remove(ModInstallerPlugin.KEY_TREE_PERMISSION_REVOKED)
                .remove(ModInstallerPlugin.KEY_DYNOS_TREE_PERMISSION_REVOKED)
            if (!editor.commit()) {
                val rollback = preferences.edit()
                previous.forEach { (key, value) -> when (value) {
                    is String -> rollback.putString(key, value)
                    is Boolean -> rollback.putBoolean(key, value)
                    is Int -> rollback.putInt(key, value)
                    else -> rollback.remove(key)
                } }
                rollback.commit()
                error("access")
            }
            }
            // Retain old grants: queued workers hold immutable URI inputs, not mutable folder prefs.
        } catch (error: Exception) {
            if (!alreadyGranted && preferences.getString(KEY, null) != grant.toString()) {
                runCatching { context.contentResolver.releasePersistableUriPermission(grant, granted) }
            }
            throw error
        }
    }

    fun root(context: Context): DocumentFile? {
        val saved = prefs(context).getString(KEY, null) ?: return null
        val uri = Uri.parse(saved)
        return GameFolderAccess.resolve(context, uri)?.takeIf {
            GameFolderAccess.hasGrant(context, uri, write = true) && it.isDirectory && it.name == "user" && it.canWrite()
        }
    }

    fun snapshot(context: Context): Map<String, Any?> = synchronized(InstallationSafAccessCoordinator.lock) {
        val preferences = prefs(context)
        var saved = preferences.getString(KEY, null)
        if (saved == null) {
            // A legacy grant to mods alone never grants its parent. Promote only an actual user tree.
            val legacy = listOf(ModInstallerPlugin.KEY_TREE_URI, ModInstallerPlugin.KEY_DYNOS_TREE_URI)
                .mapNotNull { preferences.getString(it, null) }
                .mapNotNull { runCatching { GameFolderAccess.grantUri(Uri.parse(it)) }.getOrNull() }
                .firstOrNull { GameFolderAccess.resolve(context, it)?.name == "user" && GameFolderAccess.hasGrant(context, it, write = true) }
            if (legacy != null) {
                try { connect(context, legacy, Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION); saved = legacy.toString() }
                catch (error: Exception) { if (error.message != "installing") throw error }
            }
        }
        val root = root(context)
        val actualMods = root?.findFile("mods")?.uri?.toString()
        val actualPacks = root?.findFile("dynos")?.takeIf { it.isDirectory }?.findFile("packs")?.uri?.toString()
        if (root != null && (preferences.getInt("unified_game_folder_version", 0) != 1 ||
            actualMods != preferences.getString(ModInstallerPlugin.KEY_TREE_URI, null) ||
            actualPacks != preferences.getString(ModInstallerPlugin.KEY_DYNOS_TREE_URI, null) || actualMods == null || actualPacks == null)) {
            try { connect(context, Uri.parse(saved!!), Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION) }
            catch (error: Exception) { if (error.message != "installing") throw error }
        }
        if (saved != null && root == null) {
            preferences.edit().remove(KEY).remove(ModInstallerPlugin.KEY_TREE_URI).remove(ModInstallerPlugin.KEY_DYNOS_TREE_URI)
                .putBoolean(ModInstallerPlugin.KEY_TREE_PERMISSION_REVOKED, true)
                .putBoolean(ModInstallerPlugin.KEY_DYNOS_TREE_PERMISSION_REVOKED, true).commit()
        }
        val mods = root?.findFile("mods")?.takeIf { it.isDirectory }
        val packs = root?.findFile("dynos")?.takeIf { it.isDirectory }?.findFile("packs")?.takeIf { it.isDirectory }
        val unified = root != null && mods != null && packs != null &&
            preferences.getString(ModInstallerPlugin.KEY_TREE_URI, null) == mods.uri.toString() &&
            preferences.getString(ModInstallerPlugin.KEY_DYNOS_TREE_URI, null) == packs.uri.toString()
        mapOf("unified" to unified, "dismissed" to preferences.getBoolean("game_setup_dismissed", false), "connected" to (root != null), "status" to (if (root != null && !unified) "installing" else if (root != null) "ready" else if (saved != null || preferences.getBoolean(ModInstallerPlugin.KEY_TREE_PERMISSION_REVOKED, false) || preferences.getBoolean(ModInstallerPlugin.KEY_DYNOS_TREE_PERMISSION_REVOKED, false)) "access" else "unselected"),
            "mods" to (mods != null),
            "dynos" to (packs != null),
            "config" to (root?.findFile("sm64config.txt")?.isFile == true),
            "rom" to (root?.listFiles()?.any { it.isFile && it.name?.endsWith(".z64", true) == true } == true),
            "modsUri" to preferences.getString(ModInstallerPlugin.KEY_TREE_URI, null),
            "dynosUri" to preferences.getString(ModInstallerPlugin.KEY_DYNOS_TREE_URI, null))
    }

    fun disconnect(context: Context) = synchronized(InstallationSafAccessCoordinator.lock) {
        synchronized(InstallationSafAccessCoordinator.selectionLock) {
        requireIdle(context)
        val preferences = prefs(context)
        val saved = preferences.getString(KEY, null)
        val keys = listOf(KEY, ModInstallerPlugin.KEY_TREE_URI, ModInstallerPlugin.KEY_DYNOS_TREE_URI, "unified_game_folder_version")
        val previous = keys.associateWith { preferences.all[it] }
        if (!preferences.edit().remove(KEY).remove(ModInstallerPlugin.KEY_TREE_URI).remove(ModInstallerPlugin.KEY_DYNOS_TREE_URI).remove("unified_game_folder_version").commit()) {
            val restore = preferences.edit()
            previous.forEach { (key, value) -> when (value) {
                is String -> restore.putString(key, value)
                is Int -> restore.putInt(key, value)
                else -> restore.remove(key)
            } }
            restore.commit()
            error("access")
        }
        if (saved != null) runCatching { context.contentResolver.releasePersistableUriPermission(Uri.parse(saved),
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION) }
        // No resources, config, installation receipts or game files are deleted.
        }
    }
}

package mods.sm64cdpy

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import java.io.IOException

/**
 * Bounded verifier for durable installation receipts.
 *
 * It never scans a complete SAF tree. Each receipt is checked only through
 * its (at most 32) exact sentinel paths. Calls are serialized because some
 * document providers become unstable when many directory queries overlap.
 */
object InstallationSafVerifier {
    private val verificationLock = Any()

    fun verify(
        context: Context,
        receipts: List<Map<String, Any?>>,
        requestedArtifactKeys: Set<String>? = null
    ): Map<String, Any?> = synchronized(verificationLock) {
        val selected = receipts.asSequence()
            .filter { requestedArtifactKeys == null || it["artifactKey"] in requestedArtifactKeys }
            .toList()
        val prefs = context.getSharedPreferences(
            ModInstallerPlugin.PREF_NAME,
            Context.MODE_PRIVATE
        )
        val roots = mutableMapOf<String, RootAccess>()
        val verifiedAt = java.time.Instant.now().toString()
        val results = selected.map { receipt ->
            val artifactKey = receipt["artifactKey"] as String
            val destination = receipt["destination"] as String
            val root = roots.getOrPut(destination) {
                resolveRoot(
                    context,
                    prefs.getString(preferenceKey(destination), null),
                    prefs.getBoolean(permissionMarkerKey(destination), false)
                )
            }
            verifyReceipt(root, receipt, artifactKey, verifiedAt)
        }
        mapOf(
            "schemaVersion" to 1,
            "verifiedAt" to verifiedAt,
            "results" to results
        )
    }

    private fun preferenceKey(destination: String): String = when (destination) {
        "mods" -> ModInstallerPlugin.KEY_TREE_URI
        "dynos" -> ModInstallerPlugin.KEY_DYNOS_TREE_URI
        else -> throw IllegalArgumentException("Unsupported installation destination")
    }

    private fun permissionMarkerKey(destination: String): String = when (destination) {
        "mods" -> ModInstallerPlugin.KEY_TREE_PERMISSION_REVOKED
        "dynos" -> ModInstallerPlugin.KEY_DYNOS_TREE_PERMISSION_REVOKED
        else -> throw IllegalArgumentException("Unsupported installation destination")
    }

    private sealed interface RootAccess {
        data class Available(val root: DocumentFile) : RootAccess
        data object NotSelected : RootAccess
        data object PermissionRevoked : RootAccess
        data object Unavailable : RootAccess
    }

    private fun resolveRoot(
        context: Context,
        uriString: String?,
        permissionWasRevoked: Boolean
    ): RootAccess {
        if (uriString == null) {
            return if (permissionWasRevoked) RootAccess.PermissionRevoked
            else RootAccess.NotSelected
        }
        val uri = try {
            Uri.parse(uriString)
        } catch (_: Exception) {
            return RootAccess.PermissionRevoked
        }
        val hasReadGrant = context.contentResolver.persistedUriPermissions.any {
            it.uri == uri && it.isReadPermission
        }
        if (!hasReadGrant) return RootAccess.PermissionRevoked
        return try {
            val root = DocumentFile.fromTreeUri(context, uri)
                ?: return RootAccess.Unavailable
            if (!root.exists() || !root.canRead()) RootAccess.PermissionRevoked
            else RootAccess.Available(root)
        } catch (_: SecurityException) {
            RootAccess.PermissionRevoked
        } catch (_: Exception) {
            RootAccess.Unavailable
        }
    }

    private fun verifyReceipt(
        access: RootAccess,
        receipt: Map<String, Any?>,
        artifactKey: String,
        verifiedAt: String
    ): Map<String, Any?> {
        val base = mutableMapOf<String, Any?>(
            "artifactKey" to artifactKey,
            "verifiedAt" to verifiedAt
        )
        when (access) {
            RootAccess.NotSelected -> return base.apply { put("status", "folderNotSelected") }
            RootAccess.PermissionRevoked -> return base.apply { put("status", "permissionRevoked") }
            RootAccess.Unavailable -> return base.apply { put("status", "unknown") }
            is RootAccess.Available -> Unit
        }
        return try {
            @Suppress("UNCHECKED_CAST")
            val sentinels = receipt["sentinels"] as List<Map<String, Any?>>
            val directoryCache = mutableMapOf<String, DocumentFile>("" to access.root)
            val missingPath = sentinels.asSequence()
                .map { it["relativePath"] as String }
                .firstOrNull { !fileExists(access.root, it, directoryCache) }
            base.apply {
                put("status", if (missingPath == null) "present" else "missing")
                if (missingPath != null) put("missingPath", missingPath)
            }
        } catch (_: SecurityException) {
            base.apply { put("status", "permissionRevoked") }
        } catch (_: IOException) {
            base.apply { put("status", "unknown") }
        } catch (_: Exception) {
            base.apply { put("status", "unknown") }
        }
    }

    private fun fileExists(
        root: DocumentFile,
        relativePath: String,
        directoryCache: MutableMap<String, DocumentFile>
    ): Boolean {
        val segments = relativePath.split('/').filter(String::isNotEmpty)
        if (segments.isEmpty()) return false
        var directory = root
        var currentPath = ""
        for (segment in segments.dropLast(1)) {
            currentPath = if (currentPath.isEmpty()) segment else "$currentPath/$segment"
            directory = directoryCache[currentPath]
                ?: directory.findFile(segment)?.takeIf { it.isDirectory }?.also {
                    directoryCache[currentPath] = it
                }
                ?: return false
        }
        return directory.findFile(segments.last())?.let { it.isFile && it.exists() } == true
    }
}

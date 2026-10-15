package mods.sm64cdpy

import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile

/** Resolves a descendant document through its original persisted tree grant. */
internal object GameFolderAccess {
    fun grantUri(uri: Uri): Uri = DocumentsContract.buildTreeDocumentUri(
        requireNotNull(uri.authority), DocumentsContract.getTreeDocumentId(uri))

    fun hasGrant(context: Context, uri: Uri, write: Boolean = false): Boolean = runCatching {
        val grant = grantUri(uri)
        context.contentResolver.persistedUriPermissions.any {
            it.uri == grant && it.isReadPermission && (!write || it.isWritePermission)
        }
    }.getOrDefault(false)

    fun resolve(context: Context, uri: Uri): DocumentFile? = runCatching {
        if (!hasGrant(context, uri)) return@runCatching null
        val root = DocumentFile.fromTreeUri(context, grantUri(uri)) ?: return@runCatching null
        val id = if (DocumentsContract.isDocumentUri(context, uri)) DocumentsContract.getDocumentId(uri)
            else DocumentsContract.getTreeDocumentId(uri)
        GameFolderLayout.resolve(root, id,
            id = { DocumentsContract.getDocumentId(it.uri) },
            child = { directory, name -> if (directory.isDirectory) directory.findFile(name) else null })
    }.getOrNull()
}

package mods.sm64cdpy

import java.io.File
import java.io.IOException

/** Direct paths are derived only from primary external-storage document IDs. */
internal object DirectInstallPaths {
    fun root(base: File, documentId: String): File? {
        if (!documentId.startsWith("primary:")) return null
        val relative = documentId.removePrefix("primary:")
        if (relative.isEmpty() || relative.startsWith('/') || relative.contains('\\')) return null
        val parts = relative.split('/')
        if (parts.any { it.isEmpty() || it == "." || it == ".." || it.contains('\u0000') }) return null
        if (parts.first().equals("Android", ignoreCase = true)) return null
        val storage = base.canonicalFile
        val lexical = File(storage, relative).absoluteFile
        val canonical = lexical.canonicalFile
        // Do not follow symlinks, including aliases leading into Android/.
        return canonical.takeIf { it == lexical && it.path.startsWith(storage.path + File.separator) }
    }

    fun child(root: File, relative: String): File {
        val parts = relative.split('/')
        if (parts.any { it.isEmpty() || it == "." || it == ".." || it.contains('\\') || it.contains('\u0000') }) {
            throw IOException("Invalid installation path")
        }
        val base = root.canonicalFile
        val lexical = File(base, relative).absoluteFile
        val canonical = lexical.canonicalFile
        if (canonical != lexical || !canonical.path.startsWith(base.path + File.separator)) {
            throw IOException("Installation path leaves selected folder")
        }
        return canonical
    }
}

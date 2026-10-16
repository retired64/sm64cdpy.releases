package mods.sm64cdpy

import android.content.Context
import android.os.Build
import androidx.documentfile.provider.DocumentFile
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest
import java.util.zip.ZipFile

/** Supplies bounded, private copies of the inputs used by the local 3D parser. */
internal object Player3DSource {
    private const val GAME_PACKAGE = "com.maniscat2.sm64coopdx"
    private const val MAX_LIBRARY_BYTES = 160L * 1024 * 1024

    data class Inputs(val game: File, val rom: File)

    fun prepare(context: Context): Inputs {
        val directory = File(context.cacheDir, "player3d").apply { mkdirs() }
        val info = context.packageManager.getApplicationInfo(GAME_PACKAGE, 0)
        val stamp = (listOf(info.sourceDir) + info.splitSourceDirs?.toList().orEmpty())
            .joinToString("|") { path -> "$path:${File(path).length()}:${File(path).lastModified()}" }
        val game = File(directory, "game-${stamp.hashCode().toUInt().toString(16)}.so")
        if (!game.isFile || game.length() !in 1..MAX_LIBRARY_BYTES) {
            directory.listFiles { file -> file.name.startsWith("game-") }?.forEach(File::delete)
            copyGameLibrary(info.sourceDir, info.splitSourceDirs?.toList().orEmpty(), game)
        }
        val rom = File(directory, "baserom.us.z64")
        if (!validRom(rom)) copyRom(context, rom)
        return Inputs(game, rom)
    }

    private fun copyGameLibrary(base: String, splits: List<String>, output: File) {
        val temporary = File(output.path + ".part")
        temporary.delete()
        for (abi in Build.SUPPORTED_ABIS) {
            for (apk in listOf(base) + splits) {
                ZipFile(apk).use { zip ->
                    val entry = zip.getEntry("lib/$abi/libmain.so") ?: return@use
                    require(entry.size in 1..MAX_LIBRARY_BYTES) { "game_library_size" }
                    zip.getInputStream(entry).use { input ->
                        FileOutputStream(temporary).use { target ->
                            val copied = input.copyTo(target, 64 * 1024)
                            require(copied == entry.size && copied <= MAX_LIBRARY_BYTES) { "game_library_read" }
                            target.fd.sync()
                        }
                    }
                    require(temporary.renameTo(output)) { "game_library_cache" }
                    return
                }
            }
        }
        error("game_library_missing")
    }

    private fun copyRom(context: Context, output: File) {
        val root = GameFolderStore.root(context) ?: error("game_folder")
        val candidates = root.listFiles().filter { it.isFile && it.name?.endsWith(".z64", true) == true }
            .sortedByDescending { it.name.equals("baserom.us.z64", true) }
            .take(8)
        val temporary = File(output.path + ".part")
        for (candidate in candidates) {
            temporary.delete()
            val copied = runCatching {
                context.contentResolver.openInputStream(candidate.uri).use { input ->
                    requireNotNull(input)
                    FileOutputStream(temporary).use { target ->
                        val buffer = ByteArray(64 * 1024)
                        var total = 0L
                        while (true) {
                            val count = input.read(buffer)
                            if (count < 0) break
                            total += count
                            require(total <= MarioRomDecoder.ROM_SIZE) { "rom_size" }
                            target.write(buffer, 0, count)
                        }
                        target.fd.sync()
                        total
                    }
                }
            }.getOrNull()
            if (copied == MarioRomDecoder.ROM_SIZE.toLong() && validRom(temporary)) {
                output.delete()
                require(temporary.renameTo(output)) { "rom_cache" }
                return
            }
        }
        temporary.delete()
        error("rom_missing")
    }

    private fun validRom(file: File): Boolean {
        if (!file.isFile || file.length() != MarioRomDecoder.ROM_SIZE.toLong()) return false
        val digest = MessageDigest.getInstance("MD5")
        file.inputStream().use { input ->
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                digest.update(buffer, 0, count)
            }
        }
        return digest.digest().joinToString("") { "%02x".format(it.toInt() and 255) } == MarioRomDecoder.ROM_MD5
    }
}

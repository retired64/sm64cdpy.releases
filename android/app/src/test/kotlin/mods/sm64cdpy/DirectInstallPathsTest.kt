package mods.sm64cdpy

import java.io.File
import java.nio.file.Files
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class DirectInstallPathsTest {
    @get:Rule val temporary = TemporaryFolder()

    @Test fun `mods and DynOS resolve in both root layouts`() {
        val storage = temporary.newFolder("storage")
        for (path in listOf("mods", "user/mods", "dynos/packs", "user/dynos/packs")) {
            val relative = "com.maniscat2.sm64coopdx/$path"
            assertEquals(File(storage, relative).canonicalFile,
                DirectInstallPaths.root(storage, "primary:$relative"))
        }
    }

    @Test fun `opaque IDs nonprimary volumes and Android trees never become direct paths`() {
        val storage = temporary.newFolder("storage")
        for (id in listOf("opaque", "1234:mods", "primary:", "primary:Android/data/game",
            "primary:android/obb/game", "primary:../outside", "primary:game/../Android/data",
            "primary:/game", "primary:game//mods", "primary:game\\mods")) {
            assertNull(id, DirectInstallPaths.root(storage, id))
        }
    }

    @Test fun `symlinks cannot redirect a root or child outside its destination`() {
        val storage = temporary.newFolder("storage")
        val outside = temporary.newFolder("outside")
        Files.createSymbolicLink(File(storage, "alias").toPath(), outside.toPath())
        assertNull(DirectInstallPaths.root(storage, "primary:alias/mods"))
        try {
            DirectInstallPaths.child(storage, "alias/overwrite.lua")
            fail("Must reject symlink")
        } catch (_: java.io.IOException) { }
        assertFalse(File(outside, "overwrite.lua").exists())
    }

    @Test fun `child traversal is rejected before any write`() {
        val root = temporary.newFolder("root")
        for (path in listOf("../escape", "/escape", "a/../escape", "a\\escape", "")) {
            try { DirectInstallPaths.child(root, path); fail(path) }
            catch (_: java.io.IOException) { }
        }
        assertEquals(File(root, "pack/main.lua"), DirectInstallPaths.child(root, "pack/main.lua"))
    }
}

package mods.sm64cdpy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class SafZipExtractorManifestTest {
    @Test
    fun `loose file keeps its exact path`() {
        val manifest = SafZipExtractor.buildManifestForPaths(
            listOf("sample-loose.lua"),
            looseFile = true
        )

        assertEquals(1, manifest.fileCount)
        assertEquals(SafZipExtractor.PackageShape.LOOSE_FILE, manifest.packageShape)
        assertEquals(listOf("sample-loose.lua"), manifest.sentinels.map { it.relativePath })
    }

    @Test
    fun `single root prioritizes lua entrypoint`() {
        val manifest = SafZipExtractor.buildManifestForPaths(
            listOf("sample/assets/icon.txt", "sample/main.lua", "sample/config.txt")
        )

        assertEquals(SafZipExtractor.PackageShape.SINGLE_ROOT, manifest.packageShape)
        assertEquals("sample/main.lua", manifest.sentinels.first().relativePath)
        assertEquals(3, manifest.fileCount)
    }

    @Test
    fun `multiple roots retain proof from every small fixture root`() {
        val manifest = SafZipExtractor.buildManifestForPaths(
            listOf("beta/data.txt", "alpha/main.lua", "beta/mod.lua")
        )

        assertEquals(SafZipExtractor.PackageShape.MULTIPLE_ROOTS, manifest.packageShape)
        assertTrue(manifest.sentinels.any { it.relativePath.startsWith("alpha/") })
        assertTrue(manifest.sentinels.any { it.relativePath.startsWith("beta/") })
    }

    @Test
    fun `root files are distinguished from a single root directory`() {
        val manifest = SafZipExtractor.buildManifestForPaths(
            listOf("main.lua", "config.txt")
        )

        assertEquals(SafZipExtractor.PackageShape.ROOT_FILES, manifest.packageShape)
    }

    @Test
    fun `sentinel set is deterministic and capped`() {
        val paths = (99 downTo 0).map { "root-$it/file-$it.txt" }
        val first = SafZipExtractor.buildManifestForPaths(paths)
        val second = SafZipExtractor.buildManifestForPaths(paths.reversed())

        assertEquals(100, first.fileCount)
        assertEquals(32, first.sentinels.size)
        assertEquals(first.sentinels, second.sentinels)
    }

    @Test
    fun `paths are sanitized before becoming sentinels`() {
        val manifest = SafZipExtractor.buildManifestForPaths(
            listOf("../safe\\main.lua", "/safe/./asset.txt")
        )

        assertEquals(
            listOf("safe/main.lua", "safe/asset.txt"),
            manifest.sentinels.map { it.relativePath }
        )
    }
}

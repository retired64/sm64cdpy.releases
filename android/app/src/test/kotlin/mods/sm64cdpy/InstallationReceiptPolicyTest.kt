package mods.sm64cdpy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class InstallationReceiptPolicyTest {
    private val old = InstallationReceiptPolicy.Candidate(
        artifactKey = "v1|mods|content|old",
        contentKey = "v1|mods|content",
        versionLabel = "v1.2"
    )

    @Test
    fun `same artifact is a reinstall`() {
        assertEquals(
            "reinstall",
            InstallationReceiptPolicy.classify(
                old.artifactKey,
                old.contentKey,
                "v1.2",
                listOf(old)
            )
        )
    }

    @Test
    fun `newer comparable artifact is an update`() {
        assertEquals(
            "update",
            InstallationReceiptPolicy.classify(
                "v1|mods|content|new",
                old.contentKey,
                "v2.0",
                listOf(old)
            )
        )
    }

    @Test
    fun `older or prose artifact remains a separate install`() {
        assertEquals(
            "install",
            InstallationReceiptPolicy.classify(
                "v1|mods|content|older",
                old.contentKey,
                "v1.0",
                listOf(old)
            )
        )
        assertFalse(InstallationReceiptPolicy.isReliableUpgrade("alpha", "beta"))
        assertTrue(InstallationReceiptPolicy.isReliableUpgrade("v1.9", "v2.0"))
    }

    @Test
    fun `confirmed update projects the older receipt as replaced`() {
        fun receipt(
            artifact: String,
            version: String,
            installedAt: String,
            eventKind: String
        ): Map<String, Any?> = mapOf(
            "artifactKey" to artifact,
            "contentKey" to "v1|mods|content",
            "installedAt" to installedAt,
            "eventKind" to eventKind,
            "supersedesArtifactKeys" to if (eventKind == "update") listOf("old") else emptyList<String>(),
            "displaySnapshot" to mapOf<String, Any?>("versionLabel" to version)
        )

        val projected = InstallationReceiptStore.projectReplacements(
            listOf(
                receipt("old", "v1.0", "2026-09-26T10:00:00Z", "install"),
                receipt("new", "v2.0", "2026-09-27T10:00:00Z", "update")
            )
        )

        assertEquals("new", projected.first()["replacedByArtifactKey"])
        assertEquals(null, projected.last()["replacedByArtifactKey"])
    }

    @Test
    fun `reinstall keeps persisted replacement lineage`() {
        val projected = InstallationReceiptStore.projectReplacements(
            listOf(
                mapOf(
                    "artifactKey" to "old",
                    "contentKey" to "v1|mods|content",
                    "installedAt" to "2026-09-26T10:00:00Z",
                    "eventKind" to "install",
                    "supersedesArtifactKeys" to emptyList<String>(),
                    "displaySnapshot" to mapOf<String, Any?>("versionLabel" to "v1.0")
                ),
                mapOf(
                    "artifactKey" to "new",
                    "contentKey" to "v1|mods|content",
                    "installedAt" to "2026-09-27T12:00:00Z",
                    "eventKind" to "reinstall",
                    "supersedesArtifactKeys" to listOf("old"),
                    "displaySnapshot" to mapOf<String, Any?>("versionLabel" to "v2.0")
                )
            )
        )

        assertEquals("new", projected.first()["replacedByArtifactKey"])
    }
}

package mods.sm64cdpy

import java.io.File
import androidx.documentfile.provider.DocumentFile
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class DirectInstallJournalTest {
    @get:Rule val temporary = TemporaryFolder()

    @Test fun `direct rollback removes new partial files but preserves existing entries`() {
        val root = temporary.newFolder("destination")
        val existing = File(root, "existing.lua").apply { writeText("existing") }
        val directory = File(root, "partial").apply { mkdir() }
        val partial = File(directory, "main.lua").apply { writeText("partial") }
        val journal = SafZipExtractor.WriteJournal()
        journal.useDirectRoot(root)
        journal.recordFile("existing.lua", true)
        journal.recordDirectory("partial", false)
        journal.recordFile("partial/main.lua", false)
        journal.rollback(DocumentFile.fromFile(root))
        journal.rollback(DocumentFile.fromFile(root)) // idempotent
        assertFalse(partial.exists())
        assertFalse(directory.exists())
        assertEquals("existing", existing.readText())
    }
}

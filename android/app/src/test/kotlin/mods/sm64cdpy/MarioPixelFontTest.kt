package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test
import java.awt.Font
import java.io.ByteArrayInputStream

class MarioPixelFontTest {
    @Test fun generatedPixelFontLoadsAndSupportsOnlyMappedCharacters() {
        // Synthetic abstract glyph, not Nintendo artwork.
        val pixels = IntArray(64) { if (it % 8 == 1 || it / 8 == 2) -1 else 0 }
        val fontBytes = MarioPixelFont.build("Synthetic Pixel Test", mapOf('A' to MarioPixelFont.Glyph(pixels, 8, 8)))
        val font = Font.createFont(Font.TRUETYPE_FONT, ByteArrayInputStream(fontBytes))
        assertEquals("Synthetic Pixel Test", font.family)
        assertTrue(font.canDisplay('A'))
        assertTrue(font.canDisplay(' '))
        assertFalse(font.canDisplay('é'))
        assertTrue(fontBytes.size < 262144)
        var checksum = 0L
        for (i in fontBytes.indices step 4) {
            var value = 0L
            for (j in 0..3) value = (value shl 8) or (fontBytes[i + j].toLong() and 255)
            checksum = (checksum + value) and 0xffffffffL
        }
        assertEquals(0xb1b0afbaL, checksum)
    }
}

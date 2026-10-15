package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test

class MarioRomDecoderTest {
    private fun segment(size: Int, controls: ByteArray, pairs: ByteArray, literals: ByteArray): ByteArray {
        val header = java.nio.ByteBuffer.allocate(16).putInt(0x4d494f30).putInt(size)
            .putInt(16 + controls.size).putInt(16 + controls.size + pairs.size).array()
        return header + controls + pairs + literals
    }
    @Test fun literalAndOverlappingBackreference() {
        // AB + six bytes copied at distance two -> ABABABAB.
        val input = segment(8, byteArrayOf(0xc0.toByte()), byteArrayOf(0x30, 0x01), "AB".toByteArray())
        assertArrayEquals("ABABABAB".toByteArray(), MarioRomDecoder.decompress(input))
    }
    @Test fun invalidBackreferenceIsRejected() {
        val input = segment(3, byteArrayOf(0), byteArrayOf(0, 0), byteArrayOf())
        assertThrows(IllegalArgumentException::class.java) { MarioRomDecoder.decompress(input) }
    }
    @Test fun truncatedLiteralAndOversizedOutputAreRejected() {
        assertThrows(IllegalArgumentException::class.java) {
            MarioRomDecoder.decompress(segment(1, byteArrayOf(0x80.toByte()), byteArrayOf(), byteArrayOf()))
        }
        assertThrows(IllegalArgumentException::class.java) {
            MarioRomDecoder.decompress(segment(Int.MAX_VALUE, byteArrayOf(), byteArrayOf(), byteArrayOf()))
        }
    }
    @Test fun rgba5551PreservesColorsAndAlpha() {
        val data = byteArrayOf(0xf8.toByte(), 1, 0x07, 0xc1.toByte(), 0, 0x3f, 0xff.toByte(), 0xfe.toByte())
        val t = MarioRomDecoder.Texture("test", 0, 8, 0, 4, 1)
        assertArrayEquals(intArrayOf(0xffff0000.toInt(), 0xff00ff00.toInt(), 0xff0000ff.toInt(), 0x00ffffff), MarioRomDecoder.pixels(data, t))
        assertThrows(IllegalArgumentException::class.java) { MarioRomDecoder.pixels(data.copyOf(7), t) }
    }
    @Test fun intensityFormatsAndFullOpacityPanelContrast() {
        val ia8 = MarioRomDecoder.Texture("test", 0, 2, 0, 2, 1, "ia8")
        assertArrayEquals(intArrayOf(-1, 0), MarioRomDecoder.pixels(byteArrayOf(0xff.toByte(), 0), ia8))
        val ia4 = ia8.copy(format = "ia4")
        assertArrayEquals(intArrayOf(-1, 0), MarioRomDecoder.pixels(byteArrayOf(0xf0.toByte()), ia4))
        val light = MarioRomDecoder.panelPixels(intArrayOf(0xff000000.toInt(), -1), false)
        val dark = MarioRomDecoder.panelPixels(intArrayOf(0xff000000.toInt(), -1), true)
        assertEquals(190, light[0] and 255); assertEquals(255, light[1] and 255)
        assertEquals(24, dark[0] and 255); assertEquals(72, dark[1] and 255)
    }
    @Test fun manifestIdsAreUniqueAndGeometryAssetsStayBounded() {
        val ids = MarioRomDecoder.textures.map { it.id }
        assertEquals(ids.size, ids.toSet().size)
        assertTrue(ids.containsAll(('A'..'Z').map { "menu_glyph_$it" }))
        assertTrue(ids.containsAll(('a'..'z').map { "dialog_glyph_$it" }))
        assertEquals(147, ids.size)
        assertEquals(4, MarioRomDecoder.generatedImages.size)
    }

}

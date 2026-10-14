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
}

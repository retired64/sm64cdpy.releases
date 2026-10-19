package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test
import java.nio.ByteBuffer
import java.nio.ByteOrder

class GameSaveCodecTest {
    private fun fixture(order: ByteOrder = ByteOrder.BIG_ENDIAN): ByteArray {
        val bytes = ByteArray(512)
        val b = ByteBuffer.wrap(bytes).order(order)
        fun sign(at: Int, size: Int, magic: Int) {
            b.putShort(at + size - 4, magic.toShort())
            b.putShort(at + size - 2, ((at until at + size - 2).sumOf { bytes[it].toInt() and 255 } and 65535).toShort())
        }
        for (slot in 0..7) sign(slot * 56, 56, 0x4441)
        sign(448, 32, 0x4849); sign(480, 32, 0x4849)
        return bytes
    }
    @Test fun `endian roundtrip preserves alternate copy and unrelated bytes`() {
        for (order in listOf(ByteOrder.BIG_ENDIAN, ByteOrder.LITTLE_ENDIAN)) {
            val original = fixture(order)
            val codec = GameSaveCodec(original)
            codec.edit(0, 0, List(25) { if (it == 0) 127 else 0 }, List(15) { 0 }, List(15) { it == 0 }, 1, 0)
            assertEquals(order, GameSaveCodec(codec.bytes).order)
            assertTrue(GameSaveCodec(codec.bytes).valid(0, 0))
            assertArrayEquals(original.sliceArray(56..511), codec.bytes.sliceArray(56..511))
            assertEquals(100, codec.coins(0, 0)[0])
            assertEquals(127, codec.bytes[12].toInt() and 255)
            assertEquals(128, codec.bytes[13].toInt() and 255)
            assertEquals(8, codec.total(0, 0))
        }
    }
    @Test fun `removing castle stars produces exact zero`() {
        val codec = GameSaveCodec(fixture())
        codec.edit(0, 1, List(25) { 0 }, List(15) { 0 }, List(15) { false }, 31, 0)
        assertEquals(5, codec.total(0, 1))
        codec.edit(0, 1, List(25) { 0 }, List(15) { 0 }, List(15) { false }, 0, 0)
        assertEquals(0, codec.total(0, 1))
        assertTrue(codec.valid(0, 1))
    }
    @Test fun `copy retains distinct alternate data and erase signs main`() {
        val codec = GameSaveCodec(fixture())
        codec.edit(0, 0, List(25) { 0 }, List(15) { 0 }, List(15) { false }, 1, 0)
        codec.edit(0, 1, List(25) { 0 }, List(15) { 0 }, List(15) { false }, 3, 0)
        codec.copy(0, 2)
        assertEquals(1, codec.total(2, 0)); assertEquals(2, codec.total(2, 1))
        codec.erase(2)
        assertTrue(codec.valid(2, 0)); assertTrue(codec.empty(2, 1))
        assertEquals(0, codec.total(2, 0))
    }
    @Test fun `fresh zero menu is preserved when copying and erasing`() {
        val bytes = fixture()
        bytes.fill(0, 448, 512)
        val codec = GameSaveCodec(bytes)
        codec.copy(0, 1)
        codec.erase(1)
        assertArrayEquals(ByteArray(64), codec.bytes.sliceArray(448..511))
    }
    @Test fun `coin display matches game minimum for hundred coin star`() {
        val bytes = fixture()
        bytes[12] = 64
        assertEquals(100, GameSaveCodec(bytes).coins(0, 0)[0])
    }
    @Test fun `editing progress without coins preserves raw records in both byte orders`() {
        for (order in listOf(ByteOrder.BIG_ENDIAN, ByteOrder.LITTLE_ENDIAN)) {
            val codec = GameSaveCodec(fixture(order))
            codec.edit(0, 0, List(25) { 0 }, List(15) { it * 13 }, List(15) { false }, 0, 0)
            val records = codec.bytes.sliceArray(37..51)
            val untouched = codec.bytes.sliceArray(56..511)
            // Even the 120-star preset must preserve the original coin bytes.
            codec.edit(0, 0, GameSaveCodec.maxStars.map { (1 shl it) - 1 }, null, List(15) { true }, 31, 0x10ffff)
            assertArrayEquals(records, codec.bytes.sliceArray(37..51))
            assertArrayEquals(untouched, codec.bytes.sliceArray(56..511))
            assertTrue(codec.valid(0, 0))
            assertEquals(120, codec.total(0, 0))
        }
    }
    @Test(expected = IllegalArgumentException::class) fun `rejects wrong size`() { GameSaveCodec(ByteArray(513)) }
    @Test(expected = IllegalArgumentException::class) fun `rejects corrupt source instead of signing it`() {
        val bytes = fixture(); bytes[3] = 11
        GameSaveCodec(bytes).edit(0, 0, List(25) { 0 }, List(15) { 0 }, List(15) { false }, 0, 0)
    }
}

package mods.sm64cdpy

/** Small, bounded decoder for the US vanilla ROM. No game code or artwork is bundled. */
internal object MarioRomDecoder {
    const val ROM_SIZE = 8 * 1024 * 1024
    const val ROM_MD5 = "20b854b239203baf6c961b850a4a51a2"
    const val VERSION = 1
    data class Texture(val id: String, val segment: Int, val segmentBytes: Int,
                       val offset: Int, val width: Int, val height: Int)
    // Addresses from CoopDX levels/menu/leveldata.c and bin/segment2.c (US).
    val textures = listOf(
        Texture("stone", 0x2a65b0, 22255, 0x18, 32, 32),
        Texture("stone_dark", 0x2a65b0, 22255, 0x818, 32, 32),
        Texture("hand", 0x2a65b0, 22255, 0x6328, 32, 32),
        Texture("hand_pressed", 0x2a65b0, 22255, 0x6b28, 32, 32),
        Texture("star", 0x108a40, 48390, 0x4800, 16, 16)
    ) + (0..9).map { Texture("digit_$it", 0x108a40, 48390, it * 512, 16, 16) }

    fun decompress(input: ByteArray): ByteArray {
        require(input.size >= 16) { "Truncated segment" }
        fun word(offset: Int): Int {
            require(offset >= 0 && offset + 4 <= input.size)
            val value = (0..3).fold(0L) { acc, i -> (acc shl 8) or (input[offset + i].toLong() and 255) }
            require(value <= Int.MAX_VALUE)
            return value.toInt()
        }
        require(word(0) == 0x4d494f30) { "Expected MIO0" }
        val size = word(4)
        require(size in 1..(2 * 1024 * 1024)) { "Invalid decompressed size" }
        var pairs = word(8)
        var raw = word(12)
        require(pairs in 16..input.size && raw in pairs..input.size)
        val pairEnd = raw
        val controlEnd = pairs
        val output = ByteArray(size)
        var control = 16
        var mask = 0
        var bits = 0
        var cursor = 0
        while (cursor < size) {
            if (mask == 0) {
                require(control < controlEnd) { "Truncated controls" }
                bits = input[control++].toInt() and 255
                mask = 128
            }
            if (bits and mask != 0) {
                require(raw < input.size) { "Truncated literal" }
                output[cursor++] = input[raw++]
            } else {
                require(pairs + 2 <= pairEnd) { "Truncated backreference" }
                val pair = ((input[pairs++].toInt() and 255) shl 8) or (input[pairs++].toInt() and 255)
                val count = (pair ushr 12) + 3
                val distance = (pair and 4095) + 1
                require(distance <= cursor && count <= size - cursor) { "Invalid backreference" }
                repeat(count) { output[cursor] = output[cursor - distance]; cursor++ }
            }
            mask = mask ushr 1
        }
        return output
    }

    fun pixels(segment: ByteArray, texture: Texture): IntArray {
        val count = texture.width * texture.height
        require(texture.offset >= 0 && texture.offset.toLong() + count * 2 <= segment.size)
        fun expand(value: Int) = value * 255 / 31
        return IntArray(count) { i ->
            val index = texture.offset + i * 2
            val value = ((segment[index].toInt() and 255) shl 8) or (segment[index + 1].toInt() and 255)
            val alpha = if (value and 1 != 0) 255 else 0
            (alpha shl 24) or (expand(value ushr 11) shl 16) or
                (expand((value ushr 6) and 31) shl 8) or expand((value ushr 1) and 31)
        }
    }
}

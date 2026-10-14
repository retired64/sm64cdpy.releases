package mods.sm64cdpy

import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** TrueType outlines made from imported ROM pixels; no glyph artwork is compiled into the APK. */
internal object MarioPixelFont {
    data class Glyph(val pixels: IntArray, val width: Int, val height: Int, val advance: Int = width + 1)
    private fun bytes(block: DataOutputStream.() -> Unit): ByteArray {
        val output = ByteArrayOutputStream()
        DataOutputStream(output).use { it.block() }
        return output.toByteArray()
    }
    private fun checksum(data: ByteArray): Long {
        var sum = 0L
        for (i in data.indices step 4) {
            var word = 0L
            for (j in 0..3) word = (word shl 8) or (if (i + j < data.size) data[i + j].toLong() and 255 else 0)
            sum = (sum + word) and 0xffffffffL
        }
        return sum
    }
    fun build(family: String, characters: Map<Char, Glyph>): ByteArray {
        require(characters.isNotEmpty() && characters.size <= 128)
        val codes = characters.keys.sorted()
        val glyphs = listOf<Glyph?>(null, null) + codes.map { characters.getValue(it) }
        val offsets = mutableListOf(0)
        val glyfStream = ByteArrayOutputStream()
        val advances = mutableListOf<Int>()
        var maxPoints = 0
        for (glyph in glyphs) {
            if (glyph == null) {
                advances += 400
                offsets += glyfStream.size()
                continue
            }
            require(glyph.pixels.size == glyph.width * glyph.height && glyph.width in 1..16 && glyph.height in 1..16)
            val step = 800 / glyph.height
            advances += glyph.advance * step
            val points = mutableListOf<Pair<Int, Int>>()
            for (y in 0 until glyph.height) for (x in 0 until glyph.width) {
                val pixel = glyph.pixels[y * glyph.width + x]
                if ((pixel ushr 24) < 128) continue
                val left = x * step
                val bottom = (glyph.height - y - 1) * step
                // Clockwise external contours. No diagonal smoothing: preserve the game's pixel grid.
                points += left to bottom
                points += left to bottom + step
                points += left + step to bottom + step
                points += left + step to bottom
            }
            val contours = points.size / 4
            maxPoints = maxOf(maxPoints, points.size)
            val encoded = bytes {
                writeShort(contours)
                writeShort(0); writeShort(0); writeShort(glyph.width * step); writeShort(800)
                for (i in 0 until contours) writeShort(i * 4 + 3)
                writeShort(0) // no hinting instructions
                repeat(points.size) { writeByte(1) } // on-curve; signed 16-bit coordinates follow
                var previous = 0
                for (point in points) { writeShort(point.first - previous); previous = point.first }
                previous = 0
                for (point in points) { writeShort(point.second - previous); previous = point.second }
            }
            glyfStream.write(encoded)
            while (glyfStream.size() % 4 != 0) glyfStream.write(0)
            offsets += glyfStream.size()
        }
        val tables = sortedMapOf<String, ByteArray>()
        tables["glyf"] = glyfStream.toByteArray()
        tables["loca"] = bytes { offsets.forEach { writeInt(it) } }
        tables["hmtx"] = bytes { advances.forEach { writeShort(it); writeShort(0) } }
        tables["head"] = bytes {
            writeInt(0x00010000); writeInt(0x00010000); writeInt(0); writeInt(0x5f0f3cf5)
            writeShort(3); writeShort(1000); writeLong(0); writeLong(0)
            writeShort(0); writeShort(-200); writeShort(1600); writeShort(800)
            writeShort(0); writeShort(8); writeShort(2); writeShort(1); writeShort(0)
        }
        tables["hhea"] = bytes {
            writeInt(0x00010000); writeShort(800); writeShort(-200); writeShort(100)
            writeShort(advances.max()); writeShort(0); writeShort(0); writeShort(1600)
            writeShort(1); writeShort(0); writeShort(0); repeat(4) { writeShort(0) }
            writeShort(0); writeShort(glyphs.size)
        }
        tables["maxp"] = bytes {
            writeInt(0x00010000); writeShort(glyphs.size); writeShort(maxPoints); writeShort(maxPoints / 4)
            writeShort(0); writeShort(0); writeShort(1); repeat(8) { writeShort(0) }
        }
        // One segment per supported Unicode character plus sentinel. Missing accents go to Flutter fallback.
        val unicode = listOf(' ') + codes
        val segments = unicode.size + 1
        val power = Integer.highestOneBit(segments)
        val cmap = bytes {
            writeShort(4); writeShort(16 + segments * 8); writeShort(0)
            writeShort(segments * 2); writeShort(power * 2); writeShort(Integer.numberOfTrailingZeros(power)); writeShort(segments * 2 - power * 2)
            unicode.forEach { writeShort(it.code) }; writeShort(0xffff); writeShort(0)
            unicode.forEach { writeShort(it.code) }; writeShort(0xffff)
            unicode.forEachIndexed { i, c -> writeShort(i + 1 - c.code) }; writeShort(1)
            repeat(segments) { writeShort(0) }
        }
        tables["cmap"] = bytes { writeShort(0); writeShort(1); writeShort(3); writeShort(1); writeInt(12); write(cmap) }
        tables["name"] = bytes {
            val values = listOf(1 to family, 2 to "Regular", 4 to family, 6 to family.replace(" ", ""))
            val encoded = values.map { it.second.toByteArray(Charsets.UTF_16BE) }
            writeShort(0); writeShort(values.size); writeShort(6 + values.size * 12)
            var offset = 0
            for (i in values.indices) {
                writeShort(3); writeShort(1); writeShort(0x409); writeShort(values[i].first)
                writeShort(encoded[i].size); writeShort(offset); offset += encoded[i].size
            }
            encoded.forEach { write(it) }
        }
        tables["post"] = bytes { writeInt(0x00030000); writeInt(0); writeShort(-100); writeShort(50); repeat(5) { writeInt(0) } }
        // OS/2 v0 metrics make Android/FreeType and desktop validators agree on the em box.
        tables["OS/2"] = bytes {
            writeShort(0); writeShort(600); writeShort(400); writeShort(5); writeShort(0)
            repeat(11) { writeShort(0) }; repeat(10) { writeByte(0) }
            writeInt(1); repeat(3) { writeInt(0) }; writeBytes("SM64")
            writeShort(0x40); writeShort(32); writeShort(codes.last().code)
            writeShort(800); writeShort(-200); writeShort(100); writeShort(800); writeShort(200)
        }
        val count = tables.size
        val directorySize = 12 + count * 16
        var offset = directorySize
        val positions = mutableMapOf<String, Int>()
        for ((name, data) in tables) { positions[name] = offset; offset += (data.size + 3) and -4 }
        val output = bytes {
            val p = Integer.highestOneBit(count)
            writeInt(0x00010000); writeShort(count); writeShort(p * 16); writeShort(Integer.numberOfTrailingZeros(p)); writeShort(count * 16 - p * 16)
            for ((name, data) in tables) {
                writeBytes(name); writeInt(checksum(data).toInt()); writeInt(positions.getValue(name)); writeInt(data.size)
            }
            for ((_, data) in tables) {
                write(data); repeat((4 - data.size % 4) % 4) { writeByte(0) }
            }
        }
        ByteBuffer.wrap(output).order(ByteOrder.BIG_ENDIAN).putInt(positions.getValue("head") + 8,
            ((0xb1b0afbaL - checksum(output)) and 0xffffffffL).toInt())
        return output
    }
}

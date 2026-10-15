package mods.sm64cdpy

/** Small, bounded decoder for the US vanilla ROM. No game code or artwork is bundled. */
internal object MarioRomDecoder {
    const val ROM_SIZE = 8 * 1024 * 1024
    const val ROM_MD5 = "20b854b239203baf6c961b850a4a51a2"
    const val VERSION = 3
    const val PLAYER_SEGMENT = 0x00114750
    const val PLAYER_SEGMENT_BYTES = 78432
    data class Texture(val id: String, val segment: Int, val segmentBytes: Int,
                       val offset: Int, val width: Int, val height: Int, val format: String = "rgba16", val dialogQuad: Boolean = false)
    // Addresses from CoopDX levels/menu/leveldata.c and bin/segment2.c (US).
    val legacyTextures = listOf(
        Texture("stone", 0x2a65b0, 22255, 0x18, 32, 32),
        Texture("stone_dark", 0x2a65b0, 22255, 0x818, 32, 32),
        Texture("hand", 0x2a65b0, 22255, 0x6328, 32, 32),
        Texture("hand_pressed", 0x2a65b0, 22255, 0x6b28, 32, 32),
        Texture("star", 0x108a40, 48390, 0x4800, 16, 16)
    ) + (0..9).map { Texture("digit_$it", 0x108a40, 48390, it * 512, 16, 16) }


    val textures = legacyTextures + listOf(
        Texture("mario_save", 0x002a65b0, 22255, 0x00001018, 64, 32),
        Texture("mario_new", 0x002a65b0, 22255, 0x00002018, 64, 32),
        Texture("menu_erase", 0x002a65b0, 22255, 0x00003468, 32, 32),
        Texture("menu_copy", 0x002a65b0, 22255, 0x00003c68, 32, 32),
        Texture("menu_file", 0x002a65b0, 22255, 0x00004468, 32, 32),
        Texture("menu_score", 0x002a65b0, 22255, 0x00004c68, 32, 32),
        Texture("menu_sound", 0x002a65b0, 22255, 0x00005468, 32, 32),
        Texture("menu_glyph_0", 0x002a65b0, 22255, 0x0000ac40, 8, 8, "ia8"),
        Texture("menu_glyph_1", 0x002a65b0, 22255, 0x0000ac80, 8, 8, "ia8"),
        Texture("menu_glyph_2", 0x002a65b0, 22255, 0x0000acc0, 8, 8, "ia8"),
        Texture("menu_glyph_3", 0x002a65b0, 22255, 0x0000ad00, 8, 8, "ia8"),
        Texture("menu_glyph_4", 0x002a65b0, 22255, 0x0000ad40, 8, 8, "ia8"),
        Texture("menu_glyph_5", 0x002a65b0, 22255, 0x0000ad80, 8, 8, "ia8"),
        Texture("menu_glyph_6", 0x002a65b0, 22255, 0x0000adc0, 8, 8, "ia8"),
        Texture("menu_glyph_7", 0x002a65b0, 22255, 0x0000ae00, 8, 8, "ia8"),
        Texture("menu_glyph_8", 0x002a65b0, 22255, 0x0000ae40, 8, 8, "ia8"),
        Texture("menu_glyph_9", 0x002a65b0, 22255, 0x0000ae80, 8, 8, "ia8"),
        Texture("menu_glyph_A", 0x002a65b0, 22255, 0x0000aec0, 8, 8, "ia8"),
        Texture("menu_glyph_B", 0x002a65b0, 22255, 0x0000af00, 8, 8, "ia8"),
        Texture("menu_glyph_C", 0x002a65b0, 22255, 0x0000af40, 8, 8, "ia8"),
        Texture("menu_glyph_D", 0x002a65b0, 22255, 0x0000af80, 8, 8, "ia8"),
        Texture("menu_glyph_E", 0x002a65b0, 22255, 0x0000afc0, 8, 8, "ia8"),
        Texture("menu_glyph_F", 0x002a65b0, 22255, 0x0000b000, 8, 8, "ia8"),
        Texture("menu_glyph_G", 0x002a65b0, 22255, 0x0000b040, 8, 8, "ia8"),
        Texture("menu_glyph_H", 0x002a65b0, 22255, 0x0000b080, 8, 8, "ia8"),
        Texture("menu_glyph_I", 0x002a65b0, 22255, 0x0000b0c0, 8, 8, "ia8"),
        Texture("menu_glyph_J", 0x002a65b0, 22255, 0x0000b100, 8, 8, "ia8"),
        Texture("menu_glyph_K", 0x002a65b0, 22255, 0x0000b140, 8, 8, "ia8"),
        Texture("menu_glyph_L", 0x002a65b0, 22255, 0x0000b180, 8, 8, "ia8"),
        Texture("menu_glyph_M", 0x002a65b0, 22255, 0x0000b1c0, 8, 8, "ia8"),
        Texture("menu_glyph_N", 0x002a65b0, 22255, 0x0000b200, 8, 8, "ia8"),
        Texture("menu_glyph_O", 0x002a65b0, 22255, 0x0000b240, 8, 8, "ia8"),
        Texture("menu_glyph_P", 0x002a65b0, 22255, 0x0000b280, 8, 8, "ia8"),
        Texture("menu_glyph_Q", 0x002a65b0, 22255, 0x0000b2c0, 8, 8, "ia8"),
        Texture("menu_glyph_R", 0x002a65b0, 22255, 0x0000b300, 8, 8, "ia8"),
        Texture("menu_glyph_S", 0x002a65b0, 22255, 0x0000b340, 8, 8, "ia8"),
        Texture("menu_glyph_T", 0x002a65b0, 22255, 0x0000b380, 8, 8, "ia8"),
        Texture("menu_glyph_U", 0x002a65b0, 22255, 0x0000b3c0, 8, 8, "ia8"),
        Texture("menu_glyph_V", 0x002a65b0, 22255, 0x0000b400, 8, 8, "ia8"),
        Texture("menu_glyph_W", 0x002a65b0, 22255, 0x0000b440, 8, 8, "ia8"),
        Texture("menu_glyph_X", 0x002a65b0, 22255, 0x0000b480, 8, 8, "ia8"),
        Texture("menu_glyph_Y", 0x002a65b0, 22255, 0x0000b4c0, 8, 8, "ia8"),
        Texture("menu_glyph_Z", 0x002a65b0, 22255, 0x0000b500, 8, 8, "ia8"),
        Texture("course_upper", 0x002a65b0, 22255, 0x0000bce0, 64, 32),
        Texture("course_lower", 0x002a65b0, 22255, 0x0000cce0, 64, 32),
        Texture("hud_glyph_A", 0x00108a40, 48390, 0x00001400, 16, 16),
        Texture("hud_glyph_B", 0x00108a40, 48390, 0x00001600, 16, 16),
        Texture("hud_glyph_C", 0x00108a40, 48390, 0x00001800, 16, 16),
        Texture("hud_glyph_D", 0x00108a40, 48390, 0x00001a00, 16, 16),
        Texture("hud_glyph_E", 0x00108a40, 48390, 0x00001c00, 16, 16),
        Texture("hud_glyph_F", 0x00108a40, 48390, 0x00001e00, 16, 16),
        Texture("hud_glyph_G", 0x00108a40, 48390, 0x00002000, 16, 16),
        Texture("hud_glyph_H", 0x00108a40, 48390, 0x00002200, 16, 16),
        Texture("hud_glyph_I", 0x00108a40, 48390, 0x00002400, 16, 16),
        Texture("hud_glyph_K", 0x00108a40, 48390, 0x00002600, 16, 16),
        Texture("hud_glyph_L", 0x00108a40, 48390, 0x00002800, 16, 16),
        Texture("hud_glyph_M", 0x00108a40, 48390, 0x00002a00, 16, 16),
        Texture("hud_glyph_N", 0x00108a40, 48390, 0x00002c00, 16, 16),
        Texture("hud_glyph_O", 0x00108a40, 48390, 0x00002e00, 16, 16),
        Texture("hud_glyph_P", 0x00108a40, 48390, 0x00003000, 16, 16),
        Texture("hud_glyph_R", 0x00108a40, 48390, 0x00003200, 16, 16),
        Texture("hud_glyph_S", 0x00108a40, 48390, 0x00003400, 16, 16),
        Texture("hud_glyph_T", 0x00108a40, 48390, 0x00003600, 16, 16),
        Texture("hud_glyph_U", 0x00108a40, 48390, 0x00003800, 16, 16),
        Texture("hud_glyph_W", 0x00108a40, 48390, 0x00003a00, 16, 16),
        Texture("hud_glyph_Y", 0x00108a40, 48390, 0x00003c00, 16, 16),
        Texture("coin", 0x00108a40, 48390, 0x00004400, 16, 16),
        Texture("mario_head", 0x00108a40, 48390, 0x00004600, 16, 16),
        Texture("dialog_glyph_0", 0x00108a40, 48390, 0x00005900, 8, 16, "ia4", true),
        Texture("dialog_glyph_1", 0x00108a40, 48390, 0x00005940, 8, 16, "ia4", true),
        Texture("dialog_glyph_2", 0x00108a40, 48390, 0x00005980, 8, 16, "ia4", true),
        Texture("dialog_glyph_3", 0x00108a40, 48390, 0x000059c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_4", 0x00108a40, 48390, 0x00005a00, 8, 16, "ia4", true),
        Texture("dialog_glyph_5", 0x00108a40, 48390, 0x00005a40, 8, 16, "ia4", true),
        Texture("dialog_glyph_6", 0x00108a40, 48390, 0x00005a80, 8, 16, "ia4", true),
        Texture("dialog_glyph_7", 0x00108a40, 48390, 0x00005ac0, 8, 16, "ia4", true),
        Texture("dialog_glyph_8", 0x00108a40, 48390, 0x00005b00, 8, 16, "ia4", true),
        Texture("dialog_glyph_9", 0x00108a40, 48390, 0x00005b40, 8, 16, "ia4", true),
        Texture("dialog_glyph_A", 0x00108a40, 48390, 0x00005b80, 8, 16, "ia4", true),
        Texture("dialog_glyph_B", 0x00108a40, 48390, 0x00005bc0, 8, 16, "ia4", true),
        Texture("dialog_glyph_C", 0x00108a40, 48390, 0x00005c00, 8, 16, "ia4", true),
        Texture("dialog_glyph_D", 0x00108a40, 48390, 0x00005c40, 8, 16, "ia4", true),
        Texture("dialog_glyph_E", 0x00108a40, 48390, 0x00005c80, 8, 16, "ia4", true),
        Texture("dialog_glyph_F", 0x00108a40, 48390, 0x00005cc0, 8, 16, "ia4", true),
        Texture("dialog_glyph_G", 0x00108a40, 48390, 0x00005d00, 8, 16, "ia4", true),
        Texture("dialog_glyph_H", 0x00108a40, 48390, 0x00005d40, 8, 16, "ia4", true),
        Texture("dialog_glyph_I", 0x00108a40, 48390, 0x00005d80, 8, 16, "ia4", true),
        Texture("dialog_glyph_J", 0x00108a40, 48390, 0x00005dc0, 8, 16, "ia4", true),
        Texture("dialog_glyph_K", 0x00108a40, 48390, 0x00005e00, 8, 16, "ia4", true),
        Texture("dialog_glyph_L", 0x00108a40, 48390, 0x00005e40, 8, 16, "ia4", true),
        Texture("dialog_glyph_M", 0x00108a40, 48390, 0x00005e80, 8, 16, "ia4", true),
        Texture("dialog_glyph_N", 0x00108a40, 48390, 0x00005ec0, 8, 16, "ia4", true),
        Texture("dialog_glyph_O", 0x00108a40, 48390, 0x00005f00, 8, 16, "ia4", true),
        Texture("dialog_glyph_P", 0x00108a40, 48390, 0x00005f40, 8, 16, "ia4", true),
        Texture("dialog_glyph_Q", 0x00108a40, 48390, 0x00005f80, 8, 16, "ia4", true),
        Texture("dialog_glyph_R", 0x00108a40, 48390, 0x00005fc0, 8, 16, "ia4", true),
        Texture("dialog_glyph_S", 0x00108a40, 48390, 0x00006000, 8, 16, "ia4", true),
        Texture("dialog_glyph_T", 0x00108a40, 48390, 0x00006040, 8, 16, "ia4", true),
        Texture("dialog_glyph_U", 0x00108a40, 48390, 0x00006080, 8, 16, "ia4", true),
        Texture("dialog_glyph_V", 0x00108a40, 48390, 0x000060c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_W", 0x00108a40, 48390, 0x00006100, 8, 16, "ia4", true),
        Texture("dialog_glyph_X", 0x00108a40, 48390, 0x00006140, 8, 16, "ia4", true),
        Texture("dialog_glyph_Y", 0x00108a40, 48390, 0x00006180, 8, 16, "ia4", true),
        Texture("dialog_glyph_Z", 0x00108a40, 48390, 0x000061c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_a", 0x00108a40, 48390, 0x00006200, 8, 16, "ia4", true),
        Texture("dialog_glyph_b", 0x00108a40, 48390, 0x00006240, 8, 16, "ia4", true),
        Texture("dialog_glyph_c", 0x00108a40, 48390, 0x00006280, 8, 16, "ia4", true),
        Texture("dialog_glyph_d", 0x00108a40, 48390, 0x000062c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_e", 0x00108a40, 48390, 0x00006300, 8, 16, "ia4", true),
        Texture("dialog_glyph_f", 0x00108a40, 48390, 0x00006340, 8, 16, "ia4", true),
        Texture("dialog_glyph_g", 0x00108a40, 48390, 0x00006380, 8, 16, "ia4", true),
        Texture("dialog_glyph_h", 0x00108a40, 48390, 0x000063c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_i", 0x00108a40, 48390, 0x00006400, 8, 16, "ia4", true),
        Texture("dialog_glyph_j", 0x00108a40, 48390, 0x00006440, 8, 16, "ia4", true),
        Texture("dialog_glyph_k", 0x00108a40, 48390, 0x00006480, 8, 16, "ia4", true),
        Texture("dialog_glyph_l", 0x00108a40, 48390, 0x000064c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_m", 0x00108a40, 48390, 0x00006500, 8, 16, "ia4", true),
        Texture("dialog_glyph_n", 0x00108a40, 48390, 0x00006540, 8, 16, "ia4", true),
        Texture("dialog_glyph_o", 0x00108a40, 48390, 0x00006580, 8, 16, "ia4", true),
        Texture("dialog_glyph_p", 0x00108a40, 48390, 0x000065c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_q", 0x00108a40, 48390, 0x00006600, 8, 16, "ia4", true),
        Texture("dialog_glyph_r", 0x00108a40, 48390, 0x00006640, 8, 16, "ia4", true),
        Texture("dialog_glyph_s", 0x00108a40, 48390, 0x00006680, 8, 16, "ia4", true),
        Texture("dialog_glyph_t", 0x00108a40, 48390, 0x000066c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_u", 0x00108a40, 48390, 0x00006700, 8, 16, "ia4", true),
        Texture("dialog_glyph_v", 0x00108a40, 48390, 0x00006740, 8, 16, "ia4", true),
        Texture("dialog_glyph_w", 0x00108a40, 48390, 0x00006780, 8, 16, "ia4", true),
        Texture("dialog_glyph_x", 0x00108a40, 48390, 0x000067c0, 8, 16, "ia4", true),
        Texture("dialog_glyph_y", 0x00108a40, 48390, 0x00006800, 8, 16, "ia4", true),
        Texture("dialog_glyph_z", 0x00108a40, 48390, 0x00006840, 8, 16, "ia4", true),
        Texture("arrow_up", 0x00108a40, 48390, 0x00007600, 8, 8),
        Texture("arrow_down", 0x00108a40, 48390, 0x00007680, 8, 8)
    )

    data class Sky(val id: String, val segment: Int, val bytes: Int)
    val skies = listOf(Sky("sky_day", 0x2c73d0, 35951), Sky("sky_night", 0x2fb1b0, 27422))
    val generatedImages = listOf("panel_light", "panel_dark") + skies.map { it.id }
    val fontIds = listOf("font_menu", "font_dialog", "font_hud")

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
        val bytes = when (texture.format) { "rgba16" -> count * 2; "ia8" -> count; "ia4" -> (count + 1) / 2; else -> error("Unsupported format") }
        require(texture.offset >= 0 && texture.offset.toLong() + bytes <= segment.size)
        fun expand(value: Int) = value * 255 / 31
        val decoded = IntArray(count) { i ->
            when (texture.format) {
                "rgba16" -> {
                    val index = texture.offset + i * 2
                    val value = ((segment[index].toInt() and 255) shl 8) or (segment[index + 1].toInt() and 255)
                    val alpha = if (value and 1 != 0) 255 else 0
                    (alpha shl 24) or (expand(value ushr 11) shl 16) or
                        (expand((value ushr 6) and 31) shl 8) or expand((value ushr 1) and 31)
                }
                "ia8" -> {
                    val value = segment[texture.offset + i].toInt() and 255
                    val intensity = (value ushr 4) * 17
                    ((value and 15) * 17 shl 24) or (intensity shl 16) or (intensity shl 8) or intensity
                }
                else -> {
                    val byte = segment[texture.offset + i / 2].toInt() and 255
                    val value = if (i % 2 == 0) byte ushr 4 else byte and 15
                    val intensity = (value ushr 1) * 255 / 7
                    ((if (value and 1 == 1) 255 else 0) shl 24) or (intensity shl 16) or (intensity shl 8) or intensity
                }
            }
        }
        // Sample the actual US ROM display-list quad UVs. This avoids assuming a
        // transpose/rotation from the extraction manifest's 16×8 storage dimensions.
        return if (texture.dialogQuad) dialogPixelsFromQuad(segment, decoded) else decoded
    }

    private fun dialogPixelsFromQuad(segment: ByteArray, source: IntArray): IntArray {
        val base = 0x11c88 // vertex_ia8_char in bin/segment2.c
        require(base + 64 <= segment.size && source.size == 128)
        fun short(offset: Int): Int = (((segment[offset].toInt() and 255) shl 8) or (segment[offset + 1].toInt() and 255)).toShort().toInt()
        data class Point(val x: Int, val y: Int, val s: Int, val t: Int)
        val points = (0..3).map { i -> val at = base + i * 16; Point(short(at), short(at + 2), short(at + 8), short(at + 10)) }
        val minX = points.minOf { it.x }; val maxX = points.maxOf { it.x }
        val minY = points.minOf { it.y }; val maxY = points.maxOf { it.y }
        require(minX < maxX && minY < maxY)
        fun corner(x: Int, y: Int) = points.single { it.x == x && it.y == y }
        val tl = corner(minX, maxY); val tr = corner(maxX, maxY)
        val bl = corner(minX, minY); val br = corner(maxX, minY)
        return IntArray(128) { i ->
            val x = (i % 8 + 0.5) / 8.0; val y = (i / 8 + 0.5) / 16.0
            fun interpolate(get: (Point) -> Int): Double = (get(tl) * (1 - x) + get(tr) * x) * (1 - y) + (get(bl) * (1 - x) + get(br) * x) * y
            val u = kotlin.math.floor(interpolate { it.s } / 32).toInt().coerceIn(0, 15)
            val v = kotlin.math.floor(interpolate { it.t } / 32).toInt().coerceIn(0, 7)
            source[v * 16 + u]
        }
    }

    fun skyPixels(segment: ByteArray): IntArray {
        // The pointer table uses 10 columns (8 distinct + 2 repeats) and 8 rows.
        return IntArray(256 * 256).also { out ->
            for (row in 0..7) for (column in 0..7) {
                val tile = if (row < 5) row * 8 + column else 40
                val pixels = pixels(segment, Texture("tile", 0, 0, tile * 2048, 32, 32))
                for (y in 0..31) for (x in 0..31) out[(row * 32 + y) * 256 + column * 32 + x] = pixels[y * 32 + x]
            }
        }
    }

    fun panelPixels(stone: IntArray, dark: Boolean): IntArray = IntArray(stone.size) { i ->
        val color = stone[i]
        val value = (((color ushr 16) and 255) * 3 + ((color ushr 8) and 255) * 6 + (color and 255)) / 10
        // Full-opacity original material relief, remapped only to keep localized text readable.
        val light = if (dark) 24 + value * 48 / 255 else 190 + value * 65 / 255
        (255 shl 24) or (light shl 16) or (light shl 8) or light
    }
}

package mods.sm64cdpy

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.BitmapShader
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader
import java.io.File
import java.security.MessageDigest
import kotlin.math.cos
import kotlin.math.sin

/** Bounded F3D rasterizer for one fixed Mario pose. Geometry is read from the user's ROM. */
internal object MarioPlayerPreviewRenderer {
    const val WIDTH = 512
    const val HEIGHT = 512

    private data class Placement(val dl: Int, val part: Int, val x: Float, val z: Float, val turn: Float = 0f, val texture: Int? = null)
    private data class Point(val x: Float, val y: Float, val z: Float, val shade: Float, val u: Float, val v: Float)
    private data class Triangle(val points: List<Point>, val part: Int, val depth: Float, val texture: Int?)

    private fun rotatedOrigin(x: Float, z: Float, distance: Float, turn: Float): Pair<Float, Float> =
        (x + cos(turn) * distance) to (z + sin(turn) * distance)

    private fun placements(): List<Placement> {
        val leftTurn = Math.toRadians(138.0).toFloat()
        val rightTurn = -leftTurn
        val legTurn = Math.PI.toFloat()
        fun arm(left: Boolean): List<Placement> {
            val turn = if (left) leftTurn else rightTurn
            val z = if (left) 79f else -79f
            val first = rotatedOrigin(135f, z, 65f, turn)
            val hand = rotatedOrigin(first.first, first.second, 60f, turn)
            return listOf(
                Placement(if (left) 0x0d090 else 0x0dca0, 1, 135f, z, turn),
                Placement(if (left) 0x0d2f8 else 0x0df08, 1, first.first, first.second, turn),
                Placement(if (left) 0x0d758 else 0x0e2c8, 2, hand.first, hand.second, turn),
            )
        }
        fun leg(left: Boolean): List<Placement> {
            val z = if (left) 42f else -42f
            val knee = rotatedOrigin(13f, z, 89f, legTurn)
            val foot = rotatedOrigin(knee.first, knee.second, 67f, legTurn)
            return listOf(
                Placement(if (left) 0x0e6a8 else 0x0eeb0, 0, 13f, z, legTurn),
                Placement(if (left) 0x0e918 else 0x0f1d8, 0, knee.first, knee.second, legTurn),
                Placement(if (left) 0x0ebb8 else 0x0f400, 3, foot.first, foot.second, legTurn),
            )
        }
        return listOf(
            Placement(0x0ca00, 0, 0f, 0f),
            Placement(0x0ff28, 0, 68f, 0f, texture = 0x1090),
            Placement(0x0ff88, 0, 68f, 0f),
            Placement(0x10260, 1, 68f, 0f),
            Placement(0x11438, 5, 155f, 0f),
            Placement(0x116f8, 6, 155f, 0f),
            Placement(0x11870, 4, 155f, 0f),
            Placement(0x113a0, 4, 155f, 0f, texture = 0x2890),
            Placement(0x11350, 4, 155f, 0f),
            Placement(0x112e8, 5, 155f, 0f, texture = 0x3090),
            Placement(0x112b0, 7, 155f, 0f),
        ) + arm(true) + arm(false) + leg(true) + leg(false)
    }

    fun render(segment: ByteArray, colors: IntArray, output: File): File {
        require(colors.size == 8 && segment.size > 0x11960)
        val triangles = placements().flatMap { parse(segment, it) }
        require(triangles.isNotEmpty())
        val all = triangles.flatMap { it.points }
        val minX = all.minOf { it.z }
        val maxX = all.maxOf { it.z }
        val minY = all.minOf { it.x }
        val maxY = all.maxOf { it.x }
        val scale = minOf((WIDTH - 72f) / (maxX - minX), (HEIGHT - 58f) / (maxY - minY))
        val centerX = (minX + maxX) / 2f
        val centerY = (minY + maxY) / 2f
        val bitmap = Bitmap.createBitmap(WIDTH, HEIGHT, Bitmap.Config.ARGB_8888)
        try {
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
            val textures = placements().mapNotNull { it.texture }.distinct().associateWith { texture(segment, it) }
            for (triangle in triangles.sortedBy { it.depth }) {
                val path = Path()
                val destination = FloatArray(6)
                triangle.points.forEachIndexed { index, point ->
                    val sx = WIDTH / 2f + (point.z - centerX) * scale
                    val sy = HEIGHT / 2f - (point.x - centerY) * scale
                    destination[index * 2] = sx
                    destination[index * 2 + 1] = sy
                    if (index == 0) path.moveTo(sx, sy) else path.lineTo(sx, sy)
                }
                path.close()
                val texture = triangle.texture?.let(textures::get)
                if (texture != null) {
                    val source = triangle.points.flatMap { listOf(it.u, it.v) }.toFloatArray()
                    val matrix = Matrix()
                    matrix.setPolyToPoly(source, 0, destination, 0, 3)
                    paint.shader = BitmapShader(texture, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP).apply { setLocalMatrix(matrix) }
                    paint.color = Color.WHITE
                } else {
                    paint.shader = null
                    val base = colors[triangle.part]
                    val shade = triangle.points.map { it.shade }.average().toFloat().coerceIn(.35f, 1f)
                    paint.color = Color.rgb(
                        (Color.red(base) * shade).toInt(),
                        (Color.green(base) * shade).toInt(),
                        (Color.blue(base) * shade).toInt(),
                    )
                }
                canvas.drawPath(path, paint)
            }
            textures.values.forEach(Bitmap::recycle)
            output.parentFile?.mkdirs()
            val temporary = File(output.parentFile, "${output.name}.tmp")
            temporary.outputStream().use { check(bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)); it.fd.sync() }
            check(temporary.renameTo(output) || temporary.copyTo(output, overwrite = true).let { temporary.delete(); true })
            return output
        } finally { bitmap.recycle() }
    }

    fun cacheName(generation: String, colors: IntArray): String {
        val data = "$generation:${colors.joinToString(",")}".toByteArray()
        return MessageDigest.getInstance("SHA-256").digest(data).take(12).joinToString("") { "%02x".format(it) } + ".png"
    }

    private fun parse(segment: ByteArray, placement: Placement): List<Triangle> {
        val out = mutableListOf<Triangle>()
        val vertices = arrayOfNulls<Point>(16)
        var cursor = placement.dl
        var commands = 0
        while (cursor + 8 <= segment.size && commands++ < 512) {
            val op = segment[cursor].toInt() and 255
            val w0 = word(segment, cursor)
            val w1 = word(segment, cursor + 4)
            when (op) {
                0x04 -> {
                    val count = ((w0 ushr 20) and 15) + 1
                    val address = w1 and 0x00ffffff
                    require(count in 1..16 && address + count * 16 <= segment.size)
                    repeat(count) { index -> vertices[index] = vertex(segment, address + index * 16, placement) }
                }
                0xbf -> {
                    val indices = listOf((w1 ushr 16) and 255, (w1 ushr 8) and 255, w1 and 255).map { it / 10 }
                    val points = indices.map { requireNotNull(vertices.getOrNull(it)) }
                    out += Triangle(points, placement.part, points.sumOf { it.y.toDouble() }.toFloat() / 3f, placement.texture)
                }
                0xb8 -> return out
            }
            cursor += 8
        }
        require(commands < 512) { "Unbounded display list" }
        return out
    }

    private fun vertex(data: ByteArray, at: Int, placement: Placement): Point {
        val localX = short(data, at).toFloat()
        val y = short(data, at + 2).toFloat()
        val localZ = short(data, at + 4).toFloat()
        val c = cos(placement.turn)
        val s = sin(placement.turn)
        val x = placement.x + c * localX - s * localZ
        val z = placement.z + s * localX + c * localZ
        val nx = data[at + 12].toInt() / 127f
        val ny = data[at + 13].toInt() / 127f
        val nz = data[at + 14].toInt() / 127f
        val shade = (.62f + .32f * (nx * .35f + ny * -.45f + nz * .82f)).coerceIn(.35f, 1f)
        return Point(x, y, z, shade, short(data, at + 8) / 32f, short(data, at + 10) / 32f)
    }

    private fun texture(segment: ByteArray, offset: Int): Bitmap {
        val pixels = IntArray(32 * 32) { index ->
            val at = offset + index * 2
            val value = ((segment[at].toInt() and 255) shl 8) or (segment[at + 1].toInt() and 255)
            fun expand(channel: Int) = channel * 255 / 31
            Color.argb(if (value and 1 != 0) 255 else 0, expand(value ushr 11), expand((value ushr 6) and 31), expand((value ushr 1) and 31))
        }
        return Bitmap.createBitmap(pixels, 32, 32, Bitmap.Config.ARGB_8888)
    }

    private fun short(data: ByteArray, at: Int): Short = (((data[at].toInt() and 255) shl 8) or (data[at + 1].toInt() and 255)).toShort()
    private fun word(data: ByteArray, at: Int): Int = (0..3).fold(0) { value, index -> (value shl 8) or (data[at + index].toInt() and 255) }
}

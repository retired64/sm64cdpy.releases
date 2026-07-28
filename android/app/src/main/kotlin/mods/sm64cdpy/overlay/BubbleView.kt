package mods.sm64cdpy.overlay

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.view.View

class BubbleView(context: Context) : View(context) {

    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFF1A1A2E.toInt()
        style = Paint.Style.FILL
    }

    private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFFE94560.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 3f * context.resources.displayMetrics.density
    }

    private val icon: Drawable? by lazy {
        try {
            context.packageManager.getApplicationIcon(context.packageName)
        } catch (_: Exception) {
            null
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        val cx = width / 2f
        val cy = height / 2f
        val radius = (width.coerceAtMost(height) / 2f) - borderPaint.strokeWidth

        // Background circle
        canvas.drawCircle(cx, cy, radius + borderPaint.strokeWidth / 2, bgPaint)

        // App icon
        icon?.let { drawable ->
            val padding = radius * 0.25f
            val iconSize = (radius - padding) * 2
            val left = (cx - iconSize / 2).toInt()
            val top = (cy - iconSize / 2).toInt()
            drawable.setBounds(left, top, left + iconSize.toInt(), top + iconSize.toInt())
            drawable.draw(canvas)
        }

        // Border on top
        canvas.drawCircle(cx, cy, radius, borderPaint)
    }
}

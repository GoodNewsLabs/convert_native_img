package com.example.convert_native_img

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import java.io.ByteArrayOutputStream

class Nv21ToPngConverter {

    fun convertNv21ToPngBytes(
        nv21Data: ByteArray,
        width: Int,
        height: Int,
        quality: Int,
        rotation: Int,
    ): ByteArray {
        // First convert NV21 to Bitmap using YuvImage
        val originalBitmap = nv21ToBitmap(nv21Data, width, height, quality)

        val matrix = Matrix()
        matrix.postRotate(rotation.toFloat())
        val rotatedBitmap = Bitmap.createBitmap(
            originalBitmap,
            0, 0,
            originalBitmap.width, originalBitmap.height,
            matrix,
            true
        )
        originalBitmap.recycle()

        // Then convert Bitmap to PNG
        val outputStream = ByteArrayOutputStream()
        rotatedBitmap.compress(Bitmap.CompressFormat.PNG, quality, outputStream)
        rotatedBitmap.recycle()

        return outputStream.toByteArray()
    }

    private fun nv21ToBitmap(nv21Data: ByteArray, width: Int, height: Int, quality: Int): Bitmap {
        val yuvImage = YuvImage(nv21Data, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()

        // Convert YUV to JPEG first (YuvImage doesn't support direct conversion to other formats)
        yuvImage.compressToJpeg(Rect(0, 0, width, height), quality, out)

        // Then convert JPEG to Bitmap
        val imageBytes = out.toByteArray()
        return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
    }
}
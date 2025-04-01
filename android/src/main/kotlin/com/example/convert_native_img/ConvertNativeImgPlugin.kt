package com.example.convert_native_img

import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

/** ConvertNativeImgPlugin */
class ConvertNativeImgPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var nv21ToPngConverter = Nv21ToPngConverter()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "convert_native_img")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "convert") {
            val arg = (call.arguments as? Map<*, *>)
            val bytes: ByteArray? = arg?.get("bytes") as? ByteArray
            val width: Int? = arg?.get("width") as? Int
            val height: Int? = arg?.get("height") as? Int
            val quality: Int = arg?.get("quality") as? Int ?: 100
            if (bytes == null || width == null || height == null) {
                result.success(null)
                return
            }

            CoroutineScope(Dispatchers.IO).launch {
                val byteArray = nv21ToPngConverter.convertNv21ToPngBytes(bytes, width, height, quality, -90)
                withContext(Dispatchers.Main) {
                    result.success(byteArray)
                }
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

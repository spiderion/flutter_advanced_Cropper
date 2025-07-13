package com.roohani.flutter_advanced_cropper

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Canvas
import android.graphics.Paint
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class FlutterAdvancedCropperPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
  companion object {
    private const val CHANNEL = "com.roohani.flutter_advanced_cropper"
    private const val TAG = "CropperPlugin"
  }

  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    try {
      channel = MethodChannel(binding.binaryMessenger, CHANNEL)
      channel.setMethodCallHandler(this)
      Log.d(TAG, "✅ Plugin attached to engine with channel: $CHANNEL")
    } catch (e: Exception) {
      Log.e(TAG, "❌ Failed to attach to engine: ${e.message}", e)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    try {
      if (::channel.isInitialized) {
        channel.setMethodCallHandler(null)
        Log.d(TAG, "❌ Plugin detached from engine")
      }
    } catch (e: Exception) {
      Log.e(TAG, "❌ Error during detachment: ${e.message}", e)
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    Log.d(TAG, "📞 Method call received: ${call.method} with arguments: ${call.arguments}")

    try {
      when (call.method) {
        "applyAdjustments" -> handleApplyAdjustments(call, result)
        "getSupportedAdjustments" -> handleGetSupportedAdjustments(result)
        "isAvailable" -> handleIsAvailable(result)
        "testConnection" -> handleTestConnection(result)
        else -> {
          Log.w(TAG, "⚠️ Method not implemented: ${call.method}")
          result.notImplemented()
        }
      }
    } catch (e: Exception) {
      Log.e(TAG, "❌ Unexpected error in onMethodCall: ${e.message}", e)
      result.error("UNEXPECTED_ERROR", "An unexpected error occurred: ${e.message}", e.toString())
    }
  }

  private fun handleTestConnection(result: MethodChannel.Result) {
    Log.d(TAG, "🔄 Test connection called")
    result.success("Plugin is working correctly!")
  }

  private fun handleApplyAdjustments(call: MethodCall, result: MethodChannel.Result) {
    try {
      Log.d(TAG, "🎛️ Starting applyAdjustments")

      // Validate arguments
      val args = call.arguments as? Map<*, *>
        ?: throw IllegalArgumentException("Arguments must be a Map")

      val imageBytes = args["imageBytes"] as? ByteArray
        ?: throw IllegalArgumentException("imageBytes is required and must be ByteArray")

      val adjustments = args["adjustments"] as? Map<*, *>
        ?: throw IllegalArgumentException("adjustments is required and must be Map")

      Log.d(TAG, "🖼️ Image bytes size: ${imageBytes.size}")
      Log.d(TAG, "🎛️ Adjustments: $adjustments")

      // Decode bitmap
      val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
        ?: throw IllegalArgumentException("Failed to decode image bytes")

      Log.d(TAG, "📐 Original bitmap: ${bitmap.width}x${bitmap.height}")

      // Apply adjustments
      val adjustedBitmap = applyColorMatrix(bitmap, adjustments)

      // Compress result
      val outputStream = ByteArrayOutputStream()
      val compressed = adjustedBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)

      if (!compressed) {
        throw RuntimeException("Failed to compress adjusted bitmap")
      }

      val resultBytes = outputStream.toByteArray()
      Log.d(TAG, "✅ Adjustment complete. Result size: ${resultBytes.size}")

      result.success(resultBytes)

    } catch (e: ClassCastException) {
      Log.e(TAG, "❌ Type casting error in applyAdjustments: ${e.message}", e)
      result.error("TYPE_ERROR", "Invalid argument types: ${e.message}", null)
    } catch (e: IllegalArgumentException) {
      Log.e(TAG, "❌ Invalid arguments in applyAdjustments: ${e.message}", e)
      result.error("INVALID_ARGUMENTS", e.message, null)
    } catch (e: OutOfMemoryError) {
      Log.e(TAG, "❌ Out of memory in applyAdjustments: ${e.message}", e)
      result.error("OUT_OF_MEMORY", "Image too large to process", null)
    } catch (e: Exception) {
      Log.e(TAG, "❌ Error in applyAdjustments: ${e.message}", e)
      result.error("PROCESSING_ERROR", e.message, e.toString())
    }
  }

  private fun handleGetSupportedAdjustments(result: MethodChannel.Result) {
    Log.d(TAG, "📋 Getting supported adjustments")
    val supportedAdjustments = listOf(
      "exposure", "brightness", "contrast", "saturation", "warmth", "tint"
    )
    result.success(supportedAdjustments)
  }

  private fun handleIsAvailable(result: MethodChannel.Result) {
    Log.d(TAG, "✅ Plugin availability check")
    result.success(true)
  }

  private fun applyColorMatrix(bitmap: Bitmap, adjustments: Map<*, *>): Bitmap {
    Log.d(TAG, "🎨 Applying color matrix transformations")

    val matrix = ColorMatrix()

    // Extract adjustment values with proper validation
    val brightness = getAdjustmentValue(adjustments, "brightness")
    val contrast = getAdjustmentValue(adjustments, "contrast")
    val exposure = getAdjustmentValue(adjustments, "exposure")
    val saturation = getAdjustmentValue(adjustments, "saturation")
    val warmth = getAdjustmentValue(adjustments, "warmth")
    val tint = getAdjustmentValue(adjustments, "tint")

    Log.d(TAG, "🔆 Brightness: $brightness, 🎞 Contrast: $contrast")
    Log.d(TAG, "☀ Exposure: $exposure, 🌈 Saturation: $saturation")
    Log.d(TAG, "🔥 Warmth: $warmth, 🌸 Tint: $tint")

    // Apply adjustments in order
    applyBrightness(matrix, brightness)
    applyContrast(matrix, contrast)
    applyExposure(matrix, exposure)
    applySaturation(matrix, saturation)
    applyWarmth(matrix, warmth)
    applyTint(matrix, tint)

    // Create result bitmap
    val resultBitmap = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(resultBitmap)
    val paint = Paint().apply {
      colorFilter = ColorMatrixColorFilter(matrix)
      isAntiAlias = true
      isFilterBitmap = true
    }

    canvas.drawBitmap(bitmap, 0f, 0f, paint)
    Log.d(TAG, "🖌️ Bitmap transformations applied successfully")

    return resultBitmap
  }

  private fun getAdjustmentValue(adjustments: Map<*, *>, key: String): Float {
    return when (val value = adjustments[key]) {
      is Number -> value.toFloat()
      is String -> value.toFloatOrNull() ?: 0f
      null -> 0f
      else -> {
        Log.w(TAG, "⚠️ Invalid value type for $key: ${value::class.java}")
        0f
      }
    }
  }

  private fun applyBrightness(matrix: ColorMatrix, brightness: Float) {
    if (brightness != 0f) {
      val brightnessValue = brightness * 255f
      val brightnessMatrix = ColorMatrix(
        floatArrayOf(
          1f, 0f, 0f, 0f, brightnessValue,
          0f, 1f, 0f, 0f, brightnessValue,
          0f, 0f, 1f, 0f, brightnessValue,
          0f, 0f, 0f, 1f, 0f
        )
      )
      matrix.postConcat(brightnessMatrix)
    }
  }

  private fun applyContrast(matrix: ColorMatrix, contrast: Float) {
    if (contrast != 0f) {
      val scale = 1f + contrast
      val translate = 128f * (1f - scale)
      val contrastMatrix = ColorMatrix(
        floatArrayOf(
          scale, 0f, 0f, 0f, translate,
          0f, scale, 0f, 0f, translate,
          0f, 0f, scale, 0f, translate,
          0f, 0f, 0f, 1f, 0f
        )
      )
      matrix.postConcat(contrastMatrix)
    }
  }

  private fun applyExposure(matrix: ColorMatrix, exposure: Float) {
    if (exposure != 0f) {
      val factor = Math.pow(2.0, exposure.toDouble()).toFloat()
      val exposureMatrix = ColorMatrix(
        floatArrayOf(
          factor, 0f, 0f, 0f, 0f,
          0f, factor, 0f, 0f, 0f,
          0f, 0f, factor, 0f, 0f,
          0f, 0f, 0f, 1f, 0f
        )
      )
      matrix.postConcat(exposureMatrix)
    }
  }

  private fun applySaturation(matrix: ColorMatrix, saturation: Float) {
    if (saturation != 0f) {
      val saturationMatrix = ColorMatrix()
      saturationMatrix.setSaturation(1f + saturation)
      matrix.postConcat(saturationMatrix)
    }
  }

  private fun applyWarmth(matrix: ColorMatrix, warmth: Float) {
    if (warmth != 0f) {
      val redAdjust = 1f + warmth * 0.3f
      val blueAdjust = 1f - warmth * 0.3f
      val warmthMatrix = ColorMatrix(
        floatArrayOf(
          redAdjust, 0f, 0f, 0f, 0f,
          0f, 1f, 0f, 0f, 0f,
          0f, 0f, blueAdjust, 0f, 0f,
          0f, 0f, 0f, 1f, 0f
        )
      )
      matrix.postConcat(warmthMatrix)
    }
  }

  private fun applyTint(matrix: ColorMatrix, tint: Float) {
    if (tint != 0f) {
      val rAdjust = 1f + tint * 0.2f
      val gAdjust = 1f - tint * 0.2f
      val bAdjust = 1f + tint * 0.2f
      val tintMatrix = ColorMatrix(
        floatArrayOf(
          rAdjust, 0f, 0f, 0f, 0f,
          0f, gAdjust, 0f, 0f, 0f,
          0f, 0f, bAdjust, 0f, 0f,
          0f, 0f, 0f, 1f, 0f
        )
      )
      matrix.postConcat(tintMatrix)
    }
  }
}
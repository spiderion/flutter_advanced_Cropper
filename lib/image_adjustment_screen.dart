import 'package:flutter/services.dart';

import 'models.dart';

class ImageAdjustmentProcessor {
  static const MethodChannel _channel = MethodChannel(
    'com.roohani.flutter_advanced_cropper',
  );

  static const List<AdjustmentOption> adjustmentOptions = [
    AdjustmentOption(name: 'Exposure', icon: '☀️', min: -2.0, max: 2.0),
    AdjustmentOption(name: 'Brightness', icon: '💡', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Contrast', icon: '🌗', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Saturation', icon: '🎨', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Warmth', icon: '🔥', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Tint', icon: '🌸', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Highlights', icon: '✨', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Shadows', icon: '🌑', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Vibrance', icon: '⚡', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Sharpness', icon: '🔍', min: -1.0, max: 1.0),
    AdjustmentOption(name: 'Clarity', icon: '💎', min: -1.0, max: 1.0),
  ];

  static AdjustmentOption getOptionByName(String name) {
    return adjustmentOptions.firstWhere(
      (option) => option.name == name,
      orElse: () => adjustmentOptions[0],
    );
  }

  static double getValueFromAdjustments(
    ImageAdjustmentValues adjustments,
    String adjustmentName,
  ) {
    switch (adjustmentName) {
      case 'Exposure':
        return adjustments.exposure;
      case 'Brightness':
        return adjustments.brightness;
      case 'Contrast':
        return adjustments.contrast;
      case 'Saturation':
        return adjustments.saturation;
      case 'Warmth':
        return adjustments.warmth;
      case 'Tint':
        return adjustments.tint;
      case 'Highlights':
        return adjustments.highlights;
      case 'Shadows':
        return adjustments.shadows;
      case 'Vibrance':
        return adjustments.vibrance;
      case 'Sharpness':
        return adjustments.sharpness;
      case 'Clarity':
        return adjustments.clarity;
      default:
        return 0.0;
    }
  }

  static void setValueInAdjustments(
    ImageAdjustmentValues adjustments,
    String adjustmentName,
    double value,
  ) {
    switch (adjustmentName) {
      case 'Exposure':
        adjustments.exposure = value;
        break;
      case 'Brightness':
        adjustments.brightness = value;
        break;
      case 'Contrast':
        adjustments.contrast = value;
        break;
      case 'Saturation':
        adjustments.saturation = value;
        break;
      case 'Warmth':
        adjustments.warmth = value;
        break;
      case 'Tint':
        adjustments.tint = value;
        break;
      case 'Highlights':
        adjustments.highlights = value;
        break;
      case 'Shadows':
        adjustments.shadows = value;
        break;
      case 'Vibrance':
        adjustments.vibrance = value;
        break;
      case 'Sharpness':
        adjustments.sharpness = value;
        break;
      case 'Clarity':
        adjustments.clarity = value;
        break;
    }
  }

  /// Apply image adjustments using native platform methods
  static Future<Uint8List?> applyAdjustments(
    Uint8List imageBytes,
    ImageAdjustmentValues adjustments,
  ) async {
    if (!adjustments.hasAnyAdjustments) {
      return imageBytes;
    }

    try {
      final Map<String, dynamic> arguments = {
        'imageBytes': imageBytes,
        'adjustments': {
          'exposure': adjustments.exposure,
          'brightness': adjustments.brightness,
          'contrast': adjustments.contrast,
          'saturation': adjustments.saturation,
          'warmth': adjustments.warmth,
          'tint': adjustments.tint,
          'highlights': adjustments.highlights,
          'shadows': adjustments.shadows,
          'vibrance': adjustments.vibrance,
          'sharpness': adjustments.sharpness,
          'clarity': adjustments.clarity,
        },
      };

      final result = await _channel.invokeMethod('applyAdjustments', arguments);

      if (result is Uint8List) {
        return result;
      } else {
        print('Native method returned unexpected type: ${result.runtimeType}');
        return null;
      }
    } catch (e) {
      print('Error applying adjustments via native method: $e');
      return null;
    }
  }

  /// Get a preview adjustment using native methods for real-time preview
  static Future<Uint8List?> getPreviewAdjustment(
    Uint8List imageBytes,
    ImageAdjustmentValues adjustments,
  ) async {
    try {
      final Map<String, dynamic> arguments = {
        'imageBytes': imageBytes,
        'adjustments': {
          'exposure': adjustments.exposure,
          'brightness': adjustments.brightness,
          'contrast': adjustments.contrast,
          'saturation': adjustments.saturation,
          'warmth': adjustments.warmth,
          'tint': adjustments.tint,
          'highlights': adjustments.highlights,
          'shadows': adjustments.shadows,
          'vibrance': adjustments.vibrance,
          'sharpness': adjustments.sharpness,
          'clarity': adjustments.clarity,
        },
        'preview': true, // Flag for optimized preview processing
      };

      final result = await _channel.invokeMethod('applyAdjustments', arguments);

      if (result is Uint8List) {
        return result;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting preview adjustment: $e');
      return null;
    }
  }

  /// Check if native image processing is available
  static Future<bool> isNativeProcessingAvailable() async {
    try {
      final result = await _channel.invokeMethod('isAvailable');
      return result == true;
    } catch (e) {
      print('Native processing not available: $e');
      return false;
    }
  }

  /// Get supported adjustments from native side
  static Future<List<String>> getSupportedAdjustments() async {
    try {
      final result = await _channel.invokeMethod('getSupportedAdjustments');
      if (result is List) {
        return result.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error getting supported adjustments: $e');
      return [];
    }
  }

  static bool isAtDefault(String adjustmentName, double value) {
    return value == 0.0;
  }

  static String getDisplayValue(String adjustmentName, double value) {
    if (adjustmentName == 'Exposure') {
      return value >= 0
          ? '+${value.toStringAsFixed(1)}'
          : value.toStringAsFixed(1);
    } else {
      final percentage = (value * 100).round();
      return percentage >= 0 ? '+$percentage' : '$percentage';
    }
  }
}

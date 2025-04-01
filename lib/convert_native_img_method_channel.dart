import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'convert_native_img_platform_interface.dart';

/// An implementation of [ConvertNativeImgPlatform] that uses method channels.
class MethodChannelConvertNativeImg extends ConvertNativeImgPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('convert_native_img');

  @override
  Future<Uint8List?> convertNv21ToImage(
    Uint8List bytes, {
    required int width,
    required int height,
    int quality = 100,
  }) async {
    final result = await methodChannel.invokeMethod<Uint8List?>('convert', {
      "bytes": bytes,
      "width": width,
      "height": height,
      "quality": quality,
    });
    return result;
  }
}

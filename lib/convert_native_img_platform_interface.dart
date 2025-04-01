import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'convert_native_img_method_channel.dart';

abstract class ConvertNativeImgPlatform extends PlatformInterface {
  /// Constructs a ConvertNativeImgPlatform.
  ConvertNativeImgPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConvertNativeImgPlatform _instance = MethodChannelConvertNativeImg();

  /// The default instance of [ConvertNativeImgPlatform] to use.
  ///
  /// Defaults to [MethodChannelConvertNativeImg].
  static ConvertNativeImgPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ConvertNativeImgPlatform] when
  /// they register themselves.
  static set instance(ConvertNativeImgPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List?> convertNv21ToImage(Uint8List bytes,{
    required int width,
    required int height,
    int quality = 100,
  }) {
    throw UnimplementedError('convertCameraImageToPng() has not been implemented.');
  }
}

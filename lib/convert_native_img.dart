import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'convert_native_img_platform_interface.dart';

class ConvertNativeImg {
  Future<Uint8List?> convertCameraImageToPng(
    Uint8List bytes, {
    required int width,
    required int height,
  }) async {
    if (Platform.isIOS) {
      imglib.Image image = imglib.Image.fromBytes(
        height: height,
        width: width,
        bytes: bytes.buffer,
        order: imglib.ChannelOrder.bgra,
      );
      final imglib.PngEncoder pngEncoder = imglib.PngEncoder();
      return pngEncoder.encode(image);
    }

    if (Platform.isAndroid) {
      return ConvertNativeImgPlatform.instance.convertNv21ToImage(
        bytes,
        width: width,
        height: height,
      );
    }
    return null;
  }

}

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:convert_native_img/convert_native_img.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _convertNativeImgPlugin = ConvertNativeImg();

  CameraController? controller;
  String errorText = '';
  bool _isBusy = false;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCameraController();
    });
  }

  Future<void> _initializeCameraController() async {
    try {
      final PermissionStatus permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        setState(() {
          errorText = 'cameraAccessDenied';
        });
        return;
      }

      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription? frontCameraDescription =
          cameras.firstWhereOrNull((CameraDescription camera) => camera.lensDirection == CameraLensDirection.front);

      if (frontCameraDescription == null) {
        setState(() {
          errorText = "noFrontCamera";
        });
        return;
      }
      controller = CameraController(
        frontCameraDescription,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );
      await controller?.initialize();
      controller?.startImageStream(_processCameraImage);
      setState(() {
        errorText = "";
      });
    } catch (e) {
      if (e is CameraException && e.code == 'CameraAccessDenied') {
        errorText = 'cameraAccessDenied';
      } else {
        errorText = 'other';
      }
      setState(() {});
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;
    try {
      final Uint8List? bytes = await _convertNativeImgPlugin.convertCameraImageToPng(
        image.planes.first.bytes,
        width: image.width,
        height: image.height,
      );
      setState(() {
        imageBytes = bytes;
      });
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(builder: (context) {
          if (errorText.isNotEmpty) {
            return Center(child: Text(errorText));
          }

          if (controller == null || !controller!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return FractionallySizedBox(
            widthFactor: 1,
            child: Stack(
              children: <Widget>[
                CameraPreview(controller!),
                if (imageBytes != null)
                  Positioned(
                    bottom: 0,
                    child: Center(
                      child: SizedBox(
                        width: 200,
                        child: Image.memory(
                          imageBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

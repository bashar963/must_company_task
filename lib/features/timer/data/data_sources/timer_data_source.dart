import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:must_company_task/packages/macos_camera/macos_camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

abstract interface class TimerDataSource {
  Future<void> initServices();
  Future<void> disposeServices();
  Future<Uint8List?> takeScreenshot();
  Future<Uint8List?> takeHeadshot();
}

class TimerDataSourceImpl implements TimerDataSource {
  CameraController? _cameraController;
  MacosCamera? _macosCamera;
  @override
  Future<void> initServices() async {
    if (Platform.isMacOS) {
      _macosCamera = MacosCamera.instance;
      await _macosCamera!.disposeCamera();
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    if (_cameraController?.value.isInitialized == true) {
      return;
    }

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);
  }

  @override
  Future<Uint8List?> takeHeadshot() async {
    try {
      if (Platform.isMacOS) {
        final headshotImageFile = await _macosCamera!.capture();
        return headshotImageFile;
      }

      if (_cameraController?.value.isInitialized == true) {
        final headshotImageFile =
            await (await _cameraController?.takePicture())?.readAsBytes();
        return headshotImageFile;
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<Uint8List?> takeScreenshot() async {
    try {
      String? imagePath;
      if (Platform.isMacOS) {
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();

        imagePath =
            '${appDocumentsDir.path}/${DateTime.now().millisecond}-screenshot.png';
      }

      final capturedData = await screenCapturer.capture(
        mode: CaptureMode.screen,
        copyToClipboard: false,
        imagePath: imagePath,
      );
      Uint8List? screenshotDat;
      if (capturedData == null) {
        screenshotDat = await screenCapturer.readImageFromClipboard();
      } else {
        screenshotDat = capturedData.imageBytes;
      }

      return screenshotDat;
    } catch (e) {
      debugPrint(e.toString());

      return null;
    }
  }

  @override
  Future<void> disposeServices() async {
    await _cameraController?.dispose();
    await _macosCamera?.disposeCamera();
    _cameraController = null;
    _macosCamera = null;
  }
}

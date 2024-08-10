import 'dart:convert';

import 'package:flutter/services.dart';

class MacosCamera {
  MacosCamera._();

  static final MacosCamera _instance = MacosCamera._();

  static MacosCamera get instance => _instance;

  static const MethodChannel _channel = MethodChannel('macos_camera');

  Future<void> initCamera() async {
    await _channel.invokeMethod('initializeCamera');
  }

  Future<void> disposeCamera() async {
    await _channel.invokeMethod('disposeCamera');
  }

  Future<Uint8List?> capture() async {
    final data = await _channel.invokeMethod<String?>('captureImage');
    if (data == null) {
      return null;
    }
    return base64Decode(data);
  }
}

import 'dart:typed_data';

abstract interface class TimerRepository {
  Future<void> initServices();
  Future<void> disposeServices();

  Future<Uint8List?> takeScreenshot();
  Future<Uint8List?> takeHeadshot();
}

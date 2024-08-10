import 'dart:async';

import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';
import 'package:must_company_task/features/timer/domain/use_cases/dispose_timer_services_use_case.dart';

import 'package:must_company_task/features/timer/domain/use_cases/init_timer_services_use_case.dart';
import 'package:must_company_task/features/timer/domain/use_cases/take_headshot_use_case.dart';
import 'package:must_company_task/features/timer/domain/use_cases/take_screenshot_use_case.dart';
import 'package:rxdart/rxdart.dart';

class TimerViewModel {
  /// useCases

  final InitTimerServicesUseCase _initTimerServicesUseCase;
  final DisposeTimerServicesUseCase _disposeTimerServicesUseCase;
  final TakeHeadshotUseCase _takeHeadshotUseCase;
  final TakeScreenshotUseCase _takeScreenshotUseCase;

  /// Constructor
  TimerViewModel({
    required InitTimerServicesUseCase initTimerServicesUseCase,
    required DisposeTimerServicesUseCase disposeTimerServicesUseCase,
    required TakeHeadshotUseCase takeHeadshotUseCase,
    required TakeScreenshotUseCase takeScreenshotUseCase,
  })  : _initTimerServicesUseCase = initTimerServicesUseCase,
        _takeHeadshotUseCase = takeHeadshotUseCase,
        _disposeTimerServicesUseCase = disposeTimerServicesUseCase,
        _takeScreenshotUseCase = takeScreenshotUseCase {
    _initServices();
  }

  /// private variables
  static const _oneSec = Duration(seconds: 1);
  Timer? _timer;
  final BehaviorSubject<int> _counter = BehaviorSubject<int>.seeded(0);
  final BehaviorSubject<Uint8List?> _headshotImageFile =
      BehaviorSubject<Uint8List?>.seeded(null);
  final BehaviorSubject<Uint8List?> _screenshotImageFile =
      BehaviorSubject<Uint8List?>.seeded(null);
  final BehaviorSubject<bool> _isTimerRunning =
      BehaviorSubject<bool>.seeded(false);

  final BehaviorSubject<bool> _isInitialized =
      BehaviorSubject<bool>.seeded(false);

  CameraMacOSController? _macOSController;

  /// public variables
  late final ValueStream<int> counter = _counter.shareValue();
  late final ValueStream<bool> isTimerRunning = _isTimerRunning.shareValue();
  late final ValueStream<bool> isInitialized = _isInitialized.shareValue();

  late final ValueStream<Uint8List?> headshotImageFile =
      _headshotImageFile.shareValue();
  late final ValueStream<Uint8List?> screenshotImageFile =
      _screenshotImageFile.shareValue();

  /// Private methods
  void _initServices() async {
    await _initTimerServicesUseCase.call(null);
    _isInitialized.sink.add(true);
  }

  Future<void> _takeScreenshot() async {
    final data = await _takeScreenshotUseCase.call(null);
    _screenshotImageFile.sink.add(data.data);
  }

  Future<void> _takeHeadshot() async {
    final data = await _takeHeadshotUseCase.call(null);
    _headshotImageFile.sink.add(data.data);
  }

  /// Public methods
  void startTimer() {
    _isTimerRunning.sink.add(true);
    _timer = Timer.periodic(
      _oneSec,
      (_) async {
        // take screenshot every 5 seconds
        if (_counter.value % 5 != 0) {
          _counter.sink.add(_counter.value + 1);
          return;
        }

        _counter.sink.add(_counter.value + 1);

        await _takeScreenshot();
        await _takeHeadshot();
      },
    );
  }

  void pauseTimer() {
    _isTimerRunning.sink.add(false);
    _timer?.cancel();
    _timer = null;
  }

  void resetTimer() {
    _isTimerRunning.sink.add(false);
    _timer?.cancel();
    _timer = null;
    _counter.sink.add(0);
  }

  void setMacOSController(CameraMacOSController controller) {
    _macOSController = controller;
  }

  void dispose() {
    _disposeTimerServicesUseCase.call(null);
    _timer?.cancel();
    _isTimerRunning.close();
    _headshotImageFile.close();
    _macOSController?.destroy();
    _screenshotImageFile.close();
    _counter.close();
  }
}

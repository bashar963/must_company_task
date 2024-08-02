import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Must Company Timer app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _counter = 0;
  Directory? _screenshotsDirectory;
  List<CameraDescription> _cameras = [];
  Timer? _timer;
  var _timerRunning = false;
  static const oneSec = Duration(seconds: 10);
  CapturedData? _screenshotData;
  Uint8List? _headShotImageFile;
  CameraController? _cameraController;
  CameraMacOSController? macOSController;
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");
  @override
  void initState() {
    _initializeCameraController(null);

    _init();
    super.initState();
  }

  Future<void> _init() async {
    _screenshotsDirectory = await getApplicationDocumentsDirectory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  void _initializeCameraController(CameraDescription? description) async {
    if (Platform.isMacOS) {
      return;
    }

    if (description == null && _cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    if (_cameraController?.value.isInitialized == true) {
      await _cameraController?.dispose();
    }

    _cameraController =
        CameraController(description ?? _cameras[0], ResolutionPreset.max);
    _cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        debugPrint(e.toString());
      }
    });
  }

  void _startTimer() async {
    bool allowed = await screenCapturer.isAccessAllowed();

    if (!allowed) {
      await screenCapturer.requestAccess();
    }
    if (_timerRunning) {
      _timer?.cancel();
      setState(() {
        _timerRunning = false;
      });
      return;
    }

    setState(() {
      _timerRunning = true;
    });
    _timer = Timer.periodic(oneSec, (_) async {
      try {
        final Directory dir =
            _screenshotsDirectory ?? await getApplicationDocumentsDirectory();
        final capturedData = await screenCapturer.capture(
          mode: CaptureMode.screen,
          imagePath:
              '${dir.path}/screenshot-${DateTime.now().toIso8601String()}.png',
          copyToClipboard: false,
        );

        if (Platform.isMacOS) {
          if (macOSController != null) {
            final headShotImageFile = await macOSController!.takePicture();

            setState(() {
              _headShotImageFile = headShotImageFile?.bytes;
            });
          }
        } else {
          if (_cameraController?.value.isInitialized == true) {
            final headShotImageFile =
                await (await _cameraController?.takePicture())?.readAsBytes();
            setState(() {
              _headShotImageFile = headShotImageFile;
            });
          }
        }

        setState(() {
          _screenshotData = capturedData;
          _counter++;
        });
      } catch (e) {
        debugPrint(e.toString());
        setState(() {
          _counter++;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _screenshotData = null;
      _headShotImageFile = null;
      _timerRunning = false;
      _counter = 0;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (Platform.isMacOS)
              Visibility(
                visible: false,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: CameraMacOSView(
                    key: cameraKey,
                    fit: BoxFit.fill,
                    enableAudio: false,
                    cameraMode: CameraMacOSMode.photo,
                    onCameraInizialized: (CameraMacOSController controller) {
                      setState(() {
                        macOSController = controller;
                      });
                    },
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_headShotImageFile != null)
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 10,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('Head shot'),
                        Expanded(
                          child: Image.memory(_headShotImageFile!),
                        ),
                      ],
                    ),
                  ),
                if (_screenshotData?.imageBytes != null)
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 10,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('Screenshot'),
                        Expanded(
                          child: Image.memory(
                            _screenshotData!.imageBytes!,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _getTimerText(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            key: const Key('reset'),
            onPressed: _resetTimer,
            tooltip: 'Reset Timer',
            label: const Text('Reset Timer'),
            icon: const Icon(Icons.lock_reset),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            key: const Key('start_stop'),
            onPressed: _startTimer,
            tooltip: _timerRunning ? 'Stop Timer' : 'Start Timer',
            label: Text(_timerRunning ? 'Stop Timer' : 'Start Timer'),
            icon: Icon(_timerRunning ? Icons.stop : Icons.start),
          ),
        ],
      ),
    );
  }

  String _getTimerText() {
    var duration = Duration(seconds: _counter);
    String twoDigitMinutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}

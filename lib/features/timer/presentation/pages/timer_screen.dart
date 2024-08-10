import 'dart:io';
import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';

import 'package:flutter/material.dart';
import 'package:must_company_task/core/utils/time_formatter.dart';
import 'package:must_company_task/features/timer/presentation/manager/init_view_model.dart';
import 'package:must_company_task/features/timer/presentation/manager/timer_view_model.dart';
import 'package:must_company_task/features/timer/presentation/widgets/captured_data_widget.dart';
import 'package:must_company_task/features/timer/presentation/widgets/timer_controller_buttons.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  final GlobalKey cameraKey = GlobalKey(debugLabel: "cameraKey");

  late final TimerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = initViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Must Company Timer app'),
      ),
      body: StreamBuilder<bool>(
          stream: _viewModel.isInitialized,
          initialData: false,
          builder: (_, snapshot) {
            if (snapshot.requireData == false) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (Platform.isMacOS) _macOSCameraView(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<Uint8List?>(
                        stream: _viewModel.headshotImageFile,
                        builder: (_, snapshot) => CapturedDataWidget(
                          dataTitle: 'Headshot',
                          data: snapshot.data,
                        ),
                      ),
                      StreamBuilder<Uint8List?>(
                        stream: _viewModel.screenshotImageFile,
                        builder: (_, snapshot) => CapturedDataWidget(
                          dataTitle: 'Screenshot',
                          data: snapshot.data,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<int>(
                    stream: _viewModel.counter,
                    initialData: 0,
                    builder: (_, snapshot) => Text(
                      snapshot.requireData.formatFromSecondsToMMSS,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: TimerControllerButtons(
        onStartTimerPressed: _viewModel.startTimer,
        onPauseTimerPressed: _viewModel.pauseTimer,
        onResetTimerPressed: _viewModel.resetTimer,
        isTimerRunning: _viewModel.isTimerRunning,
      ),
    );
  }

  Widget _macOSCameraView() {
    return SizedBox(
      width: 0,
      height: 0,
      child: CameraMacOSView(
        key: cameraKey,
        fit: BoxFit.fill,
        enableAudio: false,
        cameraMode: CameraMacOSMode.photo,
        onCameraInizialized: (controller) {
          _viewModel.setMacOSController(controller);
        },
      ),
    );
  }
}

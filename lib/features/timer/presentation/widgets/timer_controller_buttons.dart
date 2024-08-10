import 'package:flutter/material.dart';

class TimerControllerButtons extends StatelessWidget {
  const TimerControllerButtons({
    super.key,
    required this.onStartTimerPressed,
    required this.onPauseTimerPressed,
    required this.onResetTimerPressed,
    required this.isTimerRunning,
  });

  final void Function()? onStartTimerPressed;
  final void Function()? onPauseTimerPressed;
  final void Function()? onResetTimerPressed;
  final Stream<bool> isTimerRunning;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          key: const Key('reset'),
          onPressed: onResetTimerPressed,
          tooltip: 'Reset Timer',
          label: const Text('Reset Timer'),
          icon: const Icon(Icons.lock_reset),
        ),
        const SizedBox(width: 10),
        StreamBuilder<bool>(
          stream: isTimerRunning,
          initialData: false,
          builder: (context, snapshot) {
            return FloatingActionButton.extended(
              key: const Key('start_stop'),
              onPressed: snapshot.requireData
                  ? onPauseTimerPressed
                  : onStartTimerPressed,
              tooltip: snapshot.requireData ? 'Pause Timer' : 'Start Timer',
              label: Text(snapshot.requireData ? 'Pause Timer' : 'Start Timer'),
              icon: Icon(
                snapshot.requireData ? Icons.pause_circle : Icons.play_circle,
              ),
            );
          },
        ),
      ],
    );
  }
}

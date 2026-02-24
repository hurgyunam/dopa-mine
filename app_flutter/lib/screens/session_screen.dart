import 'dart:async';

import 'package:dopa_mine/constants/app_constants.dart';
import 'package:dopa_mine/constants/app_strings.dart';
import 'package:dopa_mine/models/exercise.dart';
import 'package:dopa_mine/models/workout_session.dart';
import 'package:dopa_mine/providers/workout_provider.dart';
import 'package:dopa_mine/screens/report_screen.dart';
import 'package:dopa_mine/widgets/content_frame.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  int _repetitionCount = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(AppTiming.sessionTick, (_) {
      setState(() {
        _elapsed += AppTiming.sessionTick;
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _completeSession(WorkoutProvider provider) async {
    final WorkoutSession session = await provider.completeSession(
      duration: _elapsed,
      repetitionCount: _repetitionCount,
      isCompleted: true,
    );

    if (!mounted) {
      return;
    }

    final Exercise exercise = provider.selectedExercise!;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ReportScreen(
          exercise: exercise,
          session: session,
          points: session.pointsAwarded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (BuildContext context, WorkoutProvider provider, Widget? child) {
        final Exercise? exercise = provider.selectedExercise;
        if (exercise == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.sessionTitle)),
            body: const SafeArea(
              child: ContentFrame(
                child: Center(child: Text(AppStrings.noSelectedExercise)),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${exercise.name}${AppStrings.sessionSuffix}'),
          ),
          body: SafeArea(
            child: ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppLayout.mediumSpacing),
                  Text(
                    '${AppStrings.targetCountPrefix}${exercise.targetCount}${AppStrings.repetitionUnit}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppLayout.mediumSpacing),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppLayout.mediumSpacing,
                        vertical: AppLayout.mediumSpacing,
                      ),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppLayout.counterHorizontalInset,
                            ),
                            child: SizedBox(
                              width: AppLayout.counterButtonSize,
                              height: AppLayout.counterButtonSize,
                              child: IconButton.filledTonal(
                                onPressed: _repetitionCount == 0
                                    ? null
                                    : () {
                                        setState(() {
                                          _repetitionCount -= 1;
                                        });
                                      },
                                icon: const Icon(
                                  Icons.chevron_left,
                                  size: AppLayout.counterIconSize,
                                ),
                                tooltip: AppStrings.decreaseRepetition,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$_repetitionCount',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppLayout.counterHorizontalInset,
                            ),
                            child: SizedBox(
                              width: AppLayout.counterButtonSize,
                              height: AppLayout.counterButtonSize,
                              child: IconButton.filled(
                                onPressed: () {
                                  setState(() {
                                    _repetitionCount += 1;
                                  });
                                },
                                icon: const Icon(
                                  Icons.chevron_right,
                                  size: AppLayout.counterIconSize,
                                ),
                                tooltip: AppStrings.increaseRepetition,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      _formatDuration(_elapsed),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  const SizedBox(height: AppLayout.largeSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      child: Text(
                        _isRunning ? AppStrings.pause : AppStrings.start,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: AppLayout.bottomBarInsets,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.pagePadding,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppLayout.bottomButtonHeight,
                child: FilledButton(
                  onPressed:
                      ((_elapsed == Duration.zero && _repetitionCount == 0) ||
                          provider.isSaving)
                      ? null
                      : () => _completeSession(provider),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: AppLayout.loadingIndicatorSize,
                          height: AppLayout.loadingIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: AppLayout.loadingIndicatorStrokeWidth,
                          ),
                        )
                      : const Text(AppStrings.completeWorkout),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, AppStrings.timePaddingChar)}:${seconds.toString().padLeft(2, AppStrings.timePaddingChar)}';
  }
}

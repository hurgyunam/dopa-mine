import 'dart:async';

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
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
          points: exercise.metPoints,
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
            appBar: AppBar(title: const Text('세션')),
            body: const SafeArea(
              child: ContentFrame(child: Center(child: Text('선택된 운동이 없습니다.'))),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(exercise.name)),
          body: SafeArea(
            child: ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '목표 횟수: ${exercise.targetCount}회',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '현재 횟수: $_repetitionCount회',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: _repetitionCount == 0
                                ? null
                                : () {
                                    setState(() {
                                      _repetitionCount -= 1;
                                    });
                                  },
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: '횟수 감소',
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _repetitionCount += 1;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: '횟수 증가',
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      child: Text(_isRunning ? '일시정지' : '시작'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed:
                      ((_elapsed == Duration.zero && _repetitionCount == 0) ||
                          provider.isSaving)
                      ? null
                      : () => _completeSession(provider),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('운동 완료'),
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
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

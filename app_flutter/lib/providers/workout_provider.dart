import 'package:flutter/foundation.dart';

import 'package:dopa_mine/data/exercise_seed.dart';
import 'package:dopa_mine/models/exercise.dart';
import 'package:dopa_mine/models/workout_session.dart';
import 'package:dopa_mine/services/session_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  final List<Exercise> _exercises = kDefaultExercises;
  final List<WorkoutSession> _sessions = <WorkoutSession>[];

  Exercise? _selectedExercise;
  bool _isSaving = false;

  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get sessions => _sessions;
  Exercise? get selectedExercise => _selectedExercise;
  bool get isSaving => _isSaving;
  int get totalPoints {
    final Map<String, int> pointMap = <String, int>{
      for (final Exercise e in _exercises) e.id: e.metPoints,
    };
    return _sessions.fold<int>(
      0,
      (int sum, WorkoutSession s) => sum + (pointMap[s.exerciseId] ?? 0),
    );
  }

  void selectExercise(Exercise exercise) {
    _selectedExercise = exercise;
    notifyListeners();
  }

  Future<WorkoutSession> completeSession({
    required Duration duration,
    required int repetitionCount,
    required bool isCompleted,
  }) async {
    final Exercise? exercise = _selectedExercise;
    if (exercise == null) {
      throw StateError('No selected exercise.');
    }

    _isSaving = true;
    notifyListeners();

    final DateTime now = DateTime.now();
    final WorkoutSession session = WorkoutSession(
      id: '${exercise.id}-${now.microsecondsSinceEpoch}',
      exerciseId: exercise.id,
      startTime: now.subtract(duration),
      duration: duration,
      repetitionCount: repetitionCount,
      isCompleted: isCompleted,
    );

    try {
      final WorkoutSession saved = await _sessionRepository.saveSession(session);
      _sessions.add(saved);
      return saved;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:dopa_mine/constants/app_strings.dart';
import 'package:dopa_mine/data/exercise_seed.dart';
import 'package:dopa_mine/models/exercise.dart';
import 'package:dopa_mine/models/workout_session.dart';
import 'package:dopa_mine/services/session_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository {
    loadSessionHistory();
  }

  final SessionRepository _sessionRepository;

  final List<Exercise> _exercises = kDefaultExercises;
  final List<WorkoutSession> _sessionHistory = <WorkoutSession>[];

  Exercise? _selectedExercise;
  bool _isSaving = false;
  bool _isHistoryLoading = false;

  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get sessions => _sessionHistory;
  List<WorkoutSession> get sessionHistory => _sessionHistory;
  Exercise? get selectedExercise => _selectedExercise;
  bool get isSaving => _isSaving;
  bool get isHistoryLoading => _isHistoryLoading;
  int get totalPoints =>
      _sessionHistory.fold<int>(
        0,
        (int sum, WorkoutSession s) => sum + s.pointsAwarded,
      );

  Future<void> loadSessionHistory() async {
    _isHistoryLoading = true;
    notifyListeners();
    try {
      final List<WorkoutSession> fetched =
          await _sessionRepository.fetchSessionHistory();
      _sessionHistory
        ..clear()
        ..addAll(fetched);
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
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
      throw StateError(AppStrings.noSelectedExerciseError);
    }

    _isSaving = true;
    notifyListeners();

    final DateTime now = DateTime.now();
    final int pointsAwarded = _calculatePoints(
      metPoints: exercise.metPoints,
      duration: duration,
      repetitionCount: repetitionCount,
      isCompleted: isCompleted,
    );
    final WorkoutSession session = WorkoutSession(
      id: '${exercise.id}-${now.microsecondsSinceEpoch}',
      exerciseId: exercise.id,
      startTime: now.subtract(duration),
      duration: duration,
      repetitionCount: repetitionCount,
      isCompleted: isCompleted,
      pointsAwarded: pointsAwarded,
    );

    try {
      final WorkoutSession saved = await _sessionRepository.saveSession(session);
      _sessionHistory.insert(0, saved);
      return saved;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  int _calculatePoints({
    required int metPoints,
    required Duration duration,
    required int repetitionCount,
    required bool isCompleted,
  }) {
    if (!isCompleted) {
      return 0;
    }

    final double timeContribution = duration.inSeconds / 30;
    final double repetitionContribution = repetitionCount.toDouble();
    final double rawScore =
        metPoints * (0.6 * timeContribution + 0.4 * repetitionContribution);
    return math.max(1, rawScore.floor());
  }
}

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:dopa_mine/constants/app_strings.dart';
import 'package:dopa_mine/data/exercise_seed.dart';
import 'package:dopa_mine/models/exercise.dart';
import 'package:dopa_mine/models/workout_session.dart';
import 'package:dopa_mine/services/session_repository.dart';
import 'package:dopa_mine/services/supabase_rest_helper.dart';

enum WorkoutSaveStatus { idle, saving, saved, error }

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository {
    loadSessionHistory();
  }

  final SessionRepository _sessionRepository;

  final List<Exercise> _exercises = kDefaultExercises;
  final List<WorkoutSession> _sessionHistory = <WorkoutSession>[];

  Exercise? _selectedExercise;
  WorkoutSaveStatus _saveStatus = WorkoutSaveStatus.idle;
  String? _lastSaveErrorCode;
  String? _lastSaveErrorMessage;
  bool _isHistoryLoading = false;

  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get sessions => _sessionHistory;
  List<WorkoutSession> get sessionHistory => _sessionHistory;
  Exercise? get selectedExercise => _selectedExercise;
  bool get isSaving => _saveStatus == WorkoutSaveStatus.saving;
  WorkoutSaveStatus get saveStatus => _saveStatus;
  String? get lastSaveErrorCode => _lastSaveErrorCode;
  String? get lastSaveErrorMessage => _lastSaveErrorMessage;
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

    _saveStatus = WorkoutSaveStatus.saving;
    _lastSaveErrorCode = null;
    _lastSaveErrorMessage = null;
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
      _saveStatus = WorkoutSaveStatus.saved;
      return saved;
    } on SupabaseApiException catch (error) {
      _saveStatus = WorkoutSaveStatus.error;
      _lastSaveErrorCode = error.code;
      _lastSaveErrorMessage = error.message;
      rethrow;
    } catch (_) {
      _saveStatus = WorkoutSaveStatus.error;
      _lastSaveErrorCode = 'unknown_save_error';
      _lastSaveErrorMessage = '운동 저장 중 알 수 없는 오류가 발생했습니다.';
      rethrow;
    } finally {
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

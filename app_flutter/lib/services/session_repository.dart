import 'package:dopa_mine/constants/app_constants.dart';
import 'package:dopa_mine/models/workout_session.dart';
import 'package:dopa_mine/services/supabase_workout_persistence_api.dart';
import 'package:dopa_mine/services/supabase_rest_helper.dart';
import 'package:flutter/foundation.dart';

abstract class SessionRepository {
  Future<WorkoutSession> saveSession(WorkoutSession session);
  Future<List<WorkoutSession>> fetchSessionHistory();
}

class MockSupabaseSessionRepository implements SessionRepository {
  final List<WorkoutSession> _historyStorage = <WorkoutSession>[];

  @override
  Future<WorkoutSession> saveSession(WorkoutSession session) async {
    // 실제 Supabase 연동 시 이 지점에서 insert/upsert를 수행하면 된다.
    await Future<void>.delayed(AppTiming.mockSaveDelay);
    _historyStorage.add(session);
    return session;
  }

  @override
  Future<List<WorkoutSession>> fetchSessionHistory() async {
    await Future<void>.delayed(AppTiming.mockSaveDelay);
    return _historyStorage.reversed.toList(growable: false);
  }
}

class SupabaseSessionRepository implements SessionRepository {
  SupabaseSessionRepository({
    required SupabaseRestHelper restHelper,
  })  : _restHelper = restHelper,
        _workoutApi = SupabaseWorkoutPersistenceApi(restHelper: restHelper);

  final SupabaseRestHelper _restHelper;
  final SupabaseWorkoutPersistenceApi _workoutApi;

  @override
  Future<WorkoutSession> saveSession(WorkoutSession session) async {
    final String requestId = 'save-${session.id}';
    try {
      await _workoutApi.createSession(
        sessionId: session.id,
        exerciseId: session.exerciseId,
        startedAt: session.startTime,
      );
      await _workoutApi.saveRepetition(
        sessionId: session.id,
        exerciseId: session.exerciseId,
        repetitionCount: session.repetitionCount,
        durationSeconds: session.duration.inSeconds,
        idempotencyKey: '${session.id}-${session.repetitionCount}',
      );
      await _workoutApi.completeSession(
        sessionId: session.id,
        totalRepetitionCount: session.repetitionCount,
        pointsAwarded: session.pointsAwarded,
        isCompleted: session.isCompleted,
      );

      final List<Map<String, dynamic>> rows = await _restHelper.getTable(
        table: 'workout_sessions',
        query: <String, String>{
          'select':
              'id,exercise_id,start_time,duration_seconds,repetition_count,is_completed,points_awarded',
          'id': 'eq.${session.id}',
          'limit': '1',
        },
      );

      if (rows.isEmpty) {
        return session;
      }
      return _toWorkoutSession(rows.first);
    } on SupabaseApiException catch (error) {
      debugPrint(
        '[SupabaseSessionRepository][$requestId] code=${error.code} message=${error.message}',
      );
      rethrow;
    }
  }

  @override
  Future<List<WorkoutSession>> fetchSessionHistory() async {
    final List<Map<String, dynamic>> rows = await _restHelper.getTable(
      table: 'workout_sessions',
      query: <String, String>{
        'select':
            'id,exercise_id,start_time,duration_seconds,repetition_count,is_completed,points_awarded',
        'order': 'start_time.desc',
      },
    );

    return rows.map(_toWorkoutSession).toList(growable: false);
  }

  WorkoutSession _toWorkoutSession(Map<String, dynamic> row) {
    return WorkoutSession(
      id: row['id'].toString(),
      exerciseId: row['exercise_id'].toString(),
      startTime: DateTime.parse(row['start_time'].toString()),
      duration: Duration(seconds: _asInt(row['duration_seconds'])),
      repetitionCount: _asInt(row['repetition_count']),
      isCompleted: _asBool(row['is_completed']),
      pointsAwarded: _asInt(row['points_awarded']),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }
}

import 'package:dopa_mine/services/supabase_rest_helper.dart';

class SupabaseWorkoutPersistenceApi {
  SupabaseWorkoutPersistenceApi({
    required SupabaseRestHelper restHelper,
  }) : _restHelper = restHelper;

  final SupabaseRestHelper _restHelper;

  Future<String> createSession({
    required String sessionId,
    required String exerciseId,
    required DateTime startedAt,
  }) async {
    final List<Map<String, dynamic>> created = await _restHelper.postTable(
      table: 'workout_sessions',
      rows: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': sessionId,
          'exercise_id': exerciseId,
          'start_time': startedAt.toIso8601String(),
          'status': 'in_progress',
        },
      ],
      returnRepresentation: true,
    );

    if (created.isEmpty || created.first['id'] == null) {
      throw SupabaseApiException(
        statusCode: 500,
        code: 'session_create_empty',
        message: '세션 생성 응답이 비어 있습니다.',
      );
    }
    return created.first['id'].toString();
  }

  Future<void> saveRepetition({
    required String sessionId,
    required String exerciseId,
    required int repetitionCount,
    required int durationSeconds,
    required String idempotencyKey,
  }) async {
    await _restHelper.postTable(
      table: 'repetition_logs',
      rows: <Map<String, dynamic>>[
        <String, dynamic>{
          'session_id': sessionId,
          'exercise_id': exerciseId,
          'repetition_count': repetitionCount,
          'duration_seconds': durationSeconds,
          'idempotency_key': idempotencyKey,
        },
      ],
      returnRepresentation: false,
    );
  }

  Future<void> completeSession({
    required String sessionId,
    required int totalRepetitionCount,
    required int pointsAwarded,
    required bool isCompleted,
  }) async {
    await _restHelper.patchTable(
      table: 'workout_sessions',
      query: <String, String>{
        'id': 'eq.$sessionId',
      },
      row: <String, dynamic>{
        'repetition_count': totalRepetitionCount,
        'points_awarded': pointsAwarded,
        'is_completed': isCompleted,
        'status': isCompleted ? 'completed' : 'cancelled',
        'completed_at': DateTime.now().toIso8601String(),
      },
      returnRepresentation: false,
    );
  }
}

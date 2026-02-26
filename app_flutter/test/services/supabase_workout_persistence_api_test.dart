import 'package:dopa_mine/services/supabase_rest_helper.dart';
import 'package:dopa_mine/services/supabase_workout_persistence_api.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSupabaseRestHelper extends SupabaseRestHelper {
  _FakeSupabaseRestHelper()
      : super(
          supabaseUrl: 'https://example.supabase.co',
          publishableKey: 'test-key',
          accessTokenProvider: () async => 'test-token',
        );

  List<Map<String, dynamic>> postResult = <Map<String, dynamic>>[];
  String? lastPostTable;
  List<Map<String, dynamic>>? lastPostRows;

  String? lastPatchTable;
  Map<String, String>? lastPatchQuery;
  Map<String, dynamic>? lastPatchRow;

  @override
  Future<List<Map<String, dynamic>>> postTable({
    required String table,
    required List<Map<String, dynamic>> rows,
    Map<String, String> query = const <String, String>{},
    bool returnRepresentation = false,
  }) async {
    lastPostTable = table;
    lastPostRows = rows;
    return postResult;
  }

  @override
  Future<List<Map<String, dynamic>>> patchTable({
    required String table,
    required Map<String, dynamic> row,
    required Map<String, String> query,
    bool returnRepresentation = false,
  }) async {
    lastPatchTable = table;
    lastPatchQuery = query;
    lastPatchRow = row;
    return const <Map<String, dynamic>>[];
  }
}

void main() {
  group('SupabaseWorkoutPersistenceApi', () {
    test('createSession should insert workout session and return id', () async {
      final _FakeSupabaseRestHelper fakeHelper = _FakeSupabaseRestHelper();
      fakeHelper.postResult = <Map<String, dynamic>>[
        <String, dynamic>{'id': 'session-123'},
      ];
      final SupabaseWorkoutPersistenceApi api = SupabaseWorkoutPersistenceApi(
        restHelper: fakeHelper,
      );

      final String sessionId = await api.createSession(
        sessionId: 'session-123',
        exerciseId: 'ex-1',
        startedAt: DateTime.parse('2026-02-26T12:00:00.000Z'),
      );

      expect(sessionId, 'session-123');
      expect(fakeHelper.lastPostTable, 'workout_sessions');
      expect(fakeHelper.lastPostRows, isNotNull);
      expect(fakeHelper.lastPostRows!.first['status'], 'in_progress');
    });

    test('saveRepetition should insert repetition log', () async {
      final _FakeSupabaseRestHelper fakeHelper = _FakeSupabaseRestHelper();
      final SupabaseWorkoutPersistenceApi api = SupabaseWorkoutPersistenceApi(
        restHelper: fakeHelper,
      );

      await api.saveRepetition(
        sessionId: 'session-1',
        exerciseId: 'ex-1',
        repetitionCount: 10,
        durationSeconds: 45,
        idempotencyKey: 'idem-1',
      );

      expect(fakeHelper.lastPostTable, 'repetition_logs');
      expect(fakeHelper.lastPostRows, isNotNull);
      expect(fakeHelper.lastPostRows!.first['idempotency_key'], 'idem-1');
    });

    test('completeSession should patch workout session status', () async {
      final _FakeSupabaseRestHelper fakeHelper = _FakeSupabaseRestHelper();
      final SupabaseWorkoutPersistenceApi api = SupabaseWorkoutPersistenceApi(
        restHelper: fakeHelper,
      );

      await api.completeSession(
        sessionId: 'session-1',
        totalRepetitionCount: 30,
        pointsAwarded: 100,
        isCompleted: true,
      );

      expect(fakeHelper.lastPatchTable, 'workout_sessions');
      expect(fakeHelper.lastPatchQuery?['id'], 'eq.session-1');
      expect(fakeHelper.lastPatchRow?['status'], 'completed');
    });
  });
}

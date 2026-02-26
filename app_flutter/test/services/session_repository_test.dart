import 'package:dopa_mine/models/workout_session.dart';
import 'package:dopa_mine/services/session_repository.dart';
import 'package:dopa_mine/services/supabase_rest_helper.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSupabaseRestHelper extends SupabaseRestHelper {
  _FakeSupabaseRestHelper()
      : super(
          supabaseUrl: 'https://example.supabase.co',
          publishableKey: 'test-key',
          accessTokenProvider: () async => 'test-token',
        );

  List<Map<String, dynamic>> postResult = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> getResult = <Map<String, dynamic>>[];

  String? lastPostTable;
  List<Map<String, dynamic>>? lastPostRows;
  final List<String> postTables = <String>[];
  Map<String, dynamic>? lastPatchRow;
  Map<String, String>? lastPatchQuery;
  Map<String, String>? lastGetQuery;

  @override
  Future<List<Map<String, dynamic>>> postTable({
    required String table,
    required List<Map<String, dynamic>> rows,
    Map<String, String> query = const <String, String>{},
    bool returnRepresentation = false,
  }) async {
    lastPostTable = table;
    lastPostRows = rows;
    postTables.add(table);
    return postResult;
  }

  @override
  Future<List<Map<String, dynamic>>> patchTable({
    required String table,
    required Map<String, dynamic> row,
    required Map<String, String> query,
    bool returnRepresentation = false,
  }) async {
    lastPatchRow = row;
    lastPatchQuery = query;
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<List<Map<String, dynamic>>> getTable({
    required String table,
    Map<String, String> query = const <String, String>{},
  }) async {
    lastGetQuery = query;
    return getResult;
  }
}

void main() {
  group('SupabaseSessionRepository', () {
    // saveSession 호출 시 workout_sessions 테이블로 POST되는지와
    // Supabase 응답이 WorkoutSession으로 올바르게 매핑되는지 검증한다.
    test('saveSession should post and map response', () async {
      final _FakeSupabaseRestHelper fakeHelper = _FakeSupabaseRestHelper();
      fakeHelper.postResult = <Map<String, dynamic>>[
        <String, dynamic>{'id': 's1'},
      ];
      fakeHelper.getResult = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 's1',
          'exercise_id': 'ex1',
          'start_time': '2026-02-26T10:00:00.000Z',
          'duration_seconds': 90,
          'repetition_count': 12,
          'is_completed': true,
          'points_awarded': 17,
        },
      ];
      final SupabaseSessionRepository repository = SupabaseSessionRepository(
        restHelper: fakeHelper,
      );

      final WorkoutSession saved = await repository.saveSession(
        WorkoutSession(
          id: 's1',
          exerciseId: 'ex1',
          startTime: DateTime.parse('2026-02-26T10:00:00.000Z'),
          duration: const Duration(seconds: 90),
          repetitionCount: 12,
          isCompleted: true,
          pointsAwarded: 17,
        ),
      );

      expect(fakeHelper.postTables, <String>['workout_sessions', 'repetition_logs']);
      expect(fakeHelper.lastPostRows, isNotNull);
      expect(fakeHelper.lastPatchQuery?['id'], 'eq.s1');
      expect(saved.id, 's1');
      expect(saved.exerciseId, 'ex1');
      expect(saved.duration.inSeconds, 90);
      expect(saved.repetitionCount, 12);
      expect(saved.isCompleted, isTrue);
      expect(saved.pointsAwarded, 17);
    });

    // fetchSessionHistory 호출 시 정렬 쿼리(order=start_time.desc)를 사용하고,
    // 조회 결과가 WorkoutSession 리스트로 변환되는지 검증한다.
    test('fetchSessionHistory should request ordered select and map rows', () async {
      final _FakeSupabaseRestHelper fakeHelper = _FakeSupabaseRestHelper();
      fakeHelper.getResult = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 's2',
          'exercise_id': 'ex2',
          'start_time': '2026-02-26T11:00:00.000Z',
          'duration_seconds': 30,
          'repetition_count': 5,
          'is_completed': false,
          'points_awarded': 0,
        },
      ];
      final SupabaseSessionRepository repository = SupabaseSessionRepository(
        restHelper: fakeHelper,
      );

      final List<WorkoutSession> history = await repository.fetchSessionHistory();

      expect(fakeHelper.lastGetQuery?['order'], 'start_time.desc');
      expect(history, hasLength(1));
      expect(history.first.id, 's2');
      expect(history.first.isCompleted, isFalse);
    });
  });
}

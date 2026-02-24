import 'package:dopa_mine/constants/app_constants.dart';
import 'package:dopa_mine/models/workout_session.dart';

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

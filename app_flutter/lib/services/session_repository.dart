import 'package:dopa_mine/models/workout_session.dart';

abstract class SessionRepository {
  Future<WorkoutSession> saveSession(WorkoutSession session);
}

class MockSupabaseSessionRepository implements SessionRepository {
  final List<WorkoutSession> _storage = <WorkoutSession>[];

  @override
  Future<WorkoutSession> saveSession(WorkoutSession session) async {
    // 실제 Supabase 연동 시 이 지점에서 insert/upsert를 수행하면 된다.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _storage.add(session);
    return session;
  }
}

import 'package:dopa_mine/constants/runtime_env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuntimeEnv', () {
    test('dotenv에 값이 있으면 해당 값을 우선 사용한다', () {
      dotenv.testLoad(
        fileInput: '''
SUPABASE_URL=https://example.supabase.co
SUPABASE_PUBLISHABLE_KEY=publishable-test-key
''',
      );

      expect(RuntimeEnv.supabaseUrl, 'https://example.supabase.co');
      expect(RuntimeEnv.supabasePublishableKey, 'publishable-test-key');
      expect(RuntimeEnv.hasSupabaseHttpConfig, isTrue);
    });

    test('publishable key가 없으면 anon key를 fallback으로 사용한다', () {
      dotenv.testLoad(
        fileInput: '''
SUPABASE_URL=https://example.supabase.co
SUPABASE_ANON_KEY=anon-fallback-key
''',
      );

      expect(RuntimeEnv.supabasePublishableKey, 'anon-fallback-key');
      expect(RuntimeEnv.hasSupabaseHttpConfig, isTrue);
    });

    test('dotenv 값이 비어 있으면 설정 미완료 상태로 판단한다', () {
      dotenv.testLoad(fileInput: '');

      expect(RuntimeEnv.supabaseUrl, isEmpty);
      expect(RuntimeEnv.supabasePublishableKey, isEmpty);
      expect(RuntimeEnv.hasSupabaseHttpConfig, isFalse);
    });
  });
}

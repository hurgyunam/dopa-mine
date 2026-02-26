import 'package:flutter_dotenv/flutter_dotenv.dart';

class RuntimeEnv {
  static String get supabaseUrl => _read('SUPABASE_URL');

  static String get supabasePublishableKey {
    final String publishable = _read('SUPABASE_PUBLISHABLE_KEY');
    if (publishable.isNotEmpty) {
      return publishable;
    }
    return _read('SUPABASE_ANON_KEY');
  }

  static bool get hasSupabaseHttpConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String _read(String key) {
    final String dotenvValue = _readDotenvValue(key);
    if (dotenvValue.isNotEmpty) {
      return dotenvValue;
    }
    return _readDartDefineValue(key);
  }

  static String _readDotenvValue(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String _readDartDefineValue(String key) {
    switch (key) {
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL');
      case 'SUPABASE_PUBLISHABLE_KEY':
        return const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY');
      default:
        return '';
    }
  }
}

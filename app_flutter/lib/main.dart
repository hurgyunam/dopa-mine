import 'dart:io';

import 'package:dopa_mine/constants/app_constants.dart';
import 'package:dopa_mine/constants/app_strings.dart';
import 'package:dopa_mine/constants/runtime_env.dart';
import 'package:dopa_mine/providers/workout_provider.dart';
import 'package:dopa_mine/screens/home_screen.dart';
import 'package:dopa_mine/services/auth_session_token_provider.dart';
import 'package:dopa_mine/services/session_repository.dart';
import 'package:dopa_mine/services/supabase_rest_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadDotenvIfExists();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: AppWindow.fixedSize,
      minimumSize: AppWindow.fixedSize,
      maximumSize: AppWindow.fixedSize,
      center: true,
      backgroundColor: AppThemeTokens.darkBackgroundColor,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const DopaMineApp());
}

Future<void> _loadDotenvIfExists() async {
  try {
    await dotenv.load(fileName: '.env.local');
  } catch (_) {
    // .env.local이 없어도 dart-define fallback으로 동작한다.
  }
}

class DopaMineApp extends StatelessWidget {
  const DopaMineApp({super.key});

  static final InMemoryAuthSessionTokenProvider _authTokenProvider =
      InMemoryAuthSessionTokenProvider();

  SessionRepository _buildSessionRepository() {
    if (!RuntimeEnv.hasSupabaseHttpConfig) {
      return MockSupabaseSessionRepository();
    }

    return SupabaseSessionRepository(
      restHelper: SupabaseRestHelper(
        supabaseUrl: RuntimeEnv.supabaseUrl,
        publishableKey: RuntimeEnv.supabasePublishableKey,
        accessTokenProvider: _authTokenProvider.getAccessToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WorkoutProvider>(
      create: (_) => WorkoutProvider(sessionRepository: _buildSessionRepository()),
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
          scaffoldBackgroundColor: AppThemeTokens.darkBackgroundColor,
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppLayout.cardRadius),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

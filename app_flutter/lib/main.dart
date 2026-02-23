import 'dart:io';

import 'package:dopa_mine/providers/workout_provider.dart';
import 'package:dopa_mine/screens/home_screen.dart';
import 'package:dopa_mine/services/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: Size(400, 800),
      minimumSize: Size(400, 800),
      maximumSize: Size(400, 800),
      center: true,
      backgroundColor: Color(0xFF121212),
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const DopaMineApp());
}

class DopaMineApp extends StatelessWidget {
  const DopaMineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WorkoutProvider>(
      create: (_) =>
          WorkoutProvider(sessionRepository: MockSupabaseSessionRepository()),
      child: MaterialApp(
        title: 'Dopa-mine',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

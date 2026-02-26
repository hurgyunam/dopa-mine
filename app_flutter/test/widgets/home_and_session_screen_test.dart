import 'package:dopa_mine/constants/app_strings.dart';
import 'package:dopa_mine/data/exercise_seed.dart';
import 'package:dopa_mine/providers/workout_provider.dart';
import 'package:dopa_mine/screens/home_screen.dart';
import 'package:dopa_mine/screens/session_screen.dart';
import 'package:dopa_mine/services/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildWithProvider({
  required WorkoutProvider provider,
  required Widget child,
}) {
  return ChangeNotifierProvider<WorkoutProvider>.value(
    value: provider,
    child: MaterialApp(home: child),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('운동 선택 전에는 시작 버튼이 비활성화되고 선택 후 활성화된다', (WidgetTester tester) async {
      final WorkoutProvider provider = WorkoutProvider(
        sessionRepository: MockSupabaseSessionRepository(),
      );

      await tester.pumpWidget(
        _buildWithProvider(provider: provider, child: const HomeScreen()),
      );
      await tester.pump(const Duration(milliseconds: 600));

      final Finder startButton = find.widgetWithText(FilledButton, AppStrings.startWorkout);
      expect(tester.widget<FilledButton>(startButton).onPressed, isNull);

      await tester.tap(find.text(kDefaultExercises.first.name));
      await tester.pump();

      expect(tester.widget<FilledButton>(startButton).onPressed, isNotNull);
    });
  });

  group('SessionScreen', () {
    testWidgets('선택된 운동이 없으면 안내 문구를 표시한다', (WidgetTester tester) async {
      final WorkoutProvider provider = WorkoutProvider(
        sessionRepository: MockSupabaseSessionRepository(),
      );

      await tester.pumpWidget(
        _buildWithProvider(provider: provider, child: const SessionScreen()),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text(AppStrings.noSelectedExercise), findsOneWidget);
    });

    testWidgets('횟수 증가 버튼을 누르면 카운터가 증가한다', (WidgetTester tester) async {
      final WorkoutProvider provider = WorkoutProvider(
        sessionRepository: MockSupabaseSessionRepository(),
      );
      provider.selectExercise(kDefaultExercises.first);

      await tester.pumpWidget(
        _buildWithProvider(provider: provider, child: const SessionScreen()),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byTooltip(AppStrings.increaseRepetition));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });
}

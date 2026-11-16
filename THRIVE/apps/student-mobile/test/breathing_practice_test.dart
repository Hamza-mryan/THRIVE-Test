import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thrive_student/design_system/thrive_theme.dart';
import 'package:thrive_student/features/guide/presentation/breathing_practice.dart';
import 'package:thrive_student/l10n/app_localizations.dart';

Widget practice() => MaterialApp(
  theme: thriveTheme(),
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Scaffold(body: SingleChildScrollView(child: BreathingPractice())),
);

void main() {
  testWidgets('opening urgent help pauses the hidden practice', (tester) async {
    await tester.pumpWidget(practice());
    await tester.tap(find.text('Start practice'));
    await tester.pump(const Duration(seconds: 2));
    final context = tester.element(find.byType(BreathingPractice));
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const SizedBox(height: 200, child: Text('Urgent help')),
    );
    await tester.pumpAndSettle();
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(find.text('Start practice'), findsOneWidget);
    expect(find.text('04:58'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('04:58'), findsOneWidget);
  });
  testWidgets(
    'practice only starts by choice and pauses when app goes inactive',
    (tester) async {
      await tester.pumpWidget(practice());
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('05:00'), findsOneWidget);
      await tester.tap(find.text('Start practice'));
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('04:54'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.text('Start practice'), findsOneWidget);
      await tester.pump(const Duration(seconds: 20));
      expect(find.text('04:54'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('practice completes and resets without leaving a running timer', (
    tester,
  ) async {
    await tester.pumpWidget(practice());
    await tester.tap(find.text('Start practice'));
    await tester.pump(const Duration(minutes: 5));
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Time complete. Take your time.'), findsOneWidget);
    await tester.ensureVisible(find.text('Reset'));
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('05:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'dart:math' as math;
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thrive_student/design_system/thrive_theme.dart';
import 'package:thrive_student/features/home/home_screen.dart';
import 'package:thrive_student/l10n/app_localizations.dart';
import 'package:thrive_student/app/thrive_app.dart';
import 'package:thrive_student/features/onboarding/application/onboarding_controller.dart';
import 'package:thrive_student/features/onboarding/data/onboarding_repository.dart';

class _UnusedOnboarding implements OnboardingRepository {
  @override
  Future<void> startDevelopmentSession() async =>
      throw StateError('No sign-in in a presentation test');
  @override
  Future<ConsentPolicy> currentPolicy() async =>
      throw StateError('No policy request in a presentation test');
  @override
  Future<ConsentChoices?> currentChoices() async =>
      throw StateError('No consent request in a presentation test');
  @override
  Future<void> saveChoices(ConsentChoices choices) async =>
      throw StateError('No consent write in a presentation test');
  @override
  void signOut() {}
}

Widget homeApp({
  String locale = 'en',
  double scale = 1,
  ValueChanged<String>? onPath,
  VoidCallback? onHistory,
}) => MaterialApp(
  theme: thriveTheme(),
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    body: HomeScreen(onPath: onPath, onHistory: onHistory),
  ),
);

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (math.max(a, b) + .05) / (math.min(a, b) + .05);
}

void main() {
  testWidgets('path titles meet normal-text contrast against their surface', (
    tester,
  ) async {
    await tester.pumpWidget(homeApp(onPath: (_) {}));
    for (final title in [
      'THRIVE Check',
      'THRIVE Guide',
      'THRIVE Connect',
      'THRIVE Plus',
    ]) {
      final text = find.text(title);
      final foreground = tester.widget<Text>(text).style!.color!;
      final surface = tester
          .widget<Material>(
            find.ancestor(of: text, matching: find.byType(Material)).first,
          )
          .color!;
      expect(
        contrast(foreground, surface),
        greaterThanOrEqualTo(4.5),
        reason: title,
      );
    }
  });

  test('supporting text meets normal-text contrast on the canvas', () {
    expect(
      contrast(ThriveColors.muted, ThriveColors.canvas),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('every path and history keeps its existing callback', (
    tester,
  ) async {
    final paths = <String>[];
    var history = 0;
    await tester.pumpWidget(
      homeApp(onPath: paths.add, onHistory: () => history++),
    );
    for (final path in ['check', 'guide', 'connect', 'plus']) {
      final tile = find.byKey(Key('home-path-$path'));
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pump();
    }
    expect(paths, ['check', 'guide', 'connect', 'plus']);
    final historyAction = find.byKey(const Key('home-history'));
    await tester.ensureVisible(historyAction);
    await tester.tap(historyAction);
    expect(history, 1);
    final start = find.text('Start demonstration');
    await tester.ensureVisible(start);
    await tester.tap(start);
    expect(paths.last, 'check');
    expect(paths.length, 5);
  });

  testWidgets('a path exposes one named accessible tap action', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(homeApp(onPath: (_) {}));
      final tile = find.byKey(const Key('home-path-check'));
      await tester.ensureVisible(tile);
      final data = tester.getSemantics(tile).getSemanticsData();
      final l = AppLocalizations.of(tester.element(find.byType(HomeScreen)));
      expect(data.label, l.openNamedPath(l.checkTitle));
      expect(data.hint, l.checkBody);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
    } finally {
      semantics.dispose();
    }
  });

  for (final locale in ['ar', 'en']) {
    for (final config in [
      (size: const Size(320, 700), scale: 1.0),
      (size: const Size(375, 812), scale: 2.0),
      (size: const Size(812, 375), scale: 2.0),
      (size: const Size(1024, 768), scale: 1.0),
    ]) {
      testWidgets('home reflows $locale at ${config.size} / ${config.scale}x', (
        tester,
      ) async {
        tester.view.physicalSize = config.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          homeApp(locale: locale, scale: config.scale, onPath: (_) {}),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final lastPath = find.byKey(const Key('home-path-plus'));
        await tester.ensureVisible(lastPath);
        await tester.tap(lastPath);
        expect(tester.takeException(), isNull);
      });
    }
    for (final size in [const Size(320, 700), const Size(812, 375)]) {
      testWidgets(
        'signed-in shell keeps urgent help and navigation $locale at $size / 2x',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final controller = OnboardingController(
            repository: _UnusedOnboarding(),
          )..stage = OnboardingStage.home;
          await tester.pumpWidget(ThriveApp(controller: controller));
          await tester.pumpAndSettle();
          if (locale == 'en') {
            await tester.tap(find.text('English'));
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull);
          expect(find.byType(NavigationBar), findsOneWidget);
          final l = AppLocalizations.of(
            tester.element(find.byType(HomeScreen)),
          );
          expect(l.localeName, locale);
          await tester.tap(find.byKey(const Key('urgent-help')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text(l.safetyTitle), findsOneWidget);
        },
      );
    }
  }
}

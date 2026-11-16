import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrive_student/app/student_services.dart';
import 'package:thrive_student/app/thrive_app.dart';
import 'package:thrive_student/features/account/presentation/account_screen.dart';
import 'package:thrive_student/features/guide/presentation/guide_screen.dart';
import 'package:thrive_student/features/history/history_screen.dart';
import 'package:thrive_student/features/home/home_screen.dart';
import 'package:thrive_student/features/referrals/presentation/referral_screens.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/features/activity/presentation/home_activity_card.dart';
import 'package:thrive_student/features/onboarding/application/onboarding_controller.dart';
import 'package:thrive_student/features/onboarding/data/onboarding_repository.dart';

class _NoOnboardingRequests implements OnboardingRepository {
  @override
  Future<void> startDevelopmentSession() async =>
      throw StateError('Unexpected sign-in');
  @override
  Future<ConsentPolicy> currentPolicy() async =>
      throw StateError('Unexpected policy request');
  @override
  Future<ConsentChoices?> currentChoices() async =>
      throw StateError('Unexpected consent read');
  @override
  Future<void> saveChoices(ConsentChoices choices) async =>
      throw StateError('Unexpected consent write');
  @override
  void signOut() {}
}

ThriveApi _navigationApi() {
  return ThriveApi(
    baseUrl: Uri.parse('http://localhost:5280'),
    client: MockClient((request) async {
      expect(request.method, 'GET');
      final Object data = switch (request.url.path) {
        '/api/v1/me/activity' => {
          'completedScreenings': 0,
          'inProgressScreenings': 0,
          'openReferrals': 0,
        },
        '/api/v1/me' => {
          'displayName': 'Synthetic student',
          'isDevelopmentIdentity': true,
        },
        '/api/v1/me/consents' => {
          'policyVersion': 'test-1',
          'serviceUse': true,
          'researchUse': false,
        },
        '/api/v1/me/moods' ||
        '/api/v1/me/screenings' ||
        '/api/v1/guide/resources' ||
        '/api/v1/me/referrals' => <Object>[],
        _ => throw StateError('Unexpected navigation request'),
      };
      return http.Response(
        jsonEncode(data),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final configuration in [
    (size: const Size(1200, 900), scale: 1.0, rail: true),
    (size: const Size(1200, 260), scale: 1.0, rail: false),
    (size: const Size(1200, 500), scale: 1.0, rail: false),
    (size: const Size(1200, 600), scale: 1.0, rail: true),
    (size: const Size(700, 320), scale: 1.0, rail: false),
    (size: const Size(800, 600), scale: 1.5, rail: false),
    (size: const Size(320, 700), scale: 2.0, rail: false),
    (size: const Size(1200, 900), scale: 2.0, rail: false),
  ]) {
    testWidgets(
      'navigation keeps every student destination functional at $configuration',
      (tester) async {
        tester.view.physicalSize = configuration.size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = configuration.scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final api = _navigationApi();
        addTearDown(api.close);
        final controller = OnboardingController(
          repository: _NoOnboardingRequests(),
        )..stage = OnboardingStage.home;
        await tester.pumpWidget(
          ThriveApp(controller: controller, services: StudentServices(api)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();
        final navigation = configuration.rail ? NavigationRail : NavigationBar;
        expect(find.byType(navigation), findsOneWidget);
        for (final destination in [
          ('History', HistoryScreen),
          ('Guide', GuideScreen),
          ('Referrals', ReferralsScreen),
          ('Account', AccountScreen),
          ('Home', HomeScreen),
        ]) {
          final target = find.descendant(
            of: find.byType(navigation),
            matching: find.text(destination.$1),
          );
          await tester.ensureVisible(target);
          await tester.tap(target);
          await tester.pumpAndSettle();
          expect(find.byType(destination.$2), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        final semantics = tester.ensureSemantics();
        try {
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        } finally {
          semantics.dispose();
        }
      },
    );
  }
  testWidgets(
    'guide search and saved-only choice survive a navigation breakpoint resize',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = _navigationApi();
      addTearDown(api.close);
      final controller = OnboardingController(
        repository: _NoOnboardingRequests(),
      )..stage = OnboardingStage.home;
      await tester.pumpWidget(
        ThriveApp(controller: controller, services: StudentServices(api)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Guide'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'retained-search');
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      tester.view.physicalSize = const Size(800, 900);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'retained-search',
      );
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      tester.view.physicalSize = const Size(1200, 900);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'retained-search',
      );
    },
  );
  for (final disposeWhilePushed in [false, true]) {
    testWidgets(
      disposeWhilePushed
          ? 'disposing while a feature is pushed does not reload or update unmounted home'
          : 'returning from a pushed feature reloads the actual home activity',
      (tester) async {
        var completed = 0;
        var reads = 0;
        final api = ThriveApi(
          baseUrl: Uri.parse('http://localhost:5280'),
          client: MockClient((request) async {
            expect(request.method, 'GET');
            final Object response = switch (request.url.path) {
              '/api/v1/me/activity' => () {
                reads++;
                return {
                  'completedScreenings': completed,
                  'inProgressScreenings': 0,
                  'openReferrals': 0,
                };
              }(),
              '/api/v1/me/moods' || '/api/v1/instruments' => <Object>[],
              _ => throw StateError('Unexpected request: ${request.url.path}'),
            };
            return http.Response(jsonEncode(response), 200);
          }),
        );
        addTearDown(api.close);
        final controller = OnboardingController(
          repository: _NoOnboardingRequests(),
        )..stage = OnboardingStage.home;
        await tester.pumpWidget(
          ThriveApp(controller: controller, services: StudentServices(api)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();
        expect(reads, 1);
        await tester.tap(find.text('Start demonstration'));
        await tester.pumpAndSettle();
        // The synthetic server state changes while Home remains under Navigator.
        completed = 1;
        if (disposeWhilePushed) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(reads, 1);
          return;
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(
          reads,
          2,
          reason: 'Home must fetch the server summary after returning',
        );
        final value = find.descendant(
          of: find.byType(HomeActivityCard),
          matching: find.text('1'),
        );
        await tester.ensureVisible(value);
        expect(value, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

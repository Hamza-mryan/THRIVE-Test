import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thrive_student/app/thrive_app.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/features/onboarding/application/onboarding_controller.dart';
import 'package:thrive_student/features/onboarding/data/onboarding_repository.dart';

const policy = ConsentPolicy(
  version: 'test-v1',
  serviceTextAr: 'سياسة خدمة تجريبية',
  serviceTextEn: 'Development service policy',
  researchTextAr: 'سياسة بحث تجريبية',
  researchTextEn: 'Development research policy',
);

class TestRepository implements OnboardingRepository {
  ConsentChoices? saved;
  ApiFailure? saveFailure;
  Completer<void>? signInBarrier;
  @override
  Future<void> startDevelopmentSession() async => signInBarrier?.future;
  @override
  Future<ConsentPolicy> currentPolicy() async => policy;
  @override
  Future<ConsentChoices?> currentChoices() async => saved;
  @override
  Future<void> saveChoices(ConsentChoices choices) async {
    if (saveFailure != null) throw saveFailure!;
    saved = choices;
  }

  @override
  void signOut() {}
}

void main() {
  test(
    'research refusal permits service consent and survives a new session',
    () async {
      final repository = TestRepository();
      final controller = OnboardingController(repository: repository);
      await controller.startDevelopmentSession();
      expect(controller.stage, OnboardingStage.consent);
      await controller.acceptConsent(researchUse: false);
      expect(repository.saved?.serviceUse, isTrue);
      expect(repository.saved?.researchUse, isFalse);
      expect(controller.stage, OnboardingStage.home);
      controller.signOut();
      await controller.startDevelopmentSession();
      expect(controller.stage, OnboardingStage.home);
    },
  );

  test('failed save stays on consent and never claims success', () async {
    final repository = TestRepository()
      ..saveFailure = const ApiFailure(ApiFailureKind.connection);
    final controller = OnboardingController(repository: repository);
    await controller.startDevelopmentSession();
    await controller.acceptConsent(researchUse: false);
    expect(controller.stage, OnboardingStage.consent);
    expect(controller.failure, ApiFailureKind.connection);
    expect(repository.saved, isNull);
    expect(controller.busy, isFalse);
  });

  test('duplicate requests are blocked while a session is loading', () async {
    final repository = TestRepository()..signInBarrier = Completer<void>();
    final controller = OnboardingController(repository: repository);
    final first = controller.startDevelopmentSession();
    expect(controller.busy, isTrue);
    await controller.startDevelopmentSession();
    expect(controller.stage, OnboardingStage.welcome);
    repository.signInBarrier!.complete();
    await first;
    expect(controller.stage, OnboardingStage.consent);
  });

  testWidgets('urgent help opens before sign-in with no network dependency', (
    tester,
  ) async {
    await tester.pumpWidget(
      ThriveApp(controller: OnboardingController(repository: TestRepository())),
    );
    await tester.tap(find.byKey(const Key('urgent-help')));
    await tester.pumpAndSettle();
    expect(find.text('الدعم حقك، ووقته الآن.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'service consent alone enables continue and home keeps urgent help',
    (tester) async {
      final repository = TestRepository();
      final controller = OnboardingController(repository: repository);
      await controller.startDevelopmentSession();
      await tester.pumpWidget(
        ThriveApp(controller: controller, enableDevelopmentIdentity: true),
      );
      await tester.ensureVisible(find.byKey(const Key('service-consent')));
      await tester.tap(find.byKey(const Key('service-consent')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('save-consent')));
      await tester.tap(find.byKey(const Key('save-consent')));
      await tester.pumpAndSettle();
      expect(controller.stage, OnboardingStage.home);
      expect(repository.saved?.researchUse, isFalse);
      expect(find.byKey(const Key('urgent-help')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('English toggle updates locale and layout direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      ThriveApp(controller: OnboardingController(repository: TestRepository())),
    );
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your next step\ntowards feeling better.'),
      findsOneWidget,
    );
    final context = tester.element(find.byKey(const Key('continue-button')));
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('small viewport with large text renders without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ThriveApp(controller: OnboardingController(repository: TestRepository())),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

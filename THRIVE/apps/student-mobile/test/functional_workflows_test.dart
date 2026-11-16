import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrive_student/app/student_services.dart';
import 'package:thrive_student/app/thrive_app.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/features/guide/data/guide_repository.dart';
import 'package:thrive_student/features/onboarding/application/onboarding_controller.dart';
import 'package:thrive_student/features/onboarding/data/onboarding_repository.dart';
import 'package:thrive_student/features/screening/application/screening_controller.dart';
import 'package:thrive_student/features/screening/data/screening_repository.dart';

const instrument = Instrument(
  'DEMO-CHECK',
  'جولة تجربة',
  'Usability demo',
  'demo-v1',
  true,
  [
    InstrumentItem('one', 'سؤال أول', 'First question', [
      AnswerOption(0, 'لا', 'No'),
      AnswerOption(1, 'نعم', 'Yes'),
    ]),
    InstrumentItem('two', 'سؤال ثاني', 'Second question', [
      AnswerOption(0, 'لا', 'No'),
      AnswerOption(1, 'نعم', 'Yes'),
    ]),
  ],
);

Map<String, Object?> sessionJson(List<Map<String, Object?>> answers) => {
  'id': 'session-one',
  'instrumentCode': 'DEMO-CHECK',
  'instrumentVersion': 'demo-v1',
  'status': 'InProgress',
  'startedAtUtc': '2026-11-04T10:00:00Z',
  'completedAtUtc': null,
  'answers': answers,
  'result': null,
};

const resource = GuideResource(
  id: 'public-guide',
  slug: 'using-thrive',
  titleAr: 'استخدام التطبيق',
  titleEn: 'Using the app',
  summaryAr: 'شرح المنتج',
  summaryEn: 'Product guide',
  bodyAr: 'نص عام منشور',
  bodyEn: 'Public published content',
  category: 'Getting started',
  source: 'THRIVE product documentation',
  version: '1',
  isDemo: true,
  published: true,
);

class MemoryGuideCache implements GuideCache {
  List<GuideResource> values = [];
  @override
  Future<List<GuideResource>> read() async => values;
  @override
  Future<void> write(List<GuideResource> resources) async => values = resources;
}

class TestOnboarding implements OnboardingRepository {
  @override
  Future<void> startDevelopmentSession() async {}
  @override
  Future<ConsentPolicy> currentPolicy() async => const ConsentPolicy(
    version: 'demo-v1',
    serviceTextAr: 'سياسة تطوير',
    serviceTextEn: 'Development policy',
    researchTextAr: 'موافقة مستقلة',
    researchTextEn: 'Separate consent',
  );
  @override
  Future<ConsentChoices?> currentChoices() async => const ConsentChoices(
    policyVersion: 'demo-v1',
    serviceUse: true,
    researchUse: false,
  );
  @override
  Future<void> saveChoices(ConsentChoices choices) async {}
  @override
  void signOut() {}
}

void main() {
  test(
    'session resumes first unanswered item and uses server-confirmed answers',
    () async {
      final api = ThriveApi(
        baseUrl: Uri.parse('http://localhost:5180'),
        client: MockClient((request) async {
          expect(request.method, 'PUT');
          expect(
            request.url.path,
            '/api/v1/screening/sessions/session-one/answers/two',
          );
          expect(jsonDecode(request.body), {'value': 1});
          return http.Response(
            jsonEncode(
              sessionJson([
                {'itemCode': 'one', 'value': 0},
                {'itemCode': 'two', 'value': 1},
              ]),
            ),
            200,
          );
        }),
      );
      addTearDown(api.close);
      final controller = ScreeningController(
        repository: ScreeningRepository(api),
        instrument: instrument,
        session: ScreeningSession.fromJson(
          sessionJson([
            {'itemCode': 'one', 'value': 0},
          ]),
        ),
      );
      addTearDown(controller.dispose);
      expect(controller.index, 1);
      expect(controller.allAnswered, isFalse);
      await controller.choose(1);
      expect(controller.selected, 1);
      expect(controller.allAnswered, isTrue);
    },
  );

  test('failed answer does not appear saved or advance progress', () async {
    final api = ThriveApi(
      baseUrl: Uri.parse('http://localhost:5180'),
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    addTearDown(api.close);
    final controller = ScreeningController(
      repository: ScreeningRepository(api),
      instrument: instrument,
      session: ScreeningSession.fromJson(sessionJson([])),
    );
    addTearDown(controller.dispose);
    await controller.choose(1);
    expect(controller.selected, isNull);
    expect(controller.index, 0);
    expect(controller.error, isA<ApiFailure>());
    expect(controller.busy, isFalse);
  });

  test('result is returned by server without sending a client score', () async {
    final api = ThriveApi(
      baseUrl: Uri.parse('http://localhost:5180'),
      client: MockClient((request) async {
        expect(request.body, isEmpty);
        return http.Response(
          jsonEncode({
            'sessionId': 'session-one',
            'instrumentCode': 'DEMO-CHECK',
            'state': 'Demo',
            'rawScore': 1,
            'maxScore': 2,
            'ruleVersion': 'demo-v1',
            'reasonAr': 'تجريبي',
            'reasonEn': 'Technical demonstration only',
            'createdAtUtc': '2026-11-04T10:00:00Z',
            'isDemo': true,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(api.close);
    final result = await ScreeningRepository(api).submit('session-one');
    expect(result.rawScore, 1);
    expect(result.isDemo, isTrue);
  });

  test(
    'explicitly saved public guide remains readable offline without API',
    () async {
      var requests = 0;
      final api = ThriveApi(
        baseUrl: Uri.parse('http://localhost:5180'),
        client: MockClient((request) async {
          requests++;
          throw http.ClientException('offline');
        }),
      );
      addTearDown(api.close);
      final cache = MemoryGuideCache();
      final repository = GuideRepository(api, cache);
      await repository.save(resource);
      final offline = await repository.savedLibrary();
      expect(offline.resources.single.bodyEn, 'Public published content');
      expect(requests, 0);
      expect(offline.offline, isTrue);
      final fallback = await repository.library();
      expect(fallback.resources.single.id, resource.id);
      expect(fallback.offline, isTrue);
    },
  );

  test(
    'guide storage contains only public resource fields and supports removal',
    () async {
      SharedPreferences.setMockInitialValues({});
      final cache = PreferenceGuideCache();
      final api = ThriveApi(baseUrl: Uri.parse('http://localhost:5180'));
      addTearDown(api.close);
      api.setSession('never-persist-this-token');
      final repository = GuideRepository(api, cache);
      await repository.save(resource);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getKeys(), {PreferenceGuideCache.key});
      expect(
        preferences.getString(PreferenceGuideCache.key),
        isNot(contains('never-persist-this-token')),
      );
      expect((await cache.read()).single.id, resource.id);
      await repository.remove(resource.id);
      expect(await cache.read(), isEmpty);
    },
  );

  testWidgets(
    'confirmed service withdrawal gates functional tabs immediately',
    (tester) async {
      var withdrawn = false;
      final api = ThriveApi(
        baseUrl: Uri.parse('http://localhost:5180'),
        client: MockClient((request) async {
          final response = switch (request.url.path) {
            '/api/v1/me' => {
              'displayName': 'Demo student',
              'isDevelopmentIdentity': true,
            },
            '/api/v1/me/consents' => {
              'policyVersion': 'demo-v1',
              'serviceUse': true,
              'researchUse': false,
            },
            '/api/v1/me/consents/withdraw' => {
              'policyVersion': 'demo-v1',
              'serviceUse': false,
              'researchUse': false,
            },
            _ => <String, Object?>{},
          };
          if (request.url.path.endsWith('/withdraw')) {
            expect(request.method, 'POST');
            withdrawn = true;
          }
          return http.Response(jsonEncode(response), 200);
        }),
      );
      addTearDown(api.close);
      final onboarding = OnboardingController(repository: TestOnboarding());
      await onboarding.startDevelopmentSession();
      await tester.pumpWidget(
        ThriveApp(controller: onboarding, services: StudentServices(api)),
      );
      await tester.tap(find.text('حسابي'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('سحب موافقة الخدمة'));
      await tester.tap(find.text('سحب موافقة الخدمة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تأكيد سحب الموافقة'));
      await tester.pumpAndSettle();
      expect(withdrawn, isTrue);
      expect(onboarding.stage, OnboardingStage.consent);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byKey(const Key('service-consent')), findsOneWidget);
      expect(find.byKey(const Key('urgent-help')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

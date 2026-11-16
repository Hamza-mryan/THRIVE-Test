import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thrive_student/app/student_service_scope.dart';
import 'package:thrive_student/app/student_services.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/design_system/thrive_theme.dart';
import 'package:thrive_student/design_system/thrive_widgets.dart';
import 'package:thrive_student/features/account/data/account_repository.dart';
import 'package:thrive_student/features/account/presentation/account_screen.dart';
import 'package:thrive_student/features/guide/data/guide_repository.dart';
import 'package:thrive_student/features/guide/presentation/breathing_practice.dart';
import 'package:thrive_student/features/guide/presentation/guide_screen.dart';
import 'package:thrive_student/features/history/history_screen.dart';
import 'package:thrive_student/features/onboarding/application/onboarding_controller.dart';
import 'package:thrive_student/features/onboarding/data/onboarding_repository.dart';
import 'package:thrive_student/features/onboarding/presentation/consent_screen.dart';
import 'package:thrive_student/features/onboarding/presentation/welcome_screen.dart';
import 'package:thrive_student/features/policies/policy_screen.dart';
import 'package:thrive_student/features/referrals/data/referral_repository.dart';
import 'package:thrive_student/features/referrals/presentation/referral_screens.dart';
import 'package:thrive_student/features/screening/data/screening_repository.dart';
import 'package:thrive_student/features/screening/presentation/screening_screens.dart';
import 'package:thrive_student/l10n/app_localizations.dart';

class _PublicCache implements GuideCache {
  @override
  Future<List<GuideResource>> read() async => [];
  @override
  Future<void> write(List<GuideResource> resources) async {}
}

class _NoConsentWrites implements OnboardingRepository {
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

const _instrument = Instrument(
  'DEMO-CHECK',
  'تجربة الاستخدام',
  'Usability demo',
  'test-1',
  true,
  [
    InstrumentItem(
      'one',
      'سؤال اختبار عن وضوح الواجهة فقط',
      'A test question about interface clarity only',
      [
        AnswerOption(0, 'خيار تجريبي أول', 'First demonstration option'),
        AnswerOption(1, 'خيار تجريبي ثانٍ', 'Second demonstration option'),
      ],
    ),
  ],
);
const _resource = GuideResource(
  id: 'synthetic-guide',
  slug: 'test-guide',
  titleAr: 'مورد اختبار عام',
  titleEn: 'Public test resource',
  summaryAr: 'مقدمة قصيرة للتجربة فقط',
  summaryEn: 'A short introduction for testing only',
  bodyAr: 'محتوى عام اصطناعي لاختبار القراءة والتفاف النص، دون بيانات شخصية.',
  bodyEn: 'Synthetic public content for testing reading and text reflow, without personal data.',
  category: 'Product',
  source: 'THRIVE synthetic verification',
  version: 'test-1',
  isDemo: true,
  published: true,
);
const _service = SupportService(
  id: 'synthetic-service',
  level: 'Counseling',
  nameAr: 'خدمة اصطناعية للاختبار',
  nameEn: 'Synthetic test service',
  descriptionAr: 'وصف خدمة اصطناعية، وليست جهة رعاية فعلية.',
  descriptionEn:
      'A synthetic service description, not an operational care provider.',
  hoursAr: 'ساعات تجريبية',
  hoursEn: 'Test hours',
  locationAr: 'مكان تجريبي',
  locationEn: 'Test location',
  bookingMethod: 'InternalRequest',
  isDemo: true,
  verified: false,
);

void main() {
  for (final locale in ['ar', 'en']) {
    for (final configuration in [
      (size: const Size(320, 700), scale: 1.0),
      (size: const Size(375, 812), scale: 2.0),
      (size: const Size(700, 320), scale: 1.0),
      (size: const Size(800, 600), scale: 1.5),
      (size: const Size(320, 700), scale: 2.0),
    ]) {
      for (final name in [
        'welcome',
        'consent',
        'history',
        'check',
        'questionnaire',
        'result',
        'guide',
        'article',
        'breathing',
        'counseling',
        'specialist',
        'service-detail',
        'referrals',
        'account',
        'privacy',
        'terms',
      ]) {
        testWidgets(
          '$name reflows $locale ${configuration.size} ${configuration.scale}x',
          (tester) async {
            tester.view.physicalSize = configuration.size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final l = await AppLocalizations.delegate.load(Locale(locale));
            final api = ThriveApi(
              baseUrl: Uri.parse('http://localhost:5280'),
              client: MockClient((request) async {
                expect(
                  request.method,
                  'GET',
                  reason: 'Rendering must not write data',
                );
                final Object value = switch (request.url.path) {
                  '/api/v1/me/screenings' => [
                    {
                      'id': 'synthetic-session',
                      'instrumentCode': 'DEMO-CHECK',
                      'status': 'InProgress',
                      'startedAtUtc': '2026-11-07T09:00:00Z',
                      'answers': <Object>[],
                      'result': null,
                    },
                  ],
                  '/api/v1/instruments' => [
                    {
                      'code': 'DEMO-CHECK',
                      'titleAr': _instrument.titleAr,
                      'titleEn': _instrument.titleEn,
                      'version': 'test-1',
                      'isDemo': true,
                      'items': <Object>[],
                    },
                  ],
                  '/api/v1/guide/resources' => [_resource.toJson()],
                  '/api/v1/services' => <Object>[],
                  '/api/v1/me/referrals' => <Object>[],
                  '/api/v1/me' => {
                    'displayName': 'Synthetic student',
                    'isDevelopmentIdentity': true,
                  },
                  '/api/v1/me/consents' => {
                    'policyVersion': 'test-1',
                    'serviceUse': true,
                    'researchUse': false,
                  },
                  _ => throw StateError(
                    'Unexpected presentation request: ${request.url.path}',
                  ),
                };
                return http.Response(
                  jsonEncode(value),
                  200,
                  headers: {'content-type': 'application/json; charset=utf-8'},
                );
              }),
            );
            addTearDown(api.close);
            final screening = ScreeningRepository(api);
            final guide = GuideRepository(api, _PublicCache());
            final referrals = ReferralRepository(api);
            final controller = OnboardingController(
              repository: _NoConsentWrites(),
            );
            final session = ScreeningSession(
              id: 'synthetic-session',
              instrumentCode: 'DEMO-CHECK',
              status: 'InProgress',
              startedAtUtc: DateTime.utc(2026, 11, 7),
              answers: const {},
            );
            final result = ScreeningResult(
              sessionId: session.id,
              rawScore: 1,
              maxScore: 1,
              reasonAr: 'نتيجة تقنية تجريبية فقط',
              reasonEn: 'A demonstration technical total only',
              ruleVersion: 'test-1',
              createdAtUtc: DateTime.utc(2026, 11, 7),
              isDemo: true,
            );
            final (Widget subject, String expected) = switch (name) {
              'welcome' => (
                WelcomeScreen(
                  enableDevelopmentIdentity: true,
                  busy: false,
                  onContinue: () {},
                ),
                l.welcomeTitle,
              ),
              'consent' => (
                ConsentScreen(
                  policy: const ConsentPolicy(
                    version: 'test-1',
                    serviceTextAr: 'موافقة الخدمة التجريبية',
                    serviceTextEn: 'Development service consent',
                    researchTextAr: 'البحث اختياري',
                    researchTextEn: 'Research is optional',
                  ),
                  busy: false,
                  onAccept: (_) {},
                ),
                l.consentTitle,
              ),
              'history' => (
                HistoryScreen(repository: screening),
                l.resumeJourneyTitle,
              ),
              'check' => (ScreeningScreen(repository: screening), l.checkTitle),
              'questionnaire' => (
                QuestionnaireScreen(
                  repository: screening,
                  instrument: _instrument,
                  session: session,
                ),
                locale == 'ar'
                    ? _instrument.items.first.promptAr
                    : _instrument.items.first.promptEn,
              ),
              'result' => (ResultContent(result: result), l.resultTitle),
              'guide' => (GuideScreen(repository: guide), l.guideTitle),
              'article' => (
                GuideDetailScreen(repository: guide, resource: _resource),
                locale == 'ar' ? _resource.titleAr : _resource.titleEn,
              ),
              'breathing' => (
                const PageContent(children: [BreathingPractice()]),
                l.breathingPracticeTitle,
              ),
              'counseling' => (
                ServiceDirectoryScreen(
                  repository: referrals,
                  level: 'Counseling',
                ),
                l.connectTitle,
              ),
              'specialist' => (
                ServiceDirectoryScreen(
                  repository: referrals,
                  level: 'Specialist',
                ),
                l.plusTitle,
              ),
              'service-detail' => (
                ServiceDetailScreen(repository: referrals, service: _service),
                locale == 'ar' ? _service.nameAr : _service.nameEn,
              ),
              'referrals' => (
                ReferralsScreen(repository: referrals),
                l.navReferrals,
              ),
              'account' => (
                AccountScreen(
                  repository: AccountRepository(api),
                  onboarding: controller,
                ),
                l.accountTitle,
              ),
              'privacy' => (
                const PolicyScreen(document: PolicyDocument.privacy),
                l.privacyPolicy,
              ),
              _ => (
                const PolicyScreen(document: PolicyDocument.terms),
                l.termsOfUse,
              ),
            };
            await tester.pumpWidget(
              MaterialApp(
                theme: thriveTheme(),
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(configuration.scale),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: StudentServiceScope(
                  services: StudentServices(api),
                  child: Scaffold(body: subject),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              find.text(expected),
              findsWidgets,
              reason:
                  'The intended content must load, not just an error widget',
            );
            await tester.ensureVisible(find.text(expected).first);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}

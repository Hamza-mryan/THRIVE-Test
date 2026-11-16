import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thrive_student/app/student_service_scope.dart';
import 'package:thrive_student/app/student_services.dart';
import 'package:thrive_student/app/support_path_links.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/features/activity/data/activity_repository.dart';
import 'package:thrive_student/features/activity/presentation/home_activity_card.dart';
import 'package:thrive_student/features/policies/policy_screen.dart';
import 'package:thrive_student/l10n/app_localizations.dart';

Widget app(Widget child, {double textScale = 1}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets(
    'optional activity remains usable on a narrow display with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ThriveApi(
        baseUrl: Uri.parse('https://localhost'),
        client: MockClient(
          (request) async => http.Response(
            request.url.path.endsWith('/activity')
                ? jsonEncode({
                    'completedScreenings': 0,
                    'inProgressScreenings': 0,
                    'openReferrals': 0,
                  })
                : '[]',
            200,
          ),
        ),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        app(
          HomeActivityCard(repository: ActivityRepository(api)),
          textScale: 1.8,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('How do you feel today? Optional'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('privacy and terms are reachable without a signed-in session', (
    tester,
  ) async {
    await tester.pumpWidget(app(const PolicyLinks()));
    await tester.tap(find.byKey(const Key('privacy-link')));
    await tester.pumpAndSettle();
    expect(find.text('What data does the app use?'), findsOneWidget);
    expect(
      find.textContaining('Development information, not an approved'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('urgent-help')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('terms-link')));
    await tester.pumpAndSettle();
    expect(find.text('Service limits'), findsOneWidget);
    expect(find.byKey(const Key('urgent-help')), findsOneWidget);
  });

  testWidgets(
    'support links open the correct service level without a questionnaire result',
    (tester) async {
      Uri? requested;
      final api = ThriveApi(
        baseUrl: Uri.parse('https://localhost'),
        client: MockClient((request) async {
          requested = request.url;
          return http.Response('[]', 200);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        StudentServiceScope(
          services: StudentServices(api),
          child: app(const SupportPathLinks(includeGuide: true)),
        ),
      );
      await tester.tap(find.text('THRIVE Plus'));
      await tester.pumpAndSettle();
      expect(requested?.path, '/api/v1/services');
      expect(requested?.queryParameters['level'], 'Specialist');
      expect(find.text('No service is currently available'), findsOneWidget);
    },
  );

  testWidgets('daily feeling is saved through the server and can be removed', (
    tester,
  ) async {
    int? feeling;
    final mutations = <String>[];
    final api = ThriveApi(
      baseUrl: Uri.parse('https://localhost'),
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/me/activity') {
          return http.Response(
            jsonEncode({
              'completedScreenings': 2,
              'inProgressScreenings': 1,
              'openReferrals': 0,
            }),
            200,
          );
        }
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode(
              feeling == null
                  ? []
                  : [
                      {'day': '2026-11-06', 'value': feeling},
                    ],
            ),
            200,
          );
        }
        mutations.add(request.method);
        if (request.method == 'PUT') {
          expect(jsonDecode(request.body), {'value': 4});
          feeling = 4;
          return http.Response('{}', 200);
        }
        feeling = null;
        return http.Response('', 204);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(
      app(
        HomeActivityCard(
          repository: ActivityRepository(
            api,
            clock: () => DateTime(2026, 11, 6),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Completed sessions: 2'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('mood-4')));
    await tester.tap(find.byKey(const Key('mood-4')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('mood-4'))).selected,
      isTrue,
    );
    await tester.ensureVisible(find.text("Remove today's entry"));
    await tester.tap(find.text("Remove today's entry"));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('mood-4'))).selected,
      isFalse,
    );
    expect(mutations, ['PUT', 'DELETE']);
    expect(tester.takeException(), isNull);
  });
}

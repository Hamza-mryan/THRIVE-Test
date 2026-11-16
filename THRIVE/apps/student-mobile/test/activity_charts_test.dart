import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/design_system/thrive_theme.dart';
import 'package:thrive_student/features/activity/data/activity_repository.dart';
import 'package:thrive_student/features/activity/presentation/home_activity_card.dart';
import 'package:thrive_student/features/activity/presentation/mood_trend_chart.dart';
import 'package:thrive_student/l10n/app_localizations.dart';

Widget app(Widget child, {String language = 'en', double scale = 1}) =>
    MaterialApp(
      locale: Locale(language),
      theme: thriveTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );

void main() {
  test('calendar windows keep absent days empty across a month boundary', () {
    final entries = [
      MoodEntry(DateTime(2026, 10, 30), 2),
      MoodEntry(DateTime(2026, 11, 1), 4),
    ];
    final slots = moodWindow(entries, DateTime(2026, 11, 2), 7);
    expect(slots.map((entry) => entry?.value), [
      null,
      null,
      null,
      2,
      null,
      4,
      null,
    ]);
  });

  testWidgets(
    'an empty chart describes missing data without inventing a series',
    (tester) async {
      await tester.pumpWidget(
        app(
          MoodTrendChart(
            entries: const [],
            today: DateTime(2026, 11, 6),
            days: 7,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 of 7 days recorded'), findsOneWidget);
      expect(find.text('Your first point starts with you'), findsOneWidget);
      final semantics = tester.widget<Semantics>(
        find.byKey(const Key('mood-chart-semantics')),
      );
      expect(
        semantics.properties.label,
        contains('Gaps are unrecorded days, not zero values'),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'one entry and 30 day range render in Arabic at large text on narrow screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          MoodTrendChart(
            entries: [MoodEntry(DateTime(2026, 11, 6), 4)],
            today: DateTime(2026, 11, 6),
            days: 30,
          ),
          language: 'ar',
          scale: 1.8,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('سجّلت 1 من 30 أيام'), findsOneWidget);
      final semantics = tester.widget<Semantics>(
        find.byKey(const Key('mood-chart-semantics')),
      );
      expect(semantics.properties.label, contains('جيد'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'range switching reveals older server entries and only fetches the bounded month',
    (tester) async {
      Uri? moodRequest;
      final api = ThriveApi(
        baseUrl: Uri.parse('https://localhost'),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/activity')) {
            return http.Response(
              jsonEncode({
                'completedScreenings': 0,
                'inProgressScreenings': 0,
                'openReferrals': 0,
              }),
              200,
            );
          }
          moodRequest = request.url;
          return http.Response(
            '[{"day":"2026-10-20","value":3},{"day":"2026-11-06","value":4}]',
            200,
          );
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
      expect(moodRequest?.queryParameters, {
        'from': '2026-10-08',
        'to': '2026-11-06',
      });
      expect(find.text('1 of 7 days recorded'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('mood-range-30')));
      await tester.tap(find.byKey(const Key('mood-range-30')));
      await tester.pumpAndSettle();
      expect(find.text('2 of 30 days recorded'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

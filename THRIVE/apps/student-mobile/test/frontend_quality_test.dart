import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/design_system/async_content.dart';
import 'package:thrive_student/design_system/thrive_theme.dart';
import 'package:thrive_student/l10n/app_localizations.dart';

Future<void> mount(WidgetTester tester, String locale, ThriveApi api) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: thriveTheme(),
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AsyncContent<Object?>(
          load: () => api.request('GET', '/api/v1/synthetic'),
          builder: (_, _, _) => const Text('Loaded synthetic content'),
        ),
      ),
    ),
  );
}

void main() {
  for (final locale in ['ar', 'en']) {
    for (final failure in ['connection', 'unauthorized', 'unavailable', 'timeout']) {
      testWidgets('$failure feedback is safe, announced and retryable in $locale', (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var calls = 0;
        final api = ThriveApi(
          baseUrl: Uri.parse('http://localhost:5280'),
          client: MockClient((request) async {
            expect(request.method, 'GET');
            if (++calls > 1) return http.Response('{}', 200);
            if (failure == 'timeout') return Completer<http.Response>().future;
            if (failure == 'connection') throw http.ClientException('SENSITIVE_SERVER_SENTINEL');
            return http.Response('SENSITIVE_SERVER_SENTINEL', failure == 'unauthorized' ? 401 : 503);
          }),
        );
        addTearDown(api.close);
        await mount(tester, locale, api);
        if (failure == 'timeout') await tester.pump(const Duration(seconds: 13));
        await tester.pumpAndSettle();
        final l = await AppLocalizations.delegate.load(Locale(locale));
        final expected = failure == 'unauthorized'
            ? l.sessionError
            : failure == 'unavailable'
            ? l.actionError
            : l.connectionError;
        expect(find.text(expected), findsOneWidget);
        expect(find.textContaining('SENSITIVE_SERVER_SENTINEL'), findsNothing);
        expect(
          find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.liveRegion == true),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text(l.retry));
        await tester.tap(find.text(l.retry));
        await tester.pumpAndSettle();
        expect(find.text('Loaded synthetic content'), findsOneWidget);
        expect(calls, 2);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('slow loading stays explicit and completes in $locale', (tester) async {
      final response = Completer<http.Response>();
      final api = ThriveApi(
        baseUrl: Uri.parse('http://localhost:5280'),
        client: MockClient((request) => response.future),
      );
      addTearDown(api.close);
      await mount(tester, locale, api);
      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loaded synthetic content'), findsNothing);
      response.complete(http.Response('{}', 200));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Loaded synthetic content'), findsOneWidget);
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thrive_student/design_system/async_content.dart';
import 'package:thrive_student/l10n/app_localizations.dart';

void main() {
  testWidgets('reload waits for a new request and displays refreshed data', (
    tester,
  ) async {
    var requests = 0;
    final response = Completer<String>();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AsyncContent<String>(
          load: () =>
              ++requests == 1 ? Future.value('Original') : response.future,
          builder: (context, value, reload) => Column(
            children: [
              Text(value),
              TextButton(onPressed: reload, child: const Text('Refresh')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Original'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(requests, 2);

    response.complete('Updated');
    await tester.pumpAndSettle();
    expect(find.text('Updated'), findsOneWidget);
    expect(find.text('Original'), findsNothing);
  });

  testWidgets('late reload callback does not request data after disposal', (
    tester,
  ) async {
    var requests = 0;
    VoidCallback? refresh;
    await tester.pumpWidget(
      MaterialApp(
        home: AsyncContent<String>(
          load: () async {
            requests++;
            return 'Loaded';
          },
          builder: (context, value, reload) {
            refresh = reload;
            return Text(value);
          },
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    expect(refresh, isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());

    refresh!();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(requests, 1);
  });
}

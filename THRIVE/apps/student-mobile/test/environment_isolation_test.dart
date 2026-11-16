import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thrive_student/core/network/thrive_api.dart';
import 'package:thrive_student/features/onboarding/data/onboarding_repository.dart';

void main() {
  test(
    'an original backend cannot receive a development session request',
    () async {
      final methods = <String>[];
      final api = ThriveApi(
        baseUrl: Uri.parse('http://localhost:5280'),
        client: MockClient((request) async {
          methods.add(request.method);
          return http.Response(jsonEncode({'application': 'THRIVE'}), 200);
        }),
      );
      addTearDown(api.close);
      await expectLater(
        ApiOnboardingRepository(api).startDevelopmentSession(),
        throwsA(isA<ApiFailure>()),
      );
      expect(methods, ['GET']);
    },
  );

  test(
    'the owned test database is verified before synthetic sign-in',
    () async {
      final paths = <String>[];
      final api = ThriveApi(
        baseUrl: Uri.parse('http://localhost:5280'),
        client: MockClient((request) async {
          paths.add(request.url.path);
          return http.Response(
            jsonEncode(
              request.url.path == '/health/isolation'
                  ? {
                      'application': 'THRIVE Test',
                      'database': 'thrive_test',
                      'databaseUser': 'thrive_test_local',
                      'databasePort': 55432,
                    }
                  : {'accessToken': 'synthetic-test-only'},
            ),
            200,
          );
        }),
      );
      addTearDown(api.close);
      await ApiOnboardingRepository(api).startDevelopmentSession();
      expect(paths, ['/health/isolation', '/api/v1/development/session']);
    },
  );
}

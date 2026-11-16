import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thrive_student/core/network/thrive_api.dart';

void main() {
  test('session headers are centralized and cleared on logout', () async {
    final headers = <String?>[];
    final api = ThriveApi(
      baseUrl: Uri.parse('http://localhost:5180'),
      client: MockClient((request) async {
        headers.add(request.headers['Authorization']);
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );
    api.setSession('synthetic-token');
    await api.request('GET', '/api/v1/me');
    api.clearSession();
    await api.request('GET', '/api/v1/me');
    expect(headers, ['Bearer synthetic-token', null]);
    api.close();
  });

  test(
    'unauthorized responses become typed errors without leaking server bodies',
    () async {
      final api = ThriveApi(
        baseUrl: Uri.parse('http://localhost:5180'),
        client: MockClient(
          (_) async => http.Response('private server details', 401),
        ),
      );
      await expectLater(
        api.request('GET', '/api/v1/me'),
        throwsA(
          isA<ApiFailure>().having(
            (error) => error.kind,
            'kind',
            ApiFailureKind.unauthorized,
          ),
        ),
      );
      api.close();
    },
  );

  test('stale policy validation becomes a policy conflict', () async {
    final api = ThriveApi(
      baseUrl: Uri.parse('http://localhost:5180'),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'status': 400,
            'errors': {
              'policyVersion': [
                'Refresh and accept the current policy version.',
              ],
            },
          }),
          400,
        ),
      ),
    );
    addTearDown(api.close);

    await expectLater(
      api.request('PUT', '/api/v1/me/consents'),
      throwsA(
        isA<ApiFailure>().having(
          (error) => error.kind,
          'kind',
          ApiFailureKind.conflict,
        ),
      ),
    );
  });

  test('unrelated validation remains invalid', () async {
    final api = ThriveApi(
      baseUrl: Uri.parse('http://localhost:5180'),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'status': 400,
            'errors': {
              'serviceUse': ['Service consent is required.'],
            },
          }),
          400,
        ),
      ),
    );
    addTearDown(api.close);

    await expectLater(
      api.request('PUT', '/api/v1/me/consents'),
      throwsA(
        isA<ApiFailure>().having(
          (error) => error.kind,
          'kind',
          ApiFailureKind.invalid,
        ),
      ),
    );
  });

  test('unstructured bad request remains invalid', () async {
    final api = ThriveApi(
      baseUrl: Uri.parse('http://localhost:5180'),
      client: MockClient((_) async => http.Response('Bad request', 400)),
    );
    addTearDown(api.close);

    await expectLater(
      api.request('PUT', '/api/v1/me/consents'),
      throwsA(
        isA<ApiFailure>().having(
          (error) => error.kind,
          'kind',
          ApiFailureKind.invalid,
        ),
      ),
    );
  });
}

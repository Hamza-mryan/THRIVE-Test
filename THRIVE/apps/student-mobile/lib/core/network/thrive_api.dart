import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum ApiFailureKind { connection, unauthorized, conflict, unavailable, invalid }

class ApiFailure implements Exception {
  const ApiFailure(this.kind);
  final ApiFailureKind kind;
}

/// Transport owns headers, timeouts and error translation; views never do HTTP.
class ThriveApi {
  // Keep the public baseUrl argument explicit at this transport boundary.
  ThriveApi({required Uri baseUrl, http.Client? client})
    // ignore: prefer_initializing_formals
    : _baseUrl = baseUrl,
      _client = client ?? http.Client();
  final Uri _baseUrl;
  final http.Client _client;
  String? _accessToken;

  void setSession(String token) => _accessToken = token;
  void clearSession() => _accessToken = null;

  Future<Object?> request(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    try {
      final request = http.Request(method, _baseUrl.resolve(path));
      request.headers['Accept'] = 'application/json';
      final token = _accessToken;
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 12)),
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty ? null : jsonDecode(response.body);
      }
      throw ApiFailure(switch (response.statusCode) {
        401 || 403 => ApiFailureKind.unauthorized,
        409 => ApiFailureKind.conflict,
        400 when _hasPolicyVersionError(response.body) =>
          ApiFailureKind.conflict,
        400 || 422 => ApiFailureKind.invalid,
        _ => ApiFailureKind.unavailable,
      });
    } on ApiFailure {
      rethrow;
    } on TimeoutException {
      throw const ApiFailure(ApiFailureKind.connection);
    } on http.ClientException {
      throw const ApiFailure(ApiFailureKind.connection);
    } on FormatException {
      throw const ApiFailure(ApiFailureKind.unavailable);
    }
  }

  bool _hasPolicyVersionError(String body) {
    try {
      final payload = jsonDecode(body);
      if (payload is! Map<String, dynamic>) return false;
      final errors = payload['errors'];
      if (errors is! Map<String, dynamic>) return false;
      final messages = errors['policyVersion'];
      return messages is List<Object?> && messages.isNotEmpty;
    } on FormatException {
      // Keep an unstructured 400 as validation failure, without exposing its body.
      return false;
    }
  }

  void close() => _client.close();
}

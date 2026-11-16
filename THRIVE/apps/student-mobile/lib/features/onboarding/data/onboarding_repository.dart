import '../../../core/network/thrive_api.dart';

class ConsentPolicy {
  const ConsentPolicy({
    required this.version,
    required this.serviceTextAr,
    required this.serviceTextEn,
    required this.researchTextAr,
    required this.researchTextEn,
  });
  final String version;
  final String serviceTextAr;
  final String serviceTextEn;
  final String researchTextAr;
  final String researchTextEn;
  factory ConsentPolicy.fromJson(Map<String, dynamic> json) => ConsentPolicy(
    version: json['version'] as String,
    serviceTextAr: json['serviceTextAr'] as String,
    serviceTextEn: json['serviceTextEn'] as String,
    researchTextAr: json['researchTextAr'] as String,
    researchTextEn: json['researchTextEn'] as String,
  );
}

class ConsentChoices {
  const ConsentChoices({
    required this.policyVersion,
    required this.serviceUse,
    required this.researchUse,
  });
  final String policyVersion;
  final bool serviceUse;
  final bool researchUse;
  factory ConsentChoices.fromJson(Map<String, dynamic> json) => ConsentChoices(
    policyVersion: json['policyVersion'] as String,
    serviceUse: json['serviceUse'] as bool,
    researchUse: json['researchUse'] as bool,
  );
  Map<String, Object?> toJson() => {
    'policyVersion': policyVersion,
    'serviceUse': serviceUse,
    'researchUse': researchUse,
  };
}

abstract interface class OnboardingRepository {
  Future<void> startDevelopmentSession();
  Future<ConsentPolicy> currentPolicy();
  Future<ConsentChoices?> currentChoices();
  Future<void> saveChoices(ConsentChoices choices);
  void signOut();
}

class ApiOnboardingRepository implements OnboardingRepository {
  ApiOnboardingRepository(this._api);
  final ThriveApi _api;

  @override
  Future<void> startDevelopmentSession() async {
    _api.clearSession();
    final destination = await _api.request('GET', '/health/isolation');
    if (destination is! Map<String, dynamic> ||
        destination['application'] != 'THRIVE Test' ||
        destination['database'] != 'thrive_test' ||
        destination['databaseUser'] != 'thrive_test_local' ||
        destination['databasePort'] != 55432) {
      throw const ApiFailure(ApiFailureKind.unavailable);
    }
    final result = await _api.request(
      'POST',
      '/api/v1/development/session',
      body: {'persona': 'student-a'},
    ) as Map<String, dynamic>;
    _api.setSession(result['accessToken'] as String);
  }

  @override
  Future<ConsentPolicy> currentPolicy() async => ConsentPolicy.fromJson(
    await _api.request('GET', '/api/v1/consent-policies/current')
        as Map<String, dynamic>,
  );
  @override
  Future<ConsentChoices?> currentChoices() async {
    final result = await _api.request('GET', '/api/v1/me/consents');
    return result == null
        ? null
        : ConsentChoices.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<void> saveChoices(ConsentChoices choices) async {
    await _api.request('PUT', '/api/v1/me/consents', body: choices.toJson());
  }

  @override
  void signOut() => _api.clearSession();
}

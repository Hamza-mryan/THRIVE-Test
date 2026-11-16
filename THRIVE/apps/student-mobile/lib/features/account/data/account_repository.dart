import '../../../core/network/thrive_api.dart';
import '../../onboarding/data/onboarding_repository.dart';

class StudentAccount {
  const StudentAccount(
    this.displayName,
    this.isDevelopmentIdentity,
    this.choices,
  );
  final String displayName;
  final bool isDevelopmentIdentity;
  final ConsentChoices? choices;
}

class AccountRepository {
  AccountRepository(this.api);
  final ThriveApi api;
  Future<StudentAccount> current() async {
    final profile =
        await api.request('GET', '/api/v1/me') as Map<String, dynamic>;
    final choices = await api.request('GET', '/api/v1/me/consents');
    return StudentAccount(
      profile['displayName'] as String,
      profile['isDevelopmentIdentity'] as bool,
      choices == null
          ? null
          : ConsentChoices.fromJson(choices as Map<String, dynamic>),
    );
  }

  Future<void> updateResearch(ConsentChoices choices, bool researchUse) async {
    await api.request(
      'PUT',
      '/api/v1/me/consents',
      body: {
        'policyVersion': choices.policyVersion,
        'serviceUse': true,
        'researchUse': researchUse,
      },
    );
  }

  Future<void> withdraw() async {
    await api.request('POST', '/api/v1/me/consents/withdraw');
  }
}

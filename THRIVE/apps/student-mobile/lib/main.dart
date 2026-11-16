import 'package:flutter/material.dart';

import 'app/thrive_app.dart';
import 'app/student_services.dart';
import 'core/network/thrive_api.dart';
import 'features/onboarding/application/onboarding_controller.dart';
import 'features/onboarding/data/onboarding_repository.dart';

void main() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5280',
  );
  const enableDevelopmentIdentity = bool.fromEnvironment(
    'ENABLE_DEVELOPMENT_IDENTITY',
  );
  final apiUri = Uri.parse(baseUrl);
  if (apiUri.scheme != 'http' ||
      apiUri.port != 5280 ||
      !['localhost', '127.0.0.1', '10.0.2.2'].contains(apiUri.host) ||
      apiUri.userInfo.isNotEmpty) {
    throw StateError(
      'THRIVE Test requires its isolated local API on port 5280.',
    );
  }
  final api = ThriveApi(baseUrl: apiUri);
  runApp(
    ThriveApp(
      controller: OnboardingController(
        repository: ApiOnboardingRepository(api),
      ),
      enableDevelopmentIdentity: enableDevelopmentIdentity,
      services: StudentServices(api),
    ),
  );
}

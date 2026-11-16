import 'package:flutter/foundation.dart';

import '../../../core/network/thrive_api.dart';
import '../data/onboarding_repository.dart';

enum OnboardingStage { welcome, consent, home }

class OnboardingController extends ChangeNotifier {
  OnboardingController({required this._repository});
  final OnboardingRepository _repository;
  OnboardingStage stage = OnboardingStage.welcome;
  ConsentPolicy? policy;
  bool busy = false;
  ApiFailureKind? failure;

  Future<void> startDevelopmentSession() async {
    if (busy) return;
    await _run(() async {
      await _repository.startDevelopmentSession();
      policy = await _repository.currentPolicy();
      final choices = await _repository.currentChoices();
      stage =
          choices?.serviceUse == true &&
              choices?.policyVersion == policy?.version
          ? OnboardingStage.home
          : OnboardingStage.consent;
    });
  }

  Future<void> acceptConsent({required bool researchUse}) async {
    final currentPolicy = policy;
    if (busy || currentPolicy == null) return;
    await _run(() async {
      await _repository.saveChoices(
        ConsentChoices(
          policyVersion: currentPolicy.version,
          serviceUse: true,
          researchUse: researchUse,
        ),
      );
      stage = OnboardingStage.home;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    busy = true;
    failure = null;
    notifyListeners();
    try {
      await action();
    } on ApiFailure catch (error) {
      failure = error.kind;
    } catch (_) {
      failure = ApiFailureKind.unavailable;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void signOut() {
    _repository.signOut();
    stage = OnboardingStage.welcome;
    policy = null;
    failure = null;
    notifyListeners();
  }

  /// Withdrawn service consent gates every functional screen immediately.
  void returnToConsent() {
    stage = OnboardingStage.consent;
    failure = null;
    notifyListeners();
  }
}

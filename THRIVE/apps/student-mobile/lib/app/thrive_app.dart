import 'package:flutter/material.dart';

import '../core/network/thrive_api.dart';
import '../design_system/thrive_theme.dart';
import '../design_system/thrive_widgets.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/presentation/consent_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/guide/presentation/guide_screen.dart';
import '../l10n/app_localizations.dart';
import 'feature_scaffold.dart';
import 'student_services.dart';
import 'student_shell.dart';
import 'student_service_scope.dart';

class ThriveApp extends StatefulWidget {
  const ThriveApp({
    required this.controller,
    this.enableDevelopmentIdentity = false,
    this.services,
    super.key,
  });
  final OnboardingController controller;
  final bool enableDevelopmentIdentity;
  final StudentServices? services;
  @override
  State<ThriveApp> createState() => _ThriveAppState();
}

class _ThriveAppState extends State<ThriveApp> {
  Locale locale = const Locale('ar');
  @override
  Widget build(BuildContext context) => StudentServiceScope(
    services: widget.services,
    child: MaterialApp(
      title: 'THRIVE Test',
      debugShowCheckedModeBanner: false,
      theme: thriveTheme(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;
          final l = AppLocalizations.of(context);
          final failure = controller.failure;
          final error = failure == null
              ? null
              : switch (failure) {
                  ApiFailureKind.connection => l.connectionError,
                  ApiFailureKind.unauthorized => l.sessionError,
                  ApiFailureKind.conflict => l.policyChangedError,
                  ApiFailureKind.invalid => l.validationError,
                  ApiFailureKind.unavailable => l.serviceError,
                };
          return Scaffold(
            appBar: AppBar(
              title: const FittedBox(fit: BoxFit.scaleDown, child: BrandMark()),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () => setState(
                    () => locale = Locale(
                      locale.languageCode == 'ar' ? 'en' : 'ar',
                    ),
                  ),
                  child: Text(
                    locale.languageCode == 'ar' ? 'English' : 'العربية',
                  ),
                ),
                if (controller.stage != OnboardingStage.welcome)
                  IconButton(
                    tooltip: l.signOut,
                    onPressed: controller.busy ? null : controller.signOut,
                    icon: const Icon(Icons.logout_rounded, size: 21),
                  ),
                const SizedBox(width: 10),
              ],
            ),
            body: SafeArea(
              child: switch (controller.stage) {
                OnboardingStage.welcome => WelcomeScreen(
                  enableDevelopmentIdentity: widget.enableDevelopmentIdentity,
                  busy: controller.busy,
                  error: error,
                  onContinue: controller.startDevelopmentSession,
                  onOpenDownloads: widget.services == null
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FeatureScaffold(
                              title: l.guideTitle,
                              child: GuideScreen(
                                repository: widget.services!.guide,
                                offlineOnly: true,
                              ),
                            ),
                          ),
                        ),
                ),
                OnboardingStage.consent => ConsentScreen(
                  policy: controller.policy!,
                  busy: controller.busy,
                  error: error,
                  onAccept: (research) =>
                      controller.acceptConsent(researchUse: research),
                ),
                OnboardingStage.home => StudentShell(
                  onboarding: controller,
                  services: widget.services,
                ),
              },
            ),
            bottomNavigationBar: controller.stage == OnboardingStage.home
                ? null
                : const UrgentHelpBar(),
          );
        },
      ),
    ),
  );
}

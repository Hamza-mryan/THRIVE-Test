import 'package:flutter/material.dart';

import '../../../design_system/thrive_illustrations.dart';
import '../../../design_system/thrive_theme.dart';
import '../../../design_system/feature_intro.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../policies/policy_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.enableDevelopmentIdentity,
    required this.busy,
    required this.onContinue,
    this.error,
    this.onOpenDownloads,
    super.key,
  });
  final bool enableDevelopmentIdentity;
  final bool busy;
  final VoidCallback onContinue;
  final String? error;
  final VoidCallback? onOpenDownloads;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final introduction = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeatureIntro(
          title: l.welcomeTitle,
          body: l.welcomeBody,
          icon: Icons.spa_outlined,
          eyebrow: l.welcomeEyebrow,
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: const AspectRatio(
            aspectRatio: 2.3,
            child: ExcludeSemantics(child: ThriveGrowthIllustration()),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('continue-button'),
          onPressed: !enableDevelopmentIdentity || busy ? null : onContinue,
          icon: busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward_rounded),
          label: Text(
            busy
                ? l.connecting
                : enableDevelopmentIdentity
                ? l.developmentSignIn
                : l.universitySignIn,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          enableDevelopmentIdentity ? l.developmentNotice : l.identityPending,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          InlineNotice(text: error!, isError: true),
        ],
      ],
    );
    final benefits = SurfaceCard(
      child: Column(
        children: [
          _Benefit(
            icon: Icons.fact_check_outlined,
            title: l.benefitCheckTitle,
            body: l.benefitCheckBody,
            color: ThriveColors.checkInk,
            surface: ThriveColors.sky,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          _Benefit(
            icon: Icons.diversity_1_outlined,
            title: l.benefitConnectTitle,
            body: l.benefitConnectBody,
            color: ThriveColors.plusInk,
            surface: ThriveColors.lavender,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          _Benefit(
            icon: Icons.verified_user_outlined,
            title: l.benefitChoiceTitle,
            body: l.benefitChoiceBody,
            color: ThriveColors.guideInk,
            surface: ThriveColors.mint,
          ),
        ],
      ),
    );
    return PageContent(
      maxWidth: 1040,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 800 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.4;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: introduction),
                  const SizedBox(width: 40),
                  Expanded(flex: 5, child: benefits),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [introduction, const SizedBox(height: 28), benefits],
            );
          },
        ),
        const SizedBox(height: 24),
        if (onOpenDownloads != null)
          TextButton.icon(
            onPressed: onOpenDownloads,
            icon: const Icon(Icons.offline_pin_outlined),
            label: Text(l.openSavedGuides),
          ),
        const SizedBox(height: 12),
        Text(
          l.screeningBoundary,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const PolicyLinks(),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.surface,
  });
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(body, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

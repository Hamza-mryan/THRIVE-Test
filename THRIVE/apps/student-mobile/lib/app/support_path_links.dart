import 'package:flutter/material.dart';

import '../features/guide/presentation/guide_screen.dart';
import '../features/referrals/presentation/referral_screens.dart';
import '../l10n/app_localizations.dart';
import 'feature_scaffold.dart';
import 'student_service_scope.dart';

// Reuses the same destinations from results and resources. No clinical routing decisions here.
class SupportPathLinks extends StatelessWidget {
  const SupportPathLinks({this.includeGuide = false, super.key});
  final bool includeGuide;

  @override
  Widget build(BuildContext context) {
    final services = StudentServiceScope.maybeOf(context);
    if (services == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.humanSupportTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(l.humanSupportBody),
        const SizedBox(height: 12),
        if (includeGuide)
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FeatureScaffold(
                  title: l.guideTitle,
                  child: GuideScreen(repository: services.guide),
                ),
              ),
            ),
            icon: const Icon(Icons.auto_stories_outlined),
            label: Text(l.guideTitle),
          ),
        for (final level in ['Counseling', 'Specialist'])
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FeatureScaffold(
                  title: level == 'Counseling' ? l.connectTitle : l.plusTitle,
                  child: ServiceDirectoryScreen(
                    repository: services.referrals,
                    level: level,
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.people_outline),
            label: Text(level == 'Counseling' ? l.connectTitle : l.plusTitle),
          ),
      ],
    );
  }
}

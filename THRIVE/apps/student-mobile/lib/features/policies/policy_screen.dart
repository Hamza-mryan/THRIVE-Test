import 'package:flutter/material.dart';

import '../../design_system/feature_intro.dart';

import '../../app/feature_scaffold.dart';
import '../../design_system/thrive_widgets.dart';
import '../../l10n/app_localizations.dart';

enum PolicyDocument { privacy, terms }

class PolicyLinks extends StatelessWidget {
  const PolicyLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        for (final document in PolicyDocument.values)
          TextButton(
            key: Key('${document.name}-link'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PolicyScreen(document: document),
              ),
            ),
            child: Text(
              document == PolicyDocument.privacy
                  ? l.privacyPolicy
                  : l.termsOfUse,
            ),
          ),
      ],
    );
  }
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({required this.document, super.key});
  final PolicyDocument document;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sections = document == PolicyDocument.privacy
        ? [
            (l.dataCollectedTitle, l.dataCollectedBody),
            (l.dataPurposeTitle, l.dataPurposeBody),
            (l.dataSharingTitle, l.dataSharingBody),
            (l.dataChoicesTitle, l.dataChoicesBody),
          ]
        : [
            (l.serviceScopeTitle, l.serviceScopeBody),
            (l.demoUseTitle, l.demoUseBody),
            (l.contactPolicyTitle, l.contactPolicyBody),
          ];
    return FeatureScaffold(
      title: document == PolicyDocument.privacy
          ? l.privacyPolicy
          : l.termsOfUse,
      child: PageContent(
        children: [
          FeatureIntro(
            title: document == PolicyDocument.privacy
                ? l.privacyPolicy
                : l.termsOfUse,
            body: l.policyDraftNotice,
            icon: document == PolicyDocument.privacy
                ? Icons.shield_outlined
                : Icons.article_outlined,
          ),
          const SizedBox(height: 20),
          for (final section in sections) ...[
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    section.$1,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(section.$2),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

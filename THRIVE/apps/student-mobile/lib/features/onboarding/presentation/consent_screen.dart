import 'package:flutter/material.dart';

import '../../../design_system/feature_intro.dart';

import '../../../design_system/thrive_theme.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/onboarding_repository.dart';
import '../../policies/policy_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({
    required this.policy,
    required this.busy,
    required this.onAccept,
    this.error,
    super.key,
  });
  final ConsentPolicy policy;
  final bool busy;
  final ValueChanged<bool> onAccept;
  final String? error;
  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool serviceUse = false;
  bool researchUse = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return PageContent(
      children: [
        StatusPill(label: l.consentEyebrow, icon: Icons.verified_user_outlined),
        const SizedBox(height: 20),
        FeatureIntro(
          title: l.consentTitle,
          body: l.consentIntro,
          icon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 24),
        _ConsentCard(
          title: l.serviceConsentTitle,
          body: ar ? widget.policy.serviceTextAr : widget.policy.serviceTextEn,
          label: l.serviceConsentLabel,
          selected: serviceUse,
          onChanged: widget.busy
              ? null
              : (value) => setState(() => serviceUse = value),
          controlKey: const Key('service-consent'),
        ),
        const SizedBox(height: 16),
        _ConsentCard(
          title: l.researchConsentTitle,
          body: ar
              ? widget.policy.researchTextAr
              : widget.policy.researchTextEn,
          label: l.researchConsentLabel,
          selected: researchUse,
          onChanged: widget.busy
              ? null
              : (value) => setState(() => researchUse = value),
          controlKey: const Key('research-consent'),
        ),
        const SizedBox(height: 18),
        InlineNotice(text: l.researchOptional),
        const PolicyLinks(),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('save-consent'),
          onPressed: !serviceUse || widget.busy
              ? null
              : () => widget.onAccept(researchUse),
          child: Text(widget.busy ? l.saving : l.saveAndContinue),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 14),
          InlineNotice(text: widget.error!, isError: true),
        ],
        const SizedBox(height: 16),
        Text(
          l.policyVersion(widget.policy.version),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: ThriveColors.muted),
        ),
      ],
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.title,
    required this.body,
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.controlKey,
  });
  final String title;
  final String body;
  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final Key controlKey;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(body),
        const SizedBox(height: 14),
        CheckboxListTile(
          key: controlKey,
          value: selected,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              height: 1.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: onChanged == null
              ? null
              : (value) => onChanged!(value ?? false),
        ),
      ],
    ),
  );
}

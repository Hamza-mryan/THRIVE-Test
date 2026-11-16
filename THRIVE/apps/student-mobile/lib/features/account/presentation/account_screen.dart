import 'package:flutter/material.dart';

import '../../../design_system/feature_intro.dart';

import '../../../design_system/async_content.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../data/account_repository.dart';
import '../../policies/policy_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    required this.repository,
    required this.onboarding,
    super.key,
  });
  final AccountRepository repository;
  final OnboardingController onboarding;
  @override
  Widget build(BuildContext context) => AsyncContent<StudentAccount>(
    load: repository.current,
    builder: (context, account, reload) => _AccountContent(
      repository: repository,
      onboarding: onboarding,
      account: account,
      reload: reload,
    ),
  );
}

class _AccountContent extends StatefulWidget {
  const _AccountContent({
    required this.repository,
    required this.onboarding,
    required this.account,
    required this.reload,
  });
  final AccountRepository repository;
  final OnboardingController onboarding;
  final StudentAccount account;
  final VoidCallback reload;
  @override
  State<_AccountContent> createState() => _AccountContentState();
}

class _AccountContentState extends State<_AccountContent> {
  bool busy = false;
  Object? error;
  Future<void> updateResearch(bool value) async {
    final choices = widget.account.choices;
    if (choices == null || busy) return;
    await run(() async {
      await widget.repository.updateResearch(choices, value);
      widget.reload();
    });
  }

  Future<void> withdraw() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.withdrawConsent),
        content: Text(l.withdrawConsentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.confirmWithdraw),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await run(() async {
      await widget.repository.withdraw();
      widget.onboarding.returnToConsent();
    });
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageContent(
      children: [
        FeatureIntro(
          title: l.accountTitle,
          body: l.accountIntro,
          icon: Icons.manage_accounts_outlined,
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_outline, size: 40),
              const SizedBox(height: 12),
              Text(
                widget.account.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (widget.account.isDevelopmentIdentity) ...[
                const SizedBox(height: 10),
                Text(l.developmentNotice),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.consentSettings,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(l.researchOptional),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.researchConsentTitle),
                value: widget.account.choices?.researchUse ?? false,
                onChanged: busy ? null : updateResearch,
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: busy ? null : withdraw,
                child: Text(l.withdrawConsent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InlineNotice(text: l.accountPrivacy),
        const PolicyLinks(),
        if (error != null) ...[
          const SizedBox(height: 14),
          InlineNotice(text: requestError(context, error), isError: true),
        ],
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: busy ? null : widget.onboarding.signOut,
          icon: const Icon(Icons.logout),
          label: Text(l.signOut),
        ),
      ],
    );
  }
}

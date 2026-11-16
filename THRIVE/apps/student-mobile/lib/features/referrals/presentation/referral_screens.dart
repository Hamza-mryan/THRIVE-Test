import 'package:flutter/material.dart';

import '../../../design_system/feature_intro.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../app/feature_scaffold.dart';
import '../../../core/network/thrive_api.dart';
import '../../../design_system/async_content.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../design_system/thrive_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/referral_repository.dart';

String referralStatus(AppLocalizations l, String status) => switch (status) {
  'Requested' => l.referralRequested,
  'Received' => l.referralReceived,
  'Scheduled' => l.referralScheduled,
  'Completed' => l.referralCompleted,
  'Declined' => l.referralDeclined,
  'Cancelled' => l.referralCancelled,
  _ => l.referralRequested,
};

String serviceSpecialty(AppLocalizations l, String? specialty) =>
    switch (specialty) {
      'Psychology' => l.specialtyPsychology,
      'Psychiatry' => l.specialtyPsychiatry,
      _ => l.specialtyGeneral,
    };

class ServiceDirectoryScreen extends StatefulWidget {
  const ServiceDirectoryScreen({
    required this.repository,
    required this.level,
    super.key,
  });
  final ReferralRepository repository;
  final String level;
  @override
  State<ServiceDirectoryScreen> createState() => _ServiceDirectoryScreenState();
}

class _ServiceDirectoryScreenState extends State<ServiceDirectoryScreen> {
  String? specialty;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return AsyncContent<List<SupportService>>(
      load: () => widget.repository.services(widget.level),
      builder: (context, services, reload) => PageContent(
        children: [
          FeatureIntro(
            title: widget.level == 'Specialist' ? l.plusTitle : l.connectTitle,
            body: widget.level == 'Specialist'
                ? l.directorySpecialistIntro
                : l.directoryIntro,
            icon: widget.level == 'Specialist'
                ? Icons.psychology_alt_outlined
                : Icons.volunteer_activism_outlined,
            accent: widget.level == 'Specialist'
                ? ThriveColors.plusInk
                : ThriveColors.guideInk,
            background: widget.level == 'Specialist'
                ? ThriveColors.lavender
                : ThriveColors.mint,
          ),
          const SizedBox(height: 24),
          if (widget.level == 'Specialist') ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in [null, 'Psychology', 'Psychiatry'])
                  ChoiceChip(
                    key: ValueKey('specialty-${value ?? 'all'}'),
                    label: Text(
                      value == null
                          ? l.directoryAllSpecialties
                          : serviceSpecialty(l, value),
                    ),
                    selected: specialty == value,
                    onSelected: (_) => setState(() => specialty = value),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          if (services.isEmpty)
            EmptyContent(title: l.noServices, body: l.noServicesBody),
          if (services.isNotEmpty &&
              !services.any(
                (s) => specialty == null || s.specialty == specialty,
              ))
            EmptyContent(title: l.noServices, body: l.noServicesBody),
          for (final service in services.where(
            (s) => specialty == null || s.specialty == specialty,
          )) ...[
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatusPill(
                    label: service.isDemo
                        ? l.demoLabel
                        : service.verified
                        ? l.verifiedService
                        : l.serviceUnverified,
                    icon: service.isDemo
                        ? Icons.science_outlined
                        : service.verified
                        ? Icons.verified_outlined
                        : Icons.info_outline,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    ar ? service.nameAr : service.nameEn,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(ar ? service.descriptionAr : service.descriptionEn),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _ServiceTag(
                        icon: Icons.psychology_outlined,
                        text: serviceSpecialty(l, service.specialty),
                      ),
                      _ServiceTag(
                        icon: Icons.location_on_outlined,
                        text: ar ? service.locationAr : service.locationEn,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ServiceDetailScreen(
                          repository: widget.repository,
                          service: service,
                        ),
                      ),
                    ),
                    child: Text(l.serviceDetails),
                  ),
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

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    required this.repository,
    required this.service,
    super.key,
  });
  final ReferralRepository repository;
  final SupportService service;
  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool share = false;
  bool busy = false;
  Object? error;
  Referral? created;

  Future<void> openContact(Uri uri) async {
    final l = AppLocalizations.of(context);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.serviceContactUnavailable)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.serviceContactUnavailable)));
      }
    }
  }

  Future<void> submit() async {
    if (!share || busy || created != null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final referral = await widget.repository.request(widget.service.id);
      if (mounted) setState(() => created = referral);
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final service = widget.service;
    final failure = error;
    return FeatureScaffold(
      title: l.serviceDetails,
      child: PageContent(
        children: [
          FeatureIntro(
            title: ar ? service.nameAr : service.nameEn,
            body: serviceSpecialty(l, service.specialty),
            icon: service.level == 'Specialist'
                ? Icons.psychology_alt_outlined
                : Icons.volunteer_activism_outlined,
          ),
          const SizedBox(height: 16),
          StatusPill(
            label: service.isDemo
                ? l.demoLabel
                : service.verified
                ? l.verifiedService
                : l.serviceUnverified,
            icon: service.verified && !service.isDemo
                ? Icons.verified_outlined
                : Icons.info_outline,
          ),
          const SizedBox(height: 16),
          if (service.isDemo) ...[
            InlineNotice(text: l.demoServiceNotice),
            const SizedBox(height: 16),
          ],
          Text(ar ? service.descriptionAr : service.descriptionEn),
          const SizedBox(height: 20),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.serviceHours,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(ar ? service.hoursAr : service.hoursEn),
                const SizedBox(height: 16),
                Text(
                  l.serviceLocation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(ar ? service.locationAr : service.locationEn),
                const SizedBox(height: 16),
                Text(
                  l.bookingMethod,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  service.bookingMethod == 'InternalRequest' || service.isDemo
                      ? l.serviceBookingInternal
                      : service.bookingMethod,
                ),
                const SizedBox(height: 16),
                Text(
                  l.serviceSource,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(service.source ?? l.serviceSourceMissing),
                if (service.phone != null ||
                    service.email != null ||
                    service.contactUrl != null) ...[
                  const Divider(height: 32),
                  if (service.phone != null) ...[
                    SelectableText(
                      service.phone!,
                      textDirection: TextDirection.ltr,
                    ),
                    OutlinedButton.icon(
                      key: const Key('service-phone'),
                      onPressed: service.isDemo || !service.verified
                          ? null
                          : () => openContact(
                              Uri(
                                scheme: 'tel',
                                path: service.phone!.replaceAll(
                                  RegExp(r'[^+0-9]'),
                                  '',
                                ),
                              ),
                            ),
                      icon: const Icon(Icons.call_outlined),
                      label: Text(l.servicePhone),
                    ),
                  ],
                  if (service.email != null) ...[
                    SelectableText(
                      service.email!,
                      textDirection: TextDirection.ltr,
                    ),
                    OutlinedButton.icon(
                      key: const Key('service-email'),
                      onPressed: service.isDemo || !service.verified
                          ? null
                          : () => openContact(
                              Uri(scheme: 'mailto', path: service.email!),
                            ),
                      icon: const Icon(Icons.mail_outline),
                      label: Text(l.serviceEmail),
                    ),
                  ],
                ],
                if (service.contactUrl != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(service.contactUrl!),
                  OutlinedButton.icon(
                    key: const Key('service-website'),
                    onPressed:
                        service.isDemo ||
                            !service.verified ||
                            Uri.tryParse(service.contactUrl!)?.scheme != 'https'
                        ? null
                        : () => openContact(Uri.parse(service.contactUrl!)),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l.serviceWebsite),
                  ),
                ],
                if (service.phone != null ||
                    service.email != null ||
                    service.contactUrl != null)
                  Text(
                    l.serviceContactBoundary,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.serviceRequestTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (created != null)
            InlineNotice(text: l.referralSent)
          else ...[
            CheckboxListTile(
              key: const Key('share-referral-consent'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(l.shareReferralConsent),
              value: share,
              onChanged: busy
                  ? null
                  : (value) => setState(() => share = value ?? false),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: !share || busy ? null : submit,
              icon: const Icon(Icons.send_outlined),
              label: Text(busy ? l.loading : l.requestReferral),
            ),
          ],
          if (failure != null) ...[
            const SizedBox(height: 12),
            InlineNotice(
              text:
                  failure is ApiFailure &&
                      failure.kind == ApiFailureKind.conflict
                  ? l.referralAlreadyOpen
                  : requestError(context, failure),
              isError: true,
            ),
          ],
          const SizedBox(height: 16),
          Text(l.referralRequestBoundary),
        ],
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  const _ServiceTag({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: ThriveColors.teal),
      const SizedBox(width: 6),
      Flexible(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
    ],
  );
}

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({required this.repository, super.key});
  final ReferralRepository repository;
  Future<void> cancel(
    BuildContext context,
    Referral referral,
    VoidCallback reload,
  ) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.cancelReferral),
        content: Text(l.cancelReferralConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.keepReferral),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.cancelReferral),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await repository.cancel(referral.id);
      reload();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(requestError(context, error))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return AsyncContent<List<Referral>>(
      load: repository.referrals,
      builder: (context, referrals, reload) => PageContent(
        children: [
          FeatureIntro(
            title: l.navReferrals,
            body: l.referralsIntro,
            icon: Icons.route_outlined,
            trailing: IconButton(
              onPressed: reload,
              tooltip: l.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 24),
          if (referrals.isEmpty)
            EmptyContent(title: l.noReferrals, body: l.noReferralsBody),
          for (final referral in referrals) ...[
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (referral.isDemo)
                    Text(
                      l.demoLabel,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  Text(
                    ar ? referral.serviceNameAr : referral.serviceNameEn,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  StatusPill(
                    label: referralStatus(l, referral.status),
                    icon: Icons.route_outlined,
                  ),
                  const SizedBox(height: 10),
                  Text(displayDate(context, referral.createdAtUtc)),
                  if (referral.canCancel) ...[
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: () => cancel(context, referral, reload),
                      child: Text(l.cancelReferral),
                    ),
                  ],
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

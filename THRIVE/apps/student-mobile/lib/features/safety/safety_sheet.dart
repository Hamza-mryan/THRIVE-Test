import 'package:flutter/material.dart';

import '../../design_system/feature_intro.dart';

import '../../design_system/thrive_theme.dart';
import '../../design_system/thrive_widgets.dart';
import '../../l10n/app_localizations.dart';

Future<void> showSafetySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        final l = AppLocalizations.of(context);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .9,
          ),
          child: PageContent(
            children: [
              FeatureIntro(
                title: l.safetyTitle,
                body: l.safetyIntro,
                icon: Icons.favorite_outline_rounded,
                accent: ThriveColors.urgent,
                background: ThriveColors.errorSurface,
              ),
              const SizedBox(height: 24),
              for (final contact in [
                (l.emergencyContactTitle, l.emergencyContactPending),
                (l.universityHelpTitle, l.universityHelpPending),
              ]) ...[
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        contact.$1,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.verificationRequired,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(contact.$2),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.safetyTrustedTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(l.safetyTrustedBody),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l.safePlaceTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(l.safePlaceBody),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InlineNotice(text: l.safetyContactsUnavailable),
              const SizedBox(height: 16),
              Text(l.safetyBoundary),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.close),
              ),
            ],
          ),
        );
      },
    );

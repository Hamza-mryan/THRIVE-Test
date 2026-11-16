import 'package:flutter/material.dart';

import '../../design_system/thrive_illustrations.dart';
import '../../design_system/thrive_theme.dart';
import '../../design_system/thrive_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../activity/data/activity_repository.dart';
import '../activity/presentation/home_activity_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.onPath,
    this.onHistory,
    this.activity,
    this.activityRevision = 0,
    super.key,
  });
  final ValueChanged<String>? onPath;
  final VoidCallback? onHistory;
  final ActivityRepository? activity;
  final int activityRevision;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final paths = [
      _SupportPath(
        l.checkTitle,
        l.checkBody,
        Icons.fact_check_outlined,
        ThriveColors.sky,
        ThriveColors.checkInk,
        'check',
      ),
      _SupportPath(
        l.guideTitle,
        l.guideBody,
        Icons.auto_stories_outlined,
        ThriveColors.mint,
        ThriveColors.guideInk,
        'guide',
      ),
      _SupportPath(
        l.connectTitle,
        l.connectBody,
        Icons.people_alt_outlined,
        ThriveColors.apricot,
        ThriveColors.connectInk,
        'connect',
      ),
      _SupportPath(
        l.plusTitle,
        l.plusBody,
        Icons.psychology_outlined,
        ThriveColors.lavender,
        ThriveColors.plusInk,
        'plus',
      ),
    ];
    return PageContent(
      maxWidth: ThriveLayout.workspaceWidth,
      children: [
        StatusPill(label: l.homeEyebrow, icon: Icons.spa_outlined),
        const SizedBox(height: ThriveSpacing.sm),
        Semantics(
          header: true,
          child: Text(
            l.homeTitle,
            style: Theme.of(context).textTheme.headlineLarge
                ?.copyWith(fontSize: 28, height: 1.5),
          ),
        ),
        const SizedBox(height: ThriveSpacing.xxs),
        Text(
          l.homeBody,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
        const SizedBox(height: ThriveSpacing.lg),
        _HomeHero(onStart: onPath == null ? null : () => onPath!('check')),
        const SizedBox(height: ThriveSpacing.xl),
        Semantics(
          header: true,
          child: Text(
            l.modulesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: ThriveSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
            final columns = constraints.maxWidth >= 600 && !largeText ? 2 : 1;
            final width = columns == 2
                ? (constraints.maxWidth - ThriveSpacing.sm) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: ThriveSpacing.sm,
              runSpacing: ThriveSpacing.sm,
              children: [
                for (final path in paths)
                  SizedBox(
                    width: width,
                    child: _ModuleCard(
                      module: path,
                      onTap: onPath == null ? null : () => onPath!(path.path),
                    ),
                  ),
              ],
            );
          },
        ),
        if (activity != null) ...[
          const SizedBox(height: ThriveSpacing.xl),
          HomeActivityCard(
            key: ValueKey(activityRevision),
            repository: activity!,
          ),
        ],
        const SizedBox(height: ThriveSpacing.lg),
        _HistoryShortcut(onTap: onHistory),
        const SizedBox(height: ThriveSpacing.lg),
        InlineNotice(text: l.developmentHomeNotice),
      ],
    );
  }
}

class _SupportPath {
  const _SupportPath(
    this.title,
    this.body,
    this.icon,
    this.background,
    this.foreground,
    this.path,
  );
  final String title;
  final String body;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String path;
}

IconData _forwardIcon(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
    ? Icons.arrow_back_rounded
    : Icons.arrow_forward_rounded;

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onStart});
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final showIllustration =
            constraints.maxWidth >= 640 &&
            MediaQuery.textScalerOf(context).scale(14) <= 21;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: ThriveColors.navy,
            borderRadius: BorderRadius.circular(ThriveLayout.heroRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ThriveSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              l.homeBannerTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                height: 1.6,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: ThriveSpacing.md),
                          if (!showIllustration)
                            const ExcludeSemantics(
                              child: Icon(
                                Icons.spa_outlined,
                                color: ThriveColors.mint,
                                size: 28,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: ThriveSpacing.sm),
                      Text(
                        l.demoLabel,
                        style: const TextStyle(
                          color: ThriveColors.mint,
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: ThriveSpacing.md),
                      FilledButton.icon(
                        key: const Key('home-start-check'),
                        onPressed: onStart,
                        style: FilledButton.styleFrom(
                          backgroundColor: ThriveColors.mint,
                          foregroundColor: ThriveColors.navy,
                          disabledBackgroundColor: ThriveColors.muted,
                          minimumSize: const Size(48, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: Text(l.startCheck),
                        icon: Icon(_forwardIcon(context), size: 20),
                      ),
                    ],
                  ),
                ),
                if (showIllustration) ...[
                  const SizedBox(width: ThriveSpacing.xl),
                  ExcludeSemantics(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ThriveLayout.actionRadius,
                      ),
                      child: const SizedBox(
                        width: 220,
                        height: 170,
                        child: ThriveGrowthIllustration(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, this.onTap});
  final _SupportPath module;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    key: Key('home-path-${module.path}'),
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: module.foreground,
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsets.all(ThriveSpacing.md),
      minimumSize: const Size(48, 108),
      side: const BorderSide(color: ThriveColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThriveLayout.actionRadius),
      ),
    ),
    child: Semantics(
      label: AppLocalizations.of(context).openNamedPath(module.title),
      hint: module.body,
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThriveSpacing.sm),
            decoration: BoxDecoration(
              color: module.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(module.icon, color: module.foreground, size: 24),
          ),
          const SizedBox(width: ThriveSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: module.foreground,
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: ThriveSpacing.xxs),
                Text(
                  module.body,
                  style: const TextStyle(
                    color: ThriveColors.muted,
                    fontSize: 14,
                    height: 1.75,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: ThriveSpacing.xs),
          Icon(_forwardIcon(context), size: 20, color: module.foreground),
        ],
      ),
    ),
  );
}

class _HistoryShortcut extends StatelessWidget {
  const _HistoryShortcut({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OutlinedButton(
      key: const Key('home-history'),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: ThriveColors.navy,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.all(ThriveSpacing.md),
        minimumSize: const Size(48, 88),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThriveLayout.actionRadius),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history_rounded,
            color: ThriveColors.plusInk,
            size: 24,
          ),
          const SizedBox(width: ThriveSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.historyTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ThriveSpacing.xxs),
                Text(
                  l.historyReadyBody,
                  style: const TextStyle(
                    color: ThriveColors.muted,
                    fontSize: 14,
                    height: 1.75,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: ThriveSpacing.xs),
          Icon(_forwardIcon(context), color: ThriveColors.teal, size: 20),
        ],
      ),
    );
  }
}

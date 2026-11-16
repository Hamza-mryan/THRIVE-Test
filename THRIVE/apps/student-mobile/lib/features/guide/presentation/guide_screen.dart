import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/feature_scaffold.dart';
import '../../../app/support_path_links.dart';
import '../../../design_system/async_content.dart';
import '../../../design_system/feature_intro.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/guide_repository.dart';
import 'guide_topic.dart';
import 'breathing_practice.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({
    required this.repository,
    this.offlineOnly = false,
    super.key,
  });
  final GuideRepository repository;
  final bool offlineOnly;
  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  String query = '';
  String? category;
  bool savedOnly = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return AsyncContent<GuideLibrary>(
      load: widget.offlineOnly
          ? widget.repository.savedLibrary
          : widget.repository.library,
      builder: (context, library, reload) {
        final categories = library.resources
            .map((x) => x.category)
            .toSet()
            .toList();
        final matches = library.resources
            .where(
              (resource) =>
                  (!savedOnly || library.savedIds.contains(resource.id)) &&
                  (category == null || resource.category == category) &&
                  '${resource.titleAr} ${resource.titleEn} ${resource.summaryAr} ${resource.summaryEn}'
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList();
        return PageContent(
          children: [
            FeatureIntro(
              title: l.guideTitle,
              body: l.guideBody,
              icon: Icons.auto_stories_outlined,
              eyebrow: l.guideEyebrow,
              trailing: IconButton(
                onPressed: reload,
                tooltip: l.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ),
            const SizedBox(height: 24),
            if (library.offline) ...[
              InlineNotice(text: l.offlineGuides),
              const SizedBox(height: 16),
            ],
            TextField(
              decoration: InputDecoration(
                labelText: l.searchGuides,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.allCategories),
                  selected: category == null,
                  onSelected: (_) => setState(() => category = null),
                ),
                for (final item in categories)
                  ChoiceChip(
                    label: Text(guideTopic(context, item).label),
                    avatar: Icon(guideTopic(context, item).icon, size: 17),
                    selected: category == item,
                    onSelected: (_) => setState(() => category = item),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.savedGuidesOnly),
              value: savedOnly,
              onChanged: (value) => setState(() => savedOnly = value),
            ),
            if (matches.isEmpty)
              EmptyContent(title: l.noResources, body: l.noResourcesBody),
            for (final resource in matches) ...[
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ResourceArtwork(
                      category: resource.category,
                      compact: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      guideTopic(context, resource.category).label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: guideTopic(context, resource.category).color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (resource.isDemo)
                      Text(
                        l.demoLabel,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    Text(
                      ar ? resource.titleAr : resource.titleEn,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(ar ? resource.summaryAr : resource.summaryEn),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      icon: Icon(
                        library.savedIds.contains(resource.id)
                            ? Icons.offline_pin_outlined
                            : Icons.auto_stories_outlined,
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GuideDetailScreen(
                              repository: widget.repository,
                              resource: resource,
                              showSupportLinks: !widget.offlineOnly,
                            ),
                          ),
                        );
                        reload();
                      },
                      label: Text(l.readResource),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}

class GuideDetailScreen extends StatefulWidget {
  const GuideDetailScreen({
    required this.repository,
    required this.resource,
    this.showSupportLinks = true,
    super.key,
  });
  final GuideRepository repository;
  final GuideResource resource;
  final bool showSupportLinks;
  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  bool? saved;
  bool busy = false;
  Object? error;
  @override
  void initState() {
    super.initState();
    widget.repository
        .isSaved(widget.resource.id)
        .then((value) {
          if (mounted) setState(() => saved = value);
        })
        .catchError((Object failure) {
          if (mounted) setState(() => error = failure);
        });
  }

  Future<void> toggle() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (saved == true) {
        await widget.repository.remove(widget.resource.id);
      } else {
        await widget.repository.save(widget.resource);
      }
      if (mounted) setState(() => saved = !(saved ?? false));
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
    final resource = widget.resource;
    return FeatureScaffold(
      title: l.guideTitle,
      child: PageContent(
        children: [
          FeatureIntro(
            title: ar ? resource.titleAr : resource.titleEn,
            body: ar ? resource.summaryAr : resource.summaryEn,
            icon: guideTopic(context, resource.category).icon,
          ),
          const SizedBox(height: 16),
          _ResourceArtwork(category: resource.category),
          const SizedBox(height: 20),
          if (resource.isDemo) ...[
            InlineNotice(
              text: resource.version.startsWith('education-draft')
                  ? l.draftEducationNotice
                  : l.demoResourceNotice,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            ar ? resource.bodyAr : resource.bodyEn,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (resource.slug == 'draft-breathing') ...[
            const BreathingPractice(),
            const SizedBox(height: 24),
          ],
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.resourceSource(resource.source)),
                if (_sourceUri(resource.source) case final source?)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        if (!await launchUrl(
                          source,
                          mode: LaunchMode.externalApplication,
                        )) {
                          if (mounted) {
                            setState(
                              () => error = StateError('source_unavailable'),
                            );
                          }
                        }
                      } catch (failure) {
                        if (mounted) setState(() => error = failure);
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(l.openOriginalSource),
                  ),
                const SizedBox(height: 8),
                Text(
                  resource.reviewedAtUtc == null
                      ? l.reviewPending
                      : l.reviewDate(
                          displayDate(context, resource.reviewedAtUtc!),
                        ),
                ),
                Text(l.contentVersion(resource.version)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: busy || saved == null ? null : toggle,
            icon: Icon(
              saved == true ? Icons.delete_outline : Icons.download_outlined,
            ),
            label: Text(saved == true ? l.removeDownload : l.downloadGuide),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            InlineNotice(text: requestError(context, error), isError: true),
          ],
          const SizedBox(height: 24),
          if (widget.showSupportLinks) const SupportPathLinks(),
        ],
      ),
    );
  }
}

Uri? _sourceUri(String source) {
  final uri = Uri.tryParse(source);
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
      ? uri
      : null;
}

class _ResourceArtwork extends StatelessWidget {
  const _ResourceArtwork({required this.category, this.compact = false});
  final String category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final topic = guideTopic(context, category);
    if (compact) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: topic.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(topic.icon, size: 26, color: topic.color),
          ),
        ),
      );
    }
    return ExcludeSemantics(
      child: Container(
        height: 100,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: topic.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PositionedDirectional(
              end: -22,
              bottom: -44,
              child: Icon(
                Icons.circle_outlined,
                color: topic.color.withValues(alpha: .13),
                size: 180,
              ),
            ),
            PositionedDirectional(
              start: 18,
              top: 12,
              child: Icon(
                Icons.spa_outlined,
                color: topic.color.withValues(alpha: .17),
                size: 68,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(topic.icon, size: 32, color: topic.color),
            ),
          ],
        ),
      ),
    );
  }
}

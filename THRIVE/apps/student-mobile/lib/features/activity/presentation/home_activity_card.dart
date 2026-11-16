import 'package:flutter/material.dart';

import '../../../design_system/async_content.dart';
import '../../../design_system/thrive_theme.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/activity_repository.dart';
import 'mood_labels.dart';
import 'mood_trend_chart.dart';

class HomeActivityCard extends StatelessWidget {
  const HomeActivityCard({required this.repository, super.key});
  final ActivityRepository repository;
  @override
  Widget build(BuildContext context) => AsyncContent<StudentActivityData>(
    load: repository.current,
    builder: (context, data, reload) =>
        _ActivityContent(repository: repository, data: data, reload: reload),
  );
}

class _ActivityContent extends StatefulWidget {
  const _ActivityContent({
    required this.repository,
    required this.data,
    required this.reload,
  });
  final ActivityRepository repository;
  final StudentActivityData data;
  final VoidCallback reload;
  @override
  State<_ActivityContent> createState() => _ActivityContentState();
}

class _ActivityContentState extends State<_ActivityContent> {
  bool busy = false;
  int chartDays = 7;
  Object? failure;
  Future<void> change(int? value) async {
    if (busy) return;
    setState(() {
      busy = true;
      failure = null;
    });
    try {
      if (value == null) {
        await widget.repository.removeToday();
      } else {
        await widget.repository.save(value);
      }
      widget.reload();
    } catch (error) {
      if (mounted) setState(() => failure = error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = widget.repository.now();
    final entries = {
      for (final entry in widget.data.moods) diaryDay(entry.day): entry,
    };
    final current = entries[diaryDay(today)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.activityTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                l.activitySubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked =
                      constraints.maxWidth < 260 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.4;
                  final metrics = [
                    (
                      widget.data.completed,
                      l.activityCompleted,
                      Icons.task_alt_rounded,
                      const Color(0xFFE4F3EB),
                      ThriveColors.teal,
                    ),
                    (
                      widget.data.inProgress,
                      l.inProgress,
                      Icons.timelapse_rounded,
                      const Color(0xFFFFF1DE),
                      const Color(0xFF8C622E),
                    ),
                    (
                      widget.data.openReferrals,
                      l.activityOpenReferrals,
                      Icons.forum_outlined,
                      const Color(0xFFEEEAF8),
                      const Color(0xFF786096),
                    ),
                  ];
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final metric in metrics)
                        SizedBox(
                          width: stacked
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 20) / 3,
                          child: _ActivityMetric(
                            value: metric.$1,
                            label: metric.$2,
                            icon: metric.$3,
                            background: metric.$4,
                            foreground: metric.$5,
                            horizontal: stacked,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0DB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_outlined,
                      color: Color(0xFF9C732E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.dailyMoodTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(l.dailyMoodNotice),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var value = 1; value <= 5; value++)
                    ChoiceChip(
                      key: Key('mood-$value'),
                      avatar: Icon(switch (value) {
                        1 => Icons.sentiment_very_dissatisfied_rounded,
                        2 => Icons.sentiment_dissatisfied_rounded,
                        3 => Icons.sentiment_neutral_rounded,
                        4 => Icons.sentiment_satisfied_rounded,
                        _ => Icons.sentiment_very_satisfied_rounded,
                      }, size: 20),
                      label: Text(moodLabel(l, value)),
                      selected: current?.value == value,
                      onSelected: busy ? null : (_) => change(value),
                    ),
                ],
              ),
              if (current != null)
                TextButton.icon(
                  onPressed: busy ? null : () => change(null),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l.removeTodayMood),
                ),
              if (busy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
              if (failure != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InlineNotice(
                    text: requestError(context, failure),
                    isError: true,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.moodChartTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                l.moodChartSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final days in [7, 30])
                    ChoiceChip(
                      key: Key('mood-range-$days'),
                      label: Text(
                        days == 7 ? l.chartSevenDays : l.chartThirtyDays,
                      ),
                      selected: chartDays == days,
                      onSelected: (_) => setState(() => chartDays = days),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              MoodTrendChart(
                entries: widget.data.moods,
                today: today,
                days: chartDays,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.horizontal,
  });
  final int value;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final content = [
      Icon(icon, color: foreground, size: 22),
      SizedBox(width: horizontal ? 12 : 0, height: horizontal ? 0 : 10),
      Text(
        '$value',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: foreground,
        ),
      ),
      SizedBox(width: horizontal ? 12 : 0, height: horizontal ? 0 : 8),
      if (horizontal)
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        )
      else
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
    ];
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: horizontal
              ? Row(children: content)
              : Column(children: content),
        ),
      ),
    );
  }
}

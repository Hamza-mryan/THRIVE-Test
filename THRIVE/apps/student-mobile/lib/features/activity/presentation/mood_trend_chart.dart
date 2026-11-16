import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../design_system/thrive_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/activity_repository.dart';
import 'mood_labels.dart';

/// Missing days remain null. Lines join consecutive recorded days only.
List<MoodEntry?> moodWindow(List<MoodEntry> entries, DateTime end, int days) {
  final indexed = {for (final entry in entries) diaryDay(entry.day): entry};
  return List.generate(days, (index) {
    final day = DateTime(end.year, end.month, end.day - days + index + 1);
    return indexed[diaryDay(day)];
  });
}

class MoodTrendChart extends StatefulWidget {
  const MoodTrendChart({
    required this.entries,
    required this.today,
    required this.days,
    super.key,
  });
  final List<MoodEntry> entries;
  final DateTime today;
  final int days;

  @override
  State<MoodTrendChart> createState() => _MoodTrendChartState();
}

class _MoodTrendChartState extends State<MoodTrendChart> {
  int? selectedIndex;

  @override
  void didUpdateWidget(covariant MoodTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days != widget.days) selectedIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slots = moodWindow(widget.entries, widget.today, widget.days);
    final recorded = slots.whereType<MoodEntry>().length;
    final start = DateTime(
      widget.today.year,
      widget.today.month,
      widget.today.day - widget.days + 1,
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.MMMd(locale);
    String dayLabel(int index) =>
        dateFormat.format(DateTime(start.year, start.month, start.day + index));
    final detailIndex = selectedIndex ?? slots.lastIndexWhere((e) => e != null);
    final detail = detailIndex < 0 ? null : slots[detailIndex];
    final description = [
      l.moodChartTitle,
      l.moodChartRecorded(recorded, widget.days),
      l.moodChartGapNotice,
      for (var index = 0; index < slots.length; index++)
        if (slots[index] != null)
          '${dayLabel(index)}: ${moodLabel(l, slots[index]!.value)}',
    ].join('. ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              l.moodChartRecorded(recorded, widget.days),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ThriveColors.teal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l.moodChartLegend,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Semantics(
          key: const Key('mood-chart-semantics'),
          label: description,
          child: ExcludeSemantics(
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: recorded == 0
                    ? null
                    : (details) {
                        final fraction =
                            (details.localPosition.dx - 24) /
                            math.max(1, constraints.maxWidth - 36);
                        setState(() {
                          selectedIndex = (fraction * (widget.days - 1))
                              .round()
                              .clamp(0, widget.days - 1);
                        });
                      },
                child: SizedBox(
                  height: recorded == 0 ? 170 : 158,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          key: const Key('mood-trend-plot'),
                          painter: _MoodPlotPainter(
                            slots: slots,
                            selectedIndex: selectedIndex,
                            textDirection: Directionality.of(context),
                          ),
                        ),
                      ),
                      if (recorded == 0)
                        Container(
                          margin: const EdgeInsetsDirectional.only(start: 28),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .96),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            size: 38,
                            color: ThriveColors.teal,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Charts keep chronological time left-to-right in either app language.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dayLabel(0),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (MediaQuery.textScalerOf(context).scale(1) <= 1.4)
                  Expanded(
                    child: Text(
                      dayLabel(widget.days ~/ 2),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: Text(
                    dayLabel(widget.days - 1),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (recorded == 0) ...[
          Text(
            l.moodChartEmptyTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
        ],
        Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ThriveColors.mint.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              recorded == 0
                  ? l.moodChartEmptyBody
                  : '${dayLabel(detailIndex)} · ${detail == null ? l.moodNotRecorded : moodLabel(l, detail.value)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.moodChartGapNotice,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MoodPlotPainter extends CustomPainter {
  const _MoodPlotPainter({
    required this.slots,
    required this.selectedIndex,
    required this.textDirection,
  });
  final List<MoodEntry?> slots;
  final int? selectedIndex;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 24.0;
    const top = 10.0;
    final width = math.max(1.0, size.width - left - 12);
    final height = size.height - top - 10;
    Offset point(int index, int value) => Offset(
      left + width * index / (slots.length - 1),
      top + height * (5 - value) / 4,
    );
    final grid = Paint()
      ..color = ThriveColors.border
      ..strokeWidth = 1;
    for (var value = 1; value <= 5; value++) {
      final y = point(0, value).dy;
      for (var x = left; x < size.width - 12; x += 8) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 3, size.width - 12), y),
          grid,
        );
      }
      final label = TextPainter(
        text: TextSpan(
          text: '$value',
          style: const TextStyle(color: ThriveColors.muted, fontSize: 10),
        ),
        textDirection: textDirection,
      )..layout();
      label.paint(canvas, Offset(2, y - label.height / 2));
    }
    final stroke = Paint()
      ..color = ThriveColors.teal
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (var index = 1; index < slots.length; index++) {
      final previous = slots[index - 1];
      final current = slots[index];
      if (previous == null || current == null) continue;
      final a = point(index - 1, previous.value);
      final b = point(index, current.value);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo((a.dx + b.dx) / 2, a.dy, (a.dx + b.dx) / 2, b.dy, b.dx, b.dy);
      final area = Path.from(path)
        ..lineTo(b.dx, top + height)
        ..lineTo(a.dx, top + height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x332A9B8D), Color(0x032A9B8D)],
          ).createShader(Rect.fromLTWH(left, top, width, height)),
      );
      canvas.drawPath(path, stroke);
    }
    if (selectedIndex != null) {
      final x = point(selectedIndex!, 1).dx;
      canvas.drawLine(Offset(x, top), Offset(x, top + height), grid);
    }
    for (var index = 0; index < slots.length; index++) {
      final entry = slots[index];
      if (entry == null) continue;
      final center = point(index, entry.value);
      if (selectedIndex == index) {
        canvas.drawCircle(
          center,
          10,
          Paint()..color = ThriveColors.teal.withValues(alpha: .13),
        );
      }
      canvas.drawCircle(center, 5, Paint()..color = Colors.white);
      canvas.drawCircle(center, 3.5, Paint()..color = ThriveColors.teal);
    }
  }

  @override
  bool shouldRepaint(covariant _MoodPlotPainter oldDelegate) =>
      oldDelegate.slots != slots ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.textDirection != textDirection;
}

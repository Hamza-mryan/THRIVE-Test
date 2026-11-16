import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/feature_intro.dart';

import '../../app/feature_scaffold.dart';
import '../../design_system/async_content.dart';
import '../../design_system/thrive_theme.dart';
import '../../design_system/thrive_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../screening/data/screening_repository.dart';
import '../screening/presentation/screening_screens.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.repository, super.key});
  final ScreeningRepository repository;
  Future<void> open(
    BuildContext context,
    ScreeningSession session,
    VoidCallback reload,
  ) async {
    if (session.result != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FeatureScaffold(
            title: AppLocalizations.of(context).resultTitle,
            child: ResultContent(result: session.result!),
          ),
        ),
      );
    } else {
      try {
        final instruments = await repository.instruments();
        final matching = instruments.where(
          (instrument) => instrument.code == session.instrumentCode,
        );
        if (!context.mounted) return;
        if (matching.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).noInstruments)),
          );
          return;
        }
        final current = await repository.session(session.id);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuestionnaireScreen(
              repository: repository,
              instrument: matching.first,
              session: current,
            ),
          ),
        );
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(requestError(context, error))));
        }
      }
    }
    reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AsyncContent<List<ScreeningSession>>(
      load: repository.history,
      builder: (context, sessions, reload) => PageContent(
        children: [
          FeatureIntro(
            title: l.historyTitle,
            body: l.historyOverviewBody,
            icon: Icons.history_rounded,
            trailing: IconButton(
              onPressed: reload,
              tooltip: l.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(height: 24),
          if (sessions.isEmpty)
            EmptyContent(title: l.noHistory, body: l.noHistoryBody),
          if (sessions.isNotEmpty) ...[
            _HistoryOverview(sessions: sessions),
            const SizedBox(height: 22),
          ],
          for (final complete in [false, true]) ...[
            if (sessions.any((session) => session.completed == complete)) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Semantics(
                  header: true,
                  child: Text(
                    complete ? l.pastSessionsTitle : l.resumeJourneyTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
            for (final session in sessions.where(
              (session) => session.completed == complete,
            )) ...[
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: session.completed
                                ? ThriveColors.mint
                                : const Color(0xFFFFF0D8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            session.completed
                                ? Icons.task_alt_rounded
                                : Icons.edit_note_rounded,
                            color: ThriveColors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.instrumentCode == 'DEMO-CHECK'
                                    ? l.demoLabel
                                    : session.instrumentCode,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayDate(context, session.startedAtUtc),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: StatusPill(
                        label: session.completed ? l.completed : l.inProgress,
                        icon: session.completed
                            ? Icons.check_circle_outline
                            : Icons.schedule_rounded,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => open(context, session, reload),
                      icon: Icon(
                        session.completed
                            ? Icons.insights_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        session.completed ? l.viewResult : l.resumeCheck,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class _HistoryOverview extends StatelessWidget {
  const _HistoryOverview({required this.sessions});
  final List<ScreeningSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final completed = sessions.where((s) => s.completed).length;
    final pending = sessions.length - completed;
    final chart = Semantics(
      label:
          '${l.historySessionCount(sessions.length)}. ${l.completed}: $completed. ${l.inProgress}: $pending',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 94,
          child: CustomPaint(
            painter: _SessionRingPainter(completed / sessions.length),
            child: Center(
              child: Text(
                '${sessions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.historyOverview,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            Text(
              '$completed ${l.completed}',
              style: const TextStyle(color: Color(0xFFB8EBDA), fontSize: 13),
            ),
            Text(
              '$pending ${l.inProgress}',
              style: const TextStyle(color: Color(0xFFFFD99C), fontSize: 13),
            ),
          ],
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThriveColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 290 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.4) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [chart, const SizedBox(height: 18), copy],
            );
          }
          return Row(
            children: [
              chart,
              const SizedBox(width: 22),
              Expanded(child: copy),
            ],
          );
        },
      ),
    );
  }
}

class _SessionRingPainter extends CustomPainter {
  const _SessionRingPainter(this.fraction);
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final rect = bounds.deflate(6);
    final base = Paint()
      ..color = const Color(0xFFFFD99C)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawOval(rect, base);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        Paint()
          ..color = const Color(0xFF8BD4B7)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SessionRingPainter oldDelegate) =>
      fraction != oldDelegate.fraction;
}

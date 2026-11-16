import 'package:flutter/material.dart';

import '../../../design_system/feature_intro.dart';

import '../../../app/feature_scaffold.dart';
import '../../../app/support_path_links.dart';
import '../../../design_system/async_content.dart';
import '../../../design_system/thrive_theme.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../application/screening_controller.dart';
import '../data/screening_repository.dart';

bool _isArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

class ScreeningScreen extends StatelessWidget {
  const ScreeningScreen({required this.repository, super.key});
  final ScreeningRepository repository;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AsyncContent<List<Instrument>>(
      load: repository.instruments,
      builder: (context, instruments, reload) => PageContent(
        children: [
          FeatureIntro(
            title: l.checkTitle,
            body: l.demoCheckNotice,
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 20),
          if (instruments.isEmpty)
            EmptyContent(title: l.noInstruments, body: l.clinicalToolsPending),
          for (final instrument in instruments) ...[
            _InstrumentCard(repository: repository, instrument: instrument),
            const SizedBox(height: 16),
          ],
          InlineNotice(text: l.clinicalToolsPending),
        ],
      ),
    );
  }
}

class _InstrumentCard extends StatefulWidget {
  const _InstrumentCard({required this.repository, required this.instrument});
  final ScreeningRepository repository;
  final Instrument instrument;
  @override
  State<_InstrumentCard> createState() => _InstrumentCardState();
}

class _InstrumentCardState extends State<_InstrumentCard> {
  bool busy = false;
  Object? error;
  Future<void> start() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final session = await widget.repository.start(widget.instrument.code);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuestionnaireScreen(
            repository: widget.repository,
            instrument: widget.instrument,
            session: session,
          ),
        ),
      );
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.fact_check_outlined,
            size: 36,
            color: ThriveColors.teal,
          ),
          const SizedBox(height: 16),
          Text(
            _isArabic(context)
                ? widget.instrument.titleAr
                : widget.instrument.titleEn,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(l.demoCheckNotice),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: busy ? null : start,
            child: Text(busy ? l.loading : l.startCheck),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            InlineNotice(text: requestError(context, error), isError: true),
          ],
        ],
      ),
    );
  }
}

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({
    required this.repository,
    required this.instrument,
    required this.session,
    super.key,
  });
  final ScreeningRepository repository;
  final Instrument instrument;
  final ScreeningSession session;
  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final controller = ScreeningController(
    repository: widget.repository,
    instrument: widget.instrument,
    session: widget.session,
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      final result = controller.result ?? widget.session.result;
      return FeatureScaffold(
        title: l.checkTitle,
        child: result != null
            ? ResultContent(result: result)
            : PageContent(
                children: [
                  StatusPill(label: l.demoLabel, icon: Icons.science_outlined),
                  const SizedBox(height: 16),
                  Text(
                    l.questionProgress(
                      controller.index + 1,
                      controller.instrument.items.length,
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value:
                        (controller.index + 1) /
                        controller.instrument.items.length,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 24),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isArabic(context)
                              ? controller.item.promptAr
                              : controller.item.promptEn,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        RadioGroup<int>(
                          groupValue: controller.selected,
                          onChanged: (value) {
                            if (!controller.busy && value != null) {
                              controller.choose(value);
                            }
                          },
                          child: Column(
                            children: [
                              for (final option in controller.item.options)
                                RadioListTile<int>(
                                  value: option.value,
                                  selected: controller.selected == option.value,
                                  selectedTileColor: ThriveColors.mint,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabled: !controller.busy,
                                  title: Text(
                                    _isArabic(context)
                                        ? option.labelAr
                                        : option.labelEn,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (controller.busy) const LinearProgressIndicator(),
                  if (controller.error != null)
                    InlineNotice(
                      text: requestError(context, controller.error),
                      isError: true,
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: controller.busy || controller.index == 0
                            ? null
                            : () => controller.move(controller.index - 1),
                        child: Text(l.previous),
                      ),
                      if (controller.index <
                          controller.instrument.items.length - 1)
                        FilledButton(
                          onPressed:
                              controller.busy || controller.selected == null
                              ? null
                              : () => controller.move(controller.index + 1),
                          child: Text(l.next),
                        )
                      else
                        FilledButton(
                          onPressed: controller.busy || !controller.allAnswered
                              ? null
                              : controller.submit,
                          child: Text(l.submitCheck),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.answersSavedOnServer,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: controller.busy
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.pause_circle_outline),
                    label: Text(l.pauseCheck),
                  ),
                ],
              ),
      );
    },
  );
}

class ResultContent extends StatelessWidget {
  const ResultContent({required this.result, super.key});
  final ScreeningResult result;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageContent(
      children: [
        StatusPill(label: l.demoLabel, icon: Icons.science_outlined),
        const SizedBox(height: 20),
        FeatureIntro(
          title: l.resultTitle,
          body: l.demoCheckNotice,
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.task_alt, size: 48, color: ThriveColors.teal),
              const SizedBox(height: 18),
              Text(
                l.technicalTotal(result.rawScore, result.maxScore),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(_isArabic(context) ? result.reasonAr : result.reasonEn),
              const SizedBox(height: 16),
              Text(displayDate(context, result.createdAtUtc)),
              Text(
                l.ruleVersion(result.ruleVersion),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SupportPathLinks(includeGuide: true),
      ],
    );
  }
}

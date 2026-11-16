import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/thrive_theme.dart';
import '../../../design_system/thrive_widgets.dart';
import '../../../l10n/app_localizations.dart';

/// Optional visual pacing for the draft gentle-breathing resource; no breath holds.
class BreathingPractice extends StatefulWidget {
  const BreathingPractice({super.key});

  @override
  State<BreathingPractice> createState() => _BreathingPracticeState();
}

class _BreathingPracticeState extends State<BreathingPractice>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController rhythm =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..addStatusListener((_) {
          if (mounted) setState(() {});
        });
  Timer? timer;
  int seconds = 300;
  bool running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void pause() {
    timer?.cancel();
    rhythm.stop();
    setState(() => running = false);
  }

  void start() {
    if (seconds == 0) seconds = 300;
    setState(() => running = true);
    rhythm.repeat(reverse: true);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds <= 1) {
        pause();
        setState(() => seconds = 0);
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (running && state != AppLifecycleState.resumed) pause();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.isCurrentOf(context) == false && running) pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    rhythm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final number = NumberFormat(
      '00',
      Localizations.localeOf(context).languageCode,
    );
    final clock =
        '${number.format(seconds ~/ 60)}:${number.format(seconds % 60)}';
    final label = !running
        ? seconds == 0
              ? l.practiceComplete
              : l.practiceReady
        : rhythm.status == AnimationStatus.reverse
        ? l.breatheOut
        : l.breatheIn;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.breathingPracticeTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(l.breathingPracticeBody),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: rhythm,
            builder: (context, _) => SizedBox(
              height: 210,
              child: Center(
                child: ExcludeSemantics(
                  child: Transform.scale(
                    scale: MediaQuery.disableAnimationsOf(context)
                        ? 1
                        : .76 + rhythm.value * .24,
                    child: Container(
                      width: 196,
                      height: 196,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThriveColors.teal.withValues(alpha: .12),
                          width: 13,
                        ),
                        color: ThriveColors.mint,
                        boxShadow: [
                          BoxShadow(
                            color: ThriveColors.teal.withValues(alpha: .12),
                            blurRadius: 28,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.air_rounded,
                        color: ThriveColors.teal,
                        size: 55,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Semantics(
            liveRegion: true,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            clock,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: running ? pause : start,
            icon: Icon(
              running ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(running ? l.pausePractice : l.startPractice),
          ),
          if (seconds != 300)
            TextButton(
              onPressed: () {
                pause();
                rhythm.reset();
                setState(() => seconds = 300);
              },
              child: Text(l.resetPractice),
            ),
        ],
      ),
    );
  }
}

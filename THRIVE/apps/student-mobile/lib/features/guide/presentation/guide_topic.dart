import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../design_system/thrive_theme.dart';

/// Stable catalog categories are translated at the presentation boundary.
({String label, IconData icon, Color color, Color surface}) guideTopic(
  BuildContext context,
  String category,
) {
  final l = AppLocalizations.of(context);
  return switch (category.toLowerCase()) {
    'stress' => (
      label: l.topicStress,
      icon: Icons.spa_outlined,
      color: ThriveColors.guideInk,
      surface: ThriveColors.mint,
    ),
    'exams' => (
      label: l.topicExams,
      icon: Icons.school_outlined,
      color: ThriveColors.checkInk,
      surface: ThriveColors.sky,
    ),
    'sleep' => (
      label: l.topicSleep,
      icon: Icons.nights_stay_outlined,
      color: ThriveColors.plusInk,
      surface: ThriveColors.lavender,
    ),
    'time' => (
      label: l.topicTime,
      icon: Icons.schedule_rounded,
      color: ThriveColors.connectInk,
      surface: ThriveColors.apricot,
    ),
    'breathing' => (
      label: l.topicBreathing,
      icon: Icons.air_rounded,
      color: ThriveColors.checkInk,
      surface: ThriveColors.sky,
    ),
    'grounding' => (
      label: l.topicGrounding,
      icon: Icons.nature_people_outlined,
      color: ThriveColors.connectInk,
      surface: ThriveColors.apricot,
    ),
    'using thrive' => (
      label: l.topicProduct,
      icon: Icons.auto_stories_outlined,
      color: ThriveColors.guideInk,
      surface: ThriveColors.mint,
    ),
    _ => (
      label: category,
      icon: Icons.auto_stories_outlined,
      color: ThriveColors.checkInk,
      surface: ThriveColors.sky,
    ),
  };
}

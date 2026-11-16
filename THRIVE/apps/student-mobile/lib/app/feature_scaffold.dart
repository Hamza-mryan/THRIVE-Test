import 'package:flutter/material.dart';

import '../features/safety/safety_sheet.dart';
import '../l10n/app_localizations.dart';
import '../design_system/thrive_theme.dart';

class FeatureScaffold extends StatelessWidget {
  const FeatureScaffold({required this.title, required this.child, super.key});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(child: child),
    bottomNavigationBar: const UrgentHelpBar(),
  );
}

class UrgentHelpBar extends StatelessWidget {
  const UrgentHelpBar({this.includeBottomSafeArea = true, super.key});
  final bool includeBottomSafeArea;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: includeBottomSafeArea,
    child: Container(
      color: ThriveColors.canvas,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: OutlinedButton.icon(
        key: const Key('urgent-help'),
        onPressed: () => showSafetySheet(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: ThriveColors.urgent,
          backgroundColor: ThriveColors.errorSurface,
          side: BorderSide(color: ThriveColors.urgent.withValues(alpha: .4)),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: const Icon(Icons.favorite_border_rounded, size: 20),
        label: Text(
          AppLocalizations.of(context).urgentHelp,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

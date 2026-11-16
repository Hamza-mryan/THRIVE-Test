import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'thrive_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.ltr,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: ThriveColors.teal,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THRIVE Test',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 21,
              height: 1.3,
              letterSpacing: 0.2,
              color: ThriveColors.navy,
            ),
          ),
          Text(
            AppLocalizations.of(context).brandTagline,
            style: const TextStyle(
              fontSize: 11,
              height: 1.5,
              color: ThriveColors.muted,
            ),
          ),
        ],
      ),
    ],
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: ThriveColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class PageContent extends StatelessWidget {
  const PageContent({required this.children, this.maxWidth = 680, super.key});
  final List<Widget> children;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, this.icon = Icons.circle, super.key});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ThriveColors.border),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ThriveColors.teal, size: 13),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: ThriveColors.teal,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class InlineNotice extends StatelessWidget {
  const InlineNotice({required this.text, this.isError = false, super.key});
  final String text;
  final bool isError;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: isError,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? ThriveColors.errorSurface : ThriveColors.softSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline_rounded,
            color: isError ? ThriveColors.urgent : ThriveColors.teal,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.8,
                color: isError ? ThriveColors.urgent : ThriveColors.muted,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

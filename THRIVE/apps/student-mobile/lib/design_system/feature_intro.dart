import 'package:flutter/material.dart';

import 'thrive_theme.dart';

/// Shared feature hierarchy; decorative artwork never carries meaning alone.
class FeatureIntro extends StatelessWidget {
  const FeatureIntro({
    required this.title,
    required this.body,
    required this.icon,
    this.eyebrow,
    this.accent = ThriveColors.teal,
    this.background = ThriveColors.mint,
    this.trailing,
    super.key,
  });
  final String title;
  final String body;
  final String? eyebrow;
  final IconData icon;
  final Color accent;
  final Color background;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
          ),
          const SizedBox(width: 12),
          if (eyebrow != null)
            Expanded(
              child: Text(
                eyebrow!,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          if (eyebrow == null) const Spacer(),
          ?trailing,
        ],
      ),
      const SizedBox(height: 18),
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
      ),
      const SizedBox(height: 8),
      Text(
        body,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: ThriveColors.muted),
      ),
    ],
  );
}

import '../../../l10n/app_localizations.dart';

String moodLabel(AppLocalizations l, int value) => switch (value) {
  1 => l.moodVeryLow,
  2 => l.moodLow,
  3 => l.moodNeutral,
  4 => l.moodGood,
  _ => l.moodVeryGood,
};

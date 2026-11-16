import 'package:flutter/material.dart';

import '../design_system/async_content.dart';
import '../design_system/thrive_theme.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/guide/presentation/guide_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/referrals/presentation/referral_screens.dart';
import '../features/screening/presentation/screening_screens.dart';
import '../l10n/app_localizations.dart';
import 'feature_scaffold.dart';
import 'student_services.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({required this.onboarding, this.services, super.key});
  final OnboardingController onboarding;
  final StudentServices? services;
  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int selected = 0;
  int activityRevision = 0;
  Future<void> openPath(String path) async {
    final services = widget.services;
    if (services == null) return;
    final l = AppLocalizations.of(context);
    if (path == 'guide') {
      setState(() => selected = 2);
      return;
    }
    final (title, page) = switch (path) {
      'check' => (
        l.checkTitle,
        ScreeningScreen(repository: services.screening),
      ),
      'plus' => (
        l.plusTitle,
        ServiceDirectoryScreen(
          repository: services.referrals,
          level: 'Specialist',
        ),
      ),
      _ => (
        l.connectTitle,
        ServiceDirectoryScreen(
          repository: services.referrals,
          level: 'Counseling',
        ),
      ),
    };
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FeatureScaffold(title: title, child: page),
      ),
    );
    if (mounted) setState(() => activityRevision++);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = widget.services;
    final body = switch (selected) {
      0 => HomeScreen(
        onPath: openPath,
        activity: services?.activity,
        activityRevision: activityRevision,
        onHistory: () => setState(() => selected = 1),
      ),
      1 when services != null => HistoryScreen(repository: services.screening),
      2 when services != null => GuideScreen(repository: services.guide),
      3 when services != null => ReferralsScreen(
        repository: services.referrals,
      ),
      4 when services != null => AccountScreen(
        repository: services.account,
        onboarding: widget.onboarding,
      ),
      _ => EmptyContent(title: l.serviceError, body: l.identityPending),
    };
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l.navHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.history),
        label: l.navHistory,
      ),
      NavigationDestination(
        icon: const Icon(Icons.auto_stories_outlined),
        label: l.navGuide,
      ),
      NavigationDestination(
        icon: const Icon(Icons.route_outlined),
        label: l.navReferrals,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        label: l.navAccount,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= 1000 &&
            constraints.maxHeight >= 480 &&
            MediaQuery.textScalerOf(context).scale(1) <= 1.4;
        final content = Column(
          children: [
            Expanded(child: body),
            const UrgentHelpBar(includeBottomSafeArea: false),
            if (!wide)
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: ThriveColors.border)),
                ),
                child: NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (index) =>
                      setState(() => selected = index),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: destinations,
                ),
              ),
          ],
        );
        return Row(
          children: [
            if (wide)
              NavigationRail(
                scrollable: true,
                selectedIndex: selected,
                onDestinationSelected: (index) =>
                    setState(() => selected = index),
                labelType: NavigationRailLabelType.all,
                minWidth: 112,
                backgroundColor: Colors.white,
                indicatorColor: ThriveColors.mint,
                selectedIconTheme: const IconThemeData(
                  color: ThriveColors.teal,
                ),
                selectedLabelTextStyle: const TextStyle(
                  fontFamily: 'NotoSansArabic',
                  color: ThriveColors.navy,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  fontFamily: 'NotoSansArabic',
                  color: ThriveColors.muted,
                ),
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: Text(destination.label),
                    ),
                ],
              ),
            if (wide) const VerticalDivider(width: 1),
            Expanded(key: const ValueKey('student-content'), child: content),
          ],
        );
      },
    );
  }
}

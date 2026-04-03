import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/session_provider.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final location = GoRouterState.of(context).matchedLocation;
    final l10n = AppLocalizations.of(context)!;

    int selectedIndex = 0;
    if (location.startsWith('/debug')) selectedIndex = 1;
    if (location.startsWith('/settings')) selectedIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/workbench');
              break;
            case 1:
              context.go('/debug');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navController,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: session.logs.isNotEmpty,
              child: const Icon(Icons.bug_report_outlined),
            ),
            selectedIcon: const Icon(Icons.bug_report),
            label: l10n.navDebug,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

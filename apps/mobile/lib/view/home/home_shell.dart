import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/session_provider.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/debug')) selectedIndex = 1;
    if (location.startsWith('/gps')) selectedIndex = 2;
    if (location.startsWith('/settings')) selectedIndex = 3;

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
              context.go('/gps');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '工作台',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: session.logs.isNotEmpty,
              child: const Icon(Icons.bug_report_outlined),
            ),
            selectedIcon: const Icon(Icons.bug_report),
            label: '调试台',
          ),
          const NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'GPS',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view/home/home_shell.dart';
import '../view/workbench/workbench_view.dart';
import '../view/debug/debug_console_view.dart';
import '../view/settings/settings_view.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/workbench',
    routes: [
      // Shell routes (main app)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/workbench',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WorkbenchView(),
            ),
          ),
          GoRoute(
            path: '/debug',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DebugConsoleView(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsView(),
            ),
          ),
        ],
      ),
    ],
  );
}
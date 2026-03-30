import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view/home/home_shell.dart';
import '../view/workbench/workbench_view.dart';
import '../view/debug/debug_console_view.dart';
import '../view/gps/gps_settings_view.dart';
import '../view/scan/device_scan_view.dart';
import '../view/settings/settings_view.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/scan',
    routes: [
      // Scan page (root, no shell)
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DeviceScanView(),
      ),
      // Shell routes (only accessible when connected)
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
            path: '/gps',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GpsSettingsView(),
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
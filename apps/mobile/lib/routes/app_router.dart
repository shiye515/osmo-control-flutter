import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view/workbench/workbench_view.dart';
import '../view/debug/debug_console_view.dart';
import '../view/settings/settings_view.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Home page (WorkbenchView)
      GoRoute(
        path: '/',
        builder: (context, state) => const WorkbenchView(),
      ),
      // Debug console page
      GoRoute(
        path: '/debug',
        builder: (context, state) => const DebugConsoleView(),
      ),
      // Settings page
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsView(),
      ),
    ],
  );
}
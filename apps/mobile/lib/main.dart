import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/ble_provider.dart';
import 'providers/session_provider.dart';
import 'providers/gps_provider.dart';
import 'providers/debug_provider.dart';
import 'routes/app_router.dart';

void main() {
  _setupLogging();
  runApp(const OsmoControlApp());
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('[${record.level.name}] ${record.loggerName}: ${record.message}');
  });
}

class OsmoControlApp extends StatelessWidget {
  const OsmoControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleProvider()),
        ChangeNotifierProxyProvider<BleProvider, SessionProvider>(
          create: (_) => SessionProvider(),
          update: (_, ble, session) => session!..updateBleProvider(ble),
        ),
        ChangeNotifierProxyProvider<SessionProvider, GpsProvider>(
          create: (_) => GpsProvider(),
          update: (_, session, gps) => gps!..updateSession(session),
        ),
        ChangeNotifierProxyProvider<SessionProvider, DebugProvider>(
          create: (_) => DebugProvider(),
          update: (_, session, debug) => debug!..updateSession(session),
        ),
      ],
      child: MaterialApp.router(
        title: '欧思魔控',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

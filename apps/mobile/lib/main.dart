import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/ble_provider.dart';
import 'providers/session_provider.dart';
import 'providers/gps_provider.dart';
import 'providers/debug_provider.dart';
import 'routes/app_router.dart';
import 'services/location_service.dart';

void main() {
  _setupLogging();
  final locationService = LocationService();
  runApp(OsmoControlApp(locationService: locationService));
}

void _setupLogging() {
  // Only show warnings and errors in production
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint('[${record.level.name}] ${record.loggerName}: ${record.message}');
  });
}

class OsmoControlApp extends StatelessWidget {
  final LocationService locationService;
  const OsmoControlApp({super.key, required this.locationService});

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
          create: (_) => GpsProvider()..setLocationService(locationService)..loadGpsEnabledState(),
          update: (_, session, gps) => gps!..updateSession(session),
        ),
        ChangeNotifierProxyProvider<SessionProvider, DebugProvider>(
          create: (_) => DebugProvider(),
          update: (_, session, debug) => debug!..updateSession(session),
        ),
      ],
      child: MaterialApp.router(
        title: 'Osmo 遥控器',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

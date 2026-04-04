// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:osmo_control/main.dart';
import 'package:osmo_control/services/location_service.dart';
import 'package:osmo_control/services/permission_service.dart';
import 'package:osmo_control/services/background_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(OsmoControlApp(
      locationService: LocationService(),
      backgroundService: BackgroundServiceManager.instance,
      permissionService: PermissionService(),
    ));

    // Verify that the app builds without errors
    expect(find.text('Osmo 遥控器'), findsWidgets);
  });
}
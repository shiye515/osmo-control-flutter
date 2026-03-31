// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Osmo Controller';

  @override
  String get navController => 'Controller';

  @override
  String get navDebug => 'Debug';

  @override
  String get navGps => 'GPS';

  @override
  String get navSettings => 'Settings';

  @override
  String get gpsSettings => 'GPS Settings';

  @override
  String get gpsAcquisition => 'GPS Acquisition';

  @override
  String get enableGps => 'Enable GPS';

  @override
  String get gpsAcquiringLocation => 'Acquiring location data';

  @override
  String get gpsDisabled => 'GPS acquisition is disabled';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get allowLocationInSettings =>
      'Please allow location access in system settings';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get altitude => 'Altitude';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get time => 'Time';

  @override
  String get noLocationData => 'No location data';

  @override
  String get autoPush => 'Auto Push';

  @override
  String get enableGpsAutoPush => 'Enable GPS Auto Push';

  @override
  String get autoPushDescription =>
      'Automatically push phone GPS location to device';

  @override
  String pushFrequency(String frequency) {
    return 'Push Frequency: $frequency';
  }

  @override
  String get pushNow => 'Push Current Location';

  @override
  String get settings => 'Settings';

  @override
  String get debugSection => 'Debug';

  @override
  String get simulateDeviceMode => 'Simulate Device Mode';

  @override
  String get simulateDeviceModeDescription =>
      'Use virtual device for UI demo without real hardware';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutAppTitle => 'Osmo Controller';

  @override
  String get aboutAppSubtitle => 'Osmo Device Flutter Controller v1.0.0';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get debugConsole => 'Debug Console';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get noLogs => 'No logs';

  @override
  String get queryVersion => 'Query Version';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get switchToPhoto => 'Switch to Photo';

  @override
  String get sleep => 'Sleep';

  @override
  String get enterHexCommand => 'Enter hex command (e.g.: 55 12 00 ...)';

  @override
  String get send => 'Send';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get scanDevices => 'Scan Devices';

  @override
  String searchingFor(String deviceName) {
    return 'Searching for $deviceName...';
  }

  @override
  String get bluetoothDisabled =>
      'Bluetooth is disabled. Please enable Bluetooth and try again';

  @override
  String get gotIt => 'Got it';

  @override
  String get scanningDevices => 'Scanning for nearby devices...';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get previouslyConnected => 'Previously connected';

  @override
  String get connect => 'Connect';

  @override
  String get connectionFailed => 'Connection failed. Please try again';

  @override
  String get battery => 'Battery';

  @override
  String get storage => 'Storage';

  @override
  String get remaining => 'Remaining';

  @override
  String get recording => 'Recording';

  @override
  String get temperature => 'Temperature';

  @override
  String get overheating => 'Overheating';

  @override
  String get normal => 'Normal';

  @override
  String get status => 'Status';

  @override
  String get power => 'Power';

  @override
  String get stop => 'Stop';

  @override
  String get photo => 'Photo';

  @override
  String get record => 'Record';

  @override
  String get gpsNotEnabled => 'Disabled';

  @override
  String get gpsAcquiring => 'Acquiring';
}

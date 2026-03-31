import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Osmo Controller'**
  String get appTitle;

  /// Navigation label for controller tab
  ///
  /// In en, this message translates to:
  /// **'Controller'**
  String get navController;

  /// Navigation label for debug tab
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get navDebug;

  /// Navigation label for GPS tab
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get navGps;

  /// Navigation label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// GPS settings page title
  ///
  /// In en, this message translates to:
  /// **'GPS Settings'**
  String get gpsSettings;

  /// GPS acquisition section title
  ///
  /// In en, this message translates to:
  /// **'GPS Acquisition'**
  String get gpsAcquisition;

  /// Enable GPS switch label
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get enableGps;

  /// GPS status when acquiring
  ///
  /// In en, this message translates to:
  /// **'Acquiring location data'**
  String get gpsAcquiringLocation;

  /// GPS status when disabled
  ///
  /// In en, this message translates to:
  /// **'GPS acquisition is disabled'**
  String get gpsDisabled;

  /// Toast title for permission denied
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// Toast description for permission denied
  ///
  /// In en, this message translates to:
  /// **'Please allow location access in system settings'**
  String get allowLocationInSettings;

  /// Current location section title
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// Latitude label
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// Longitude label
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// Altitude label
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get altitude;

  /// Accuracy label
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No location data placeholder
  ///
  /// In en, this message translates to:
  /// **'No location data'**
  String get noLocationData;

  /// Auto push section title
  ///
  /// In en, this message translates to:
  /// **'Auto Push'**
  String get autoPush;

  /// Enable GPS auto push switch label
  ///
  /// In en, this message translates to:
  /// **'Enable GPS Auto Push'**
  String get enableGpsAutoPush;

  /// Auto push feature description
  ///
  /// In en, this message translates to:
  /// **'Automatically push phone GPS location to device'**
  String get autoPushDescription;

  /// Push frequency label
  ///
  /// In en, this message translates to:
  /// **'Push Frequency: {frequency}'**
  String pushFrequency(String frequency);

  /// Push current location button label
  ///
  /// In en, this message translates to:
  /// **'Push Current Location'**
  String get pushNow;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Debug section header
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debugSection;

  /// Fake device mode switch label
  ///
  /// In en, this message translates to:
  /// **'Simulate Device Mode'**
  String get simulateDeviceMode;

  /// Fake device mode description
  ///
  /// In en, this message translates to:
  /// **'Use virtual device for UI demo without real hardware'**
  String get simulateDeviceModeDescription;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// App title in about section
  ///
  /// In en, this message translates to:
  /// **'Osmo Controller'**
  String get aboutAppTitle;

  /// App subtitle in about section
  ///
  /// In en, this message translates to:
  /// **'Osmo Device Flutter Controller v1.0.0'**
  String get aboutAppSubtitle;

  /// Open source licenses menu item
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// Debug console page title
  ///
  /// In en, this message translates to:
  /// **'Debug Console'**
  String get debugConsole;

  /// Clear logs tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No logs placeholder
  ///
  /// In en, this message translates to:
  /// **'No logs'**
  String get noLogs;

  /// Preset command: query version
  ///
  /// In en, this message translates to:
  /// **'Query Version'**
  String get queryVersion;

  /// Preset command: start recording
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// Preset command: stop recording
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// Preset command: switch to photo mode
  ///
  /// In en, this message translates to:
  /// **'Switch to Photo'**
  String get switchToPhoto;

  /// Preset command: sleep
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// Hex input hint
  ///
  /// In en, this message translates to:
  /// **'Enter hex command (e.g.: 55 12 00 ...)'**
  String get enterHexCommand;

  /// Send button label
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Copy confirmation snackbar
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Scan devices page title
  ///
  /// In en, this message translates to:
  /// **'Scan Devices'**
  String get scanDevices;

  /// Auto-connect banner text
  ///
  /// In en, this message translates to:
  /// **'Searching for {deviceName}...'**
  String searchingFor(String deviceName);

  /// Bluetooth disabled banner
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is disabled. Please enable Bluetooth and try again'**
  String get bluetoothDisabled;

  /// Dismiss button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Scanning in progress text
  ///
  /// In en, this message translates to:
  /// **'Scanning for nearby devices...'**
  String get scanningDevices;

  /// No devices found text
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// Previously connected badge
  ///
  /// In en, this message translates to:
  /// **'Previously connected'**
  String get previouslyConnected;

  /// Connect button label
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Connection failed snackbar
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Please try again'**
  String get connectionFailed;

  /// Battery tile label
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// Storage tile label
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// Remaining time tile label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Recording tile label
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// Temperature tile label
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Overheating status
  ///
  /// In en, this message translates to:
  /// **'Overheating'**
  String get overheating;

  /// Normal status
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// Status tile label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Power tile label
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// Stop recording button
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Take photo button
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// Start recording button
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// GPS disabled status
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get gpsNotEnabled;

  /// GPS acquiring status
  ///
  /// In en, this message translates to:
  /// **'Acquiring'**
  String get gpsAcquiring;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

class AppConstants {
  // BLE
  static const String osmoServiceUuid = '0000FFF0-0000-1000-8000-00805F9B34FB';
  static const String osmoWriteCharUuid = '0000FFF6-0000-1000-8000-00805F9B34FB';
  static const String osmoNotifyCharUuid = '0000FFF7-0000-1000-8000-00805F9B34FB';

  // Scan
  static const int scanTimeoutSeconds = 15;
  static const String osmoDeviceNamePrefix = 'Osmo';

  // GPS
  static const double defaultGpsFrequencyHz = 1.0;
  static const double maxGpsFrequencyHz = 10.0;
  static const double minGpsFrequencyHz = 0.1;

  // Protocol
  static const int dumlHeaderByte = 0x55;
  static const int dumlVersion = 0x01;

  // Camera modes
  static const int cameraModeVideo = 0;
  static const int cameraModePhoto = 1;
  static const int cameraModeSlow = 2;
  static const int cameraModeTimelapse = 3;

  // Preferences keys
  static const String prefKeyFakeMode = 'fake_mode_enabled';
  static const String prefKeyControllerId = 'controller_id';
  static const String prefKeyPairedDeviceId = 'paired_device_id';
  static const String prefKeyGpsFrequency = 'gps_frequency_hz';
}

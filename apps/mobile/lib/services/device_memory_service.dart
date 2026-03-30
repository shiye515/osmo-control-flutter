import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting last connected device information.
class DeviceMemoryService {
  static const String _keyLastDeviceId = 'last_device_id';
  static const String _keyLastDeviceName = 'last_device_name';

  /// Save device ID and name to persistent storage.
  Future<void> saveDevice(String deviceId, String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastDeviceId, deviceId);
    await prefs.setString(_keyLastDeviceName, deviceName);
  }

  /// Get stored device information.
  /// Returns (deviceId, deviceName) or null if not stored.
  Future<({String id, String name})?> getDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyLastDeviceId);
    final name = prefs.getString(_keyLastDeviceName);
    if (id == null || name == null) return null;
    return (id: id, name: name);
  }

  /// Clear stored device information.
  Future<void> clearDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastDeviceId);
    await prefs.remove(_keyLastDeviceName);
  }

  /// Check if a device is stored.
  Future<bool> hasDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyLastDeviceId);
  }
}
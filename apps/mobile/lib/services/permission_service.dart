import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:logging/logging.dart';

/// Represents a group of permissions with combined status.
class PermissionGroupStatus {
  final String name;
  final String description;
  final List<ph.Permission> permissions;
  final PermissionStatusType status;
  final ph.Permission?
      deniedPermission; // The specific permission that is denied

  const PermissionGroupStatus({
    required this.name,
    required this.description,
    required this.permissions,
    required this.status,
    this.deniedPermission,
  });

  bool get isGranted => status == PermissionStatusType.granted;
  bool get isDenied => status == PermissionStatusType.denied;
  bool get isPermanentlyDenied =>
      status == PermissionStatusType.permanentlyDenied;
}

/// Permission status types.
enum PermissionStatusType {
  granted,
  denied,
  permanentlyDenied,
}

/// Service for managing app permissions uniformly.
class PermissionService extends ChangeNotifier {
  static final _log = Logger('PermissionService');

  List<PermissionGroupStatus> _permissionStatuses = [];
  bool _isInitialized = false;

  List<PermissionGroupStatus> get permissionStatuses => _permissionStatuses;
  bool get isInitialized => _isInitialized;
  bool get allGranted => _permissionStatuses.every((p) => p.isGranted);

  /// Initialize and check all permission statuses.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await checkAllPermissions();
    _isInitialized = true;
    notifyListeners();
  }

  /// Check all required permissions and update status list.
  Future<void> checkAllPermissions() async {
    _log.info('Checking all permissions...');
    final statuses = <PermissionGroupStatus>[];

    // Bluetooth permission group
    final bluetoothStatus = await _checkBluetoothPermission();
    statuses.add(bluetoothStatus);

    // Location (while in use) permission
    final locationStatus = await _checkLocationPermission();
    statuses.add(locationStatus);

    // Location (always/background) permission
    final locationAlwaysStatus = await _checkLocationAlwaysPermission();
    statuses.add(locationAlwaysStatus);

    // Notification permission (Android 13+)
    if (Platform.isAndroid) {
      final notificationStatus = await _checkNotificationPermission();
      statuses.add(notificationStatus);
    }

    _permissionStatuses = statuses;
    _log.info(
        'Permission check complete: ${statuses.where((s) => s.isGranted).length}/${statuses.length} granted');
    notifyListeners();
  }

  /// Check Bluetooth permission group.
  Future<PermissionGroupStatus> _checkBluetoothPermission() async {
    final permissions = <ph.Permission>[];

    if (Platform.isAndroid) {
      permissions.addAll([
        ph.Permission.bluetoothScan,
        ph.Permission.bluetoothConnect,
      ]);
    }
    // On iOS, we use flutter_blue_plus adapter state instead of permission_handler
    // because permission_handler's Permission.bluetooth is unreliable on iOS

    _log.info('Checking Bluetooth permissions: $permissions');

    // On iOS, check adapter state directly
    if (Platform.isIOS) {
      try {
        final adapterState = await FlutterBluePlus.adapterState.first;
        _log.info('iOS Bluetooth adapter state: $adapterState');

        // If adapter is on, permission is granted
        if (adapterState == BluetoothAdapterState.on) {
          return const PermissionGroupStatus(
            name: 'permissionBluetooth',
            description: 'permissionBluetoothDesc',
            permissions: [],
            status: PermissionStatusType.granted,
          );
        } else if (adapterState == BluetoothAdapterState.unauthorized) {
          return const PermissionGroupStatus(
            name: 'permissionBluetooth',
            description: 'permissionBluetoothDesc',
            permissions: [],
            status: PermissionStatusType.permanentlyDenied,
          );
        } else {
          // Adapter is off or unknown - permission might be granted but bluetooth is off
          // We can't determine permission status, so assume granted
          return const PermissionGroupStatus(
            name: 'permissionBluetooth',
            description: 'permissionBluetoothDesc',
            permissions: [],
            status: PermissionStatusType.granted,
          );
        }
      } catch (e) {
        _log.warning('Failed to check iOS Bluetooth adapter state: $e');
        // If we can't check, assume granted since bluetooth might already be working
        return const PermissionGroupStatus(
          name: 'permissionBluetooth',
          description: 'permissionBluetoothDesc',
          permissions: [],
          status: PermissionStatusType.granted,
        );
      }
    }

    // Android: check each permission with detailed logging
    for (final perm in permissions) {
      try {
        final status = await perm.status;
        _log.info('Bluetooth permission $perm raw status: $status (value: ${status.index})');
      } catch (e) {
        _log.warning('Bluetooth permission $perm check failed: $e');
      }
    }

    return await _checkPermissionGroup(
      permissions: permissions,
      name: 'permissionBluetooth',
      description: 'permissionBluetoothDesc',
    );
  }

  /// Check Location (while in use) permission.
  Future<PermissionGroupStatus> _checkLocationPermission() async {
    // Use geolocator for accurate location permission status
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        final permission = await Geolocator.checkPermission();
        _log.info('Geolocator permission status: $permission');

        // LocationPermission values:
        // denied, deniedForever, whileInUse, always, unableToDetermine
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          return const PermissionGroupStatus(
            name: 'permissionLocation',
            description: 'permissionLocationDesc',
            permissions: [],
            status: PermissionStatusType.granted,
          );
        } else if (permission == LocationPermission.deniedForever) {
          return const PermissionGroupStatus(
            name: 'permissionLocation',
            description: 'permissionLocationDesc',
            permissions: [],
            status: PermissionStatusType.permanentlyDenied,
          );
        } else {
          return const PermissionGroupStatus(
            name: 'permissionLocation',
            description: 'permissionLocationDesc',
            permissions: [],
            status: PermissionStatusType.denied,
          );
        }
      } catch (e) {
        _log.warning('Failed to check location permission via geolocator: $e');
        // Fall back to permission_handler
        return await _checkPermissionGroup(
          permissions: [ph.Permission.locationWhenInUse],
          name: 'permissionLocation',
          description: 'permissionLocationDesc',
        );
      }
    }

    return await _checkPermissionGroup(
      permissions: [ph.Permission.locationWhenInUse],
      name: 'permissionLocation',
      description: 'permissionLocationDesc',
    );
  }

  /// Check Location (always) permission.
  Future<PermissionGroupStatus> _checkLocationAlwaysPermission() async {
    // Use geolocator for accurate location permission status
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        final permission = await Geolocator.checkPermission();
        _log.info('Geolocator always permission status: $permission');

        if (permission == LocationPermission.always) {
          return const PermissionGroupStatus(
            name: 'permissionLocationAlways',
            description: 'permissionLocationAlwaysDesc',
            permissions: [],
            status: PermissionStatusType.granted,
          );
        } else if (permission == LocationPermission.deniedForever) {
          return const PermissionGroupStatus(
            name: 'permissionLocationAlways',
            description: 'permissionLocationAlwaysDesc',
            permissions: [],
            status: PermissionStatusType.permanentlyDenied,
          );
        } else {
          // whileInUse or denied - need to request always permission
          return const PermissionGroupStatus(
            name: 'permissionLocationAlways',
            description: 'permissionLocationAlwaysDesc',
            permissions: [],
            status: PermissionStatusType.denied,
          );
        }
      } catch (e) {
        _log.warning('Failed to check location always permission via geolocator: $e');
        // Fall back to permission_handler
        return await _checkPermissionGroup(
          permissions: [ph.Permission.locationAlways],
          name: 'permissionLocationAlways',
          description: 'permissionLocationAlwaysDesc',
        );
      }
    }

    return await _checkPermissionGroup(
      permissions: [ph.Permission.locationAlways],
      name: 'permissionLocationAlways',
      description: 'permissionLocationAlwaysDesc',
    );
  }

  /// Check Notification permission.
  Future<PermissionGroupStatus> _checkNotificationPermission() async {
    return await _checkPermissionGroup(
      permissions: [ph.Permission.notification],
      name: 'permissionNotification',
      description: 'permissionNotificationDesc',
    );
  }

  /// Check a group of permissions and return combined status.
  Future<PermissionGroupStatus> _checkPermissionGroup({
    required List<ph.Permission> permissions,
    required String name,
    required String description,
  }) async {
    if (permissions.isEmpty) {
      return PermissionGroupStatus(
        name: name,
        description: description,
        permissions: [],
        status: PermissionStatusType.granted,
      );
    }

    bool allGranted = true;
    bool anyPermanentlyDenied = false;
    ph.Permission? deniedPerm;

    for (final permission in permissions) {
      final status = await _getPermissionStatus(permission);

      if (status == PermissionStatusType.granted) {
        continue;
      } else if (status == PermissionStatusType.permanentlyDenied) {
        allGranted = false;
        anyPermanentlyDenied = true;
        deniedPerm = permission;
        break; // Permanently denied is the most severe
      } else {
        allGranted = false;
        deniedPerm ??= permission;
      }
    }

    return PermissionGroupStatus(
      name: name,
      description: description,
      permissions: permissions,
      status: allGranted
          ? PermissionStatusType.granted
          : anyPermanentlyDenied
              ? PermissionStatusType.permanentlyDenied
              : PermissionStatusType.denied,
      deniedPermission: deniedPerm,
    );
  }

  /// Get status of a single permission.
  Future<PermissionStatusType> _getPermissionStatus(
      ph.Permission permission) async {
    try {
      final status = await permission.status;
      _log.info('Permission $permission status: $status (index: ${status.index})');

      // PermissionStatus values:
      // 0 = denied, 1 = granted, 2 = restricted, 3 = limited, 4 = permanentlyDenied, 5 = provisional
      if (status == ph.PermissionStatus.granted ||
          status == ph.PermissionStatus.limited) {
        return PermissionStatusType.granted;
      } else if (status == ph.PermissionStatus.permanentlyDenied) {
        return PermissionStatusType.permanentlyDenied;
      } else if (status == ph.PermissionStatus.restricted) {
        // Restricted on iOS usually means parental controls, treat as granted for our purposes
        _log.info('Permission $permission is restricted, treating as granted');
        return PermissionStatusType.granted;
      } else {
        return PermissionStatusType.denied;
      }
    } catch (e) {
      _log.warning('Failed to check permission $permission: $e');
      // If permission check throws, it might mean the permission doesn't apply
      // on this platform/version - treat as granted
      return PermissionStatusType.granted;
    }
  }

  /// Request a permission group.
  Future<bool> requestPermission(PermissionGroupStatus groupStatus) async {
    _log.info('Requesting permissions: ${groupStatus.name}');

    // On iOS, Bluetooth permission can only be requested by trying to use Bluetooth
    if (Platform.isIOS && groupStatus.name == 'permissionBluetooth') {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        _log.warning('Failed to request Bluetooth permission on iOS: $e');
      }
      await checkAllPermissions();
      return allGranted;
    }

    // Use geolocator for location permissions
    if (groupStatus.name == 'permissionLocation' ||
        groupStatus.name == 'permissionLocationAlways') {
      try {
        final currentPermission = await Geolocator.checkPermission();

        // For "always" permission, directly open settings
        // iOS requires user to manually change to "always" in settings
        if (groupStatus.name == 'permissionLocationAlways') {
          if (currentPermission == LocationPermission.whileInUse) {
            // User has "while in use", need to go to settings to enable "always"
            _log.info('User has whileInUse, opening settings for always permission');
            await ph.openAppSettings();
            return false; // Will be updated when user returns
          } else if (currentPermission == LocationPermission.deniedForever) {
            // Permanently denied, must go to settings
            await ph.openAppSettings();
            return false;
          }
        }

        // For "while in use" permission or first-time request
        if (currentPermission == LocationPermission.denied) {
          final newPermission = await Geolocator.requestPermission();
          _log.info('Geolocator request permission result: $newPermission');

          // If still denied or got whileInUse but we need always, open settings
          if (groupStatus.name == 'permissionLocationAlways' &&
              newPermission == LocationPermission.whileInUse) {
            await ph.openAppSettings();
            return false;
          }
        } else if (currentPermission == LocationPermission.deniedForever) {
          // Permanently denied, must go to settings
          await ph.openAppSettings();
          return false;
        }
      } catch (e) {
        _log.warning('Failed to request location permission via geolocator: $e');
      }
      await checkAllPermissions();
      return allGranted;
    }

    // For notification permission, use permission_handler
    for (final permission in groupStatus.permissions) {
      try {
        final result = await permission.request();
        _log.info('Permission $permission request result: $result');
      } catch (e) {
        _log.warning('Failed to request permission $permission: $e');
      }
    }

    await checkAllPermissions();
    return allGranted;
  }

  /// Open system settings for permanently denied permissions.
  Future<bool> openSettings() async {
    _log.info('Opening app settings...');
    return await ph.openAppSettings();
  }

  /// Refresh permission status when app resumes.
  Future<void> refreshOnResume() async {
    if (!_isInitialized) return;
    await checkAllPermissions();
  }
}

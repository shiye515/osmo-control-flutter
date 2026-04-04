import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

/// Background service for maintaining GPS and BLE activity when screen is locked.
class BackgroundServiceManager {
  static final _log = Logger('BackgroundServiceManager');

  static const String _notificationChannelId = 'osmo_control_background';
  static const int _notificationId = 888;

  static BackgroundServiceManager? _instance;
  static BackgroundServiceManager get instance => _instance ??= BackgroundServiceManager._();

  BackgroundServiceManager._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the background service.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeNotifications();

    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        foregroundServiceNotificationId: _notificationId,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Osmo 遥控器',
        initialNotificationContent: '正在获取位置...',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );

    _isInitialized = true;
    _log.info('Background service initialized');
  }

  /// Initialize local notifications.
  Future<void> _initializeNotifications() async {
    const channel = AndroidNotificationChannel(
      _notificationChannelId,
      '后台位置服务',
      description: '显示后台服务运行状态',
      importance: Importance.low,
    );

    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  /// Start the background service.
  Future<void> start() async {
    if (!_isInitialized) {
      await initialize();
    }

    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
      _log.info('Background service started');
    }
  }

  /// Stop the background service.
  Future<void> stop() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stop');
      _log.info('Background service stopped');
    }
  }

  /// Check if the background service is running.
  Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  /// Update notification content.
  void updateNotification({required String title, required String content}) {
    final service = FlutterBackgroundService();
    service.invoke('updateNotification', {
      'title': title,
      'content': content,
    });
  }

  /// Background service entry point for Android.
  @pragma('vm:entry-point')
  static Future<void> _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // Initialize location stream
    StreamSubscription<Position>? positionSubscription;

    service.on('stop').listen((event) {
      positionSubscription?.cancel();
      service.stopSelf();
    });

    service.on('updateNotification').listen((event) {
      if (event is Map) {
        FlutterBackgroundService().invoke('setAsForeground');
      }
    });

    // Start location stream in background
    if (await Geolocator.isLocationServiceEnabled()) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        positionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        ).listen((Position position) {
          // Broadcast position via service
          service.invoke('positionUpdate', {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'altitude': position.altitude,
            'accuracy': position.accuracy,
            'speed': position.speed,
            'timestamp': position.timestamp.toIso8601String(),
          });
        });
      }
    }

    // Keep service running
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }
  }

  /// Background handler for iOS.
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    return true;
  }
}
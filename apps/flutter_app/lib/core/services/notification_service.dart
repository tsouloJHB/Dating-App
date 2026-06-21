import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _notificationsEnabledPrefKey = 'notifications_enabled';

abstract class NotificationService {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<bool> isEnabled();

  Future<bool> setEnabled(bool enabled);

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String? payload,
  });
}

class NotificationServiceImpl implements NotificationService {
  static final NotificationServiceImpl _instance = NotificationServiceImpl._internal();

  factory NotificationServiceImpl() {
    return _instance;
  }

  NotificationServiceImpl._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    _isInitialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (!_isInitialized) {
      await initialize();
    }

    final ios = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  @override
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledPrefKey) ?? false;
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (!enabled) {
      await prefs.setBool(_notificationsEnabledPrefKey, false);
      return false;
    }

    final granted = await requestPermission();
    await prefs.setBool(_notificationsEnabledPrefKey, granted);
    return granted;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'justhookups_channel',
      'CasualMeets Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      // Navigate or perform action based on payload
    }
  }
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      // iOS/macOS can be added later if you need.
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    _initialized = true;
  }

  Future<bool> requestPermissionIfNeeded() async {
    // Android 13+ needs runtime permission; plugin exposes it as below.
    if (!kIsWeb && Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? granted =
            await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }
    // Web or older Android don't need permission here.
    return true;
  }

  Future<void> showSimple({
    int id = 0,
    String title = 'Notifications Enabled',
    String body = 'You will now receive parking updates.',
  }) async {
    await init();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'parking_updates',
      'Parking Updates',
      channelDescription: 'General updates and reminders about parking.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  // Fetch notifications from backend
  Future<List<Map<String, dynamic>>> fetchNotifications(String token,
      {bool showUnreadLocally = true}) async {
    try {
      final response = await ApiService.getList('notifications/fetch', token);
      final notifications = response
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      // Optionally show unread notifications locally
      if (showUnreadLocally) {
        for (var n in notifications.where((n) => n['status'] == 'unread')) {
          final notifId = n['notification_id'] is int
              ? n['notification_id']
              : int.tryParse(n['notification_id']?.toString() ?? '0') ?? 0;

          await showSimple(
            id: notifId,
            title: n['type']?.toString().toUpperCase() ?? 'Notification',
            body: n['message'] ?? '',
          );
        }
      }

      return notifications;
    } catch (e) {
      if (kDebugMode) print('Fetch notifications error: $e');
      rethrow;
    }
  }

  // Mark one notification as read
  Future<void> markAsRead(int id, String token) async {
    try {
      await ApiService.postWithToken('notifications/$id/read', {}, token);
    } catch (e) {
      if (kDebugMode) print('Mark as read error: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String token) async {
    try {
      await ApiService.postWithToken('notifications/read-all', {}, token);
    } catch (e) {
      if (kDebugMode) print('Mark all as read error: $e');
      rethrow;
    }
  }
}

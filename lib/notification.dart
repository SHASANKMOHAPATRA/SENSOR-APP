import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifierhelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );
      await _notification.initialize(initSettings);
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  static Future<void> pushNotification(
      {required String title, required String body}) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails('important_channel', "My Channel",
              importance: Importance.max, priority: Priority.max);

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );
      await _notification.show(0, title, body, notificationDetails);
    } catch (e) {
      print('Failed to push notification: $e');
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart'; // For Navigator and MaterialPageRoute
import 'package:medicineproject/screens/reminder.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future<void> init(BuildContext context) async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iOS = DarwinInitializationSettings();

  await _notification.initialize(
    const InitializationSettings(android: android, iOS: iOS),
    onDidReceiveNotificationResponse: (details) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReminderPage()),
      );
    },
  );

  tz.initializeTimeZones();
}

  static scheduleNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'important_notifications',
      'My Channel',

      importance: Importance.max,
      priority: Priority.high,
    );

    var iosDetails = DarwinNotificationDetails();

    var notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails
    );

    await _notification.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // do notification even in idle stage
      androidScheduleMode:
          AndroidScheduleMode
              .exactAllowWhileIdle, // do notification even in idle stage
    );
  }
  
}

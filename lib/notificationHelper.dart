// --- CORRECTED notificationHelper.dart with Exact Alarm Request ---

import 'package:flutter/material.dart'; // For BuildContext, TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicineproject/screens/reminder.dart'; // Assuming this screen exists for navigation
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  // --- Initialization ---
  static Future<void> init(BuildContext context) async {
    print("NotificationHelper: Initializing...");
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    tz.initializeTimeZones();
    // Optional: tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    await _notification.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification tapped with payload: ${response.payload}");
        try {
           Navigator.of(context).push(
             MaterialPageRoute(builder: (_) => const ReminderPage()),
           );
        } catch (e) {
           print("Error navigating from notification tap: $e");
        }
      },
    );

    // Request Permissions explicitly
    await _requestPermissions(); // Calls the updated method below
    print("NotificationHelper: Initialization complete.");
  }

  // --- Request Permissions (Now includes Exact Alarm) ---
  static Future<void> _requestPermissions() async {
    // Android Notification Permissions (Android 13+)
    final androidPlugin = _notification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Request standard notification permission first
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      print("Android Notification Permission Granted: $granted");

      // --- ADD THIS REQUEST for Android 12+ ---
      // Request exact alarm permission (requires manifest permission)
      final bool? exactGranted = await androidPlugin.requestExactAlarmsPermission();
      print("Android Exact Alarm Permission Granted: $exactGranted");
      // Note: This might open system settings for the user to grant it manually.
      // --- End Exact Alarm Request ---

    }

    // iOS Notification Permissions
    final iOSPlugin = _notification.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iOSPlugin != null) {
      final bool? granted = await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
       print("iOS Notification Permission Granted: $granted");
    }
  }


  // --- Schedule a Single Medicine Dose Notification (Keep as is) ---
  static Future<void> scheduleSingleMedicineNotification({
    required int notificationId,
    required String medicineName,
    required String quantity, // Make sure this matches Medicine model type if changed
    required TimeOfDay time,
  }) async {
      final tz.TZDateTime scheduledDateTime = _nextInstanceOfTime(time);
      const androidDetails = AndroidNotificationDetails(
          'medicine_channel_id_01','Medicine Reminders',
          channelDescription: 'Channel for medicine reminder notifications',
          importance: Importance.max, priority: Priority.high, ticker: 'Medicine Reminder');
      const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
      const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      try {
          print('Scheduling notification ID $notificationId for "$medicineName" (Qty: $quantity) at $scheduledDateTime (local time: ${scheduledDateTime.toLocal()})');
          await _notification.zonedSchedule(
              notificationId, 'Medication Reminder', 'Time to take $quantity of $medicineName.',
              scheduledDateTime, notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time);
           print("Successfully scheduled notification ID: $notificationId");
      } catch (e) {
          print("Error scheduling notification ID $notificationId: $e");
      }
  }

  // --- Helper function _nextInstanceOfTime (Keep as is) ---
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
      // Try using explicit timezone for robustness
      tz.Location location;
      try {
           location = tz.getLocation('Asia/Bangkok'); // Use your specific timezone
      } catch (e) {
          print("Error getting location 'Asia/Bangkok', falling back to local. Error: $e");
          location = tz.local; // Fallback to local if specific one fails
      }

      final tz.TZDateTime now = tz.TZDateTime.now(location);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
          location, now.year, now.month, now.day, time.hour, time.minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
  }

  // --- cancelNotification (Keep as is) ---
  static Future<void> cancelNotification(int notificationId) async {
    // ... (implementation from previous step) ...
    try { await _notification.cancel(notificationId); print('Cancelled notification ID $notificationId'); } catch(e) { print("Error cancelling notification ID $notificationId: $e");}
  }

   // --- cancelAllNotifications (Keep as is) ---
  static Future<void> cancelAllNotifications() async {
    // ... (implementation from previous step) ...
    try { await _notification.cancelAll(); print('Cancelled all notifications.'); } catch(e) { print("Error cancelling all notifications: $e"); }
  }

} // End of NotificationHelper class
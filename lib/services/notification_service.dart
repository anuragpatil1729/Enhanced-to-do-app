import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/todo.dart';
import '../utils/enums.dart' hide Priority;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
    tz.initializeTimeZones();
  }

  static Future<void> scheduleNotification(Todo todo) async {
    if (todo.dueDate == null) return;

    final scheduledTime = _getScheduledTime(todo.dueDate!, todo.reminder);

    // Check if the scheduled time is in the future
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetails = AndroidNotificationDetails(
      'todo_due_date',
      'Todo Due Dates',
      channelDescription: 'Notifications for task due dates',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      todo.id.hashCode,
      'Task Due Soon!',
      todo.title,
      scheduledTime,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> cancelNotification(String todoId) async {
    await _notifications.cancel(todoId.hashCode);
  }

  static tz.TZDateTime _getScheduledTime(DateTime dueDate, Reminder reminder) {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dueDate, tz.local);
    switch (reminder) {
      case Reminder.atTime:
        return scheduledDate;
      case Reminder.fiveMin:
        return scheduledDate.subtract(const Duration(minutes: 5));
      case Reminder.fifteenMin:
        return scheduledDate.subtract(const Duration(minutes: 15));
      case Reminder.oneHour:
        return scheduledDate.subtract(const Duration(hours: 1));
      case Reminder.oneDay:
        return scheduledDate.subtract(const Duration(days: 1));
    }
  }
}

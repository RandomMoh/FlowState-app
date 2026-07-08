import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS initialization is skipped for now, focusing on Android
    const initSettings = InitializationSettings(android: androidInit);
    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> showTimerNotification(int durationInSeconds) async {
    final endTime = DateTime.now().add(Duration(seconds: durationInSeconds));

    final androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Focus Timer',
      channelDescription: 'Ongoing focus timer',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      usesChronometer: true,
      chronometerCountDown: true,
      when: endTime.millisecondsSinceEpoch,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 0,
      title: 'Deep Focus',
      body: 'Timer running...',
      notificationDetails: details,
    );
  }

  Future<void> cancelTimerNotification() async {
    await _notificationsPlugin.cancel(id: 0);
  }

  Future<void> showCompletionNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'completion_channel',
      'Focus Complete',
      channelDescription: 'Alerts when focus session finishes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 1,
      title: 'Focus Complete',
      body: 'Great job! Take a short break.',
      notificationDetails: details,
    );
  }
}

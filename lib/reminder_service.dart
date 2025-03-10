import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class ReminderService {
  ReminderService();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Timer? _reminderTimer;

  // Reminder settings
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  Duration _frequency = const Duration(hours: 1);
  String _message = 'Time to break!';
  bool _workdayOnly = false;
  bool _timeRangeEnabled = true;

  Future<void> initialize() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();
    const macOSSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: macOSSettings,
    );
    await _notifications.initialize(initializationSettings);
  }

  void setMessage(String message) {
    _message = message.isNotEmpty ? message : 'Time to break!';
    _restartTimer();
  }

  void setWorkdayOnly(bool workdayOnly) {
    _workdayOnly = workdayOnly;
    _restartTimer();
  }

  void setTimeRangeEnabled(bool enabled) {
    _timeRangeEnabled = enabled;
    _restartTimer();
  }

  void setTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    _startTime = startTime;
    _endTime = endTime;
    _restartTimer();
  }

  void setReminderTime(TimeOfDay time) {
    _reminderTime = time;
    _restartTimer();
  }

  void setFrequency(Duration frequency) {
    _frequency = frequency;
    _restartTimer();
  }

  bool _isWithinActiveHours() {
    final now = DateTime.now();
    final currentTimeOfDay = TimeOfDay.fromDateTime(now);

    if (_workdayOnly &&
        (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)) {
      return false;
    }

    if (!_timeRangeEnabled) {
      final reminderMinutes = _reminderTime.hour * 60 + _reminderTime.minute;
      final currentMinutes =
          currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;
      return currentMinutes >= reminderMinutes;
    }

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final currentMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  void startReminders() {
    stopReminders();
    _scheduleReminder();
  }

  void stopReminders() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  void _scheduleReminder() {

    // Schedule next reminder
    _reminderTimer = Timer.periodic(_frequency, (timer) {
      if (_isWithinActiveHours()) {
        _showNotification();
      }
    });
  }

  Future<void> _showNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Periodic reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const osxPlatformChannelSpecifics = DarwinNotificationDetails();
    const linuxPlatformChannelSpecifics = LinuxNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: osxPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notifications.show(
      0,
      'Reminder',
      _message,
      platformChannelSpecifics,
    );
  }

  void dispose() {
    stopReminders();
  }

  void _restartTimer() {
    if (_reminderTimer != null) {
      startReminders();
    }
  }
}

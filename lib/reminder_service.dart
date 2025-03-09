import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';  // 添加这行导入

class ReminderService {
  ReminderService();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  // final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _reminderTimer;

  // Reminder settings
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  Duration _frequency = const Duration(hours: 1);
  String _message = 'Time to break!';
  bool _workdayOnly = false;

  void setMessage(String message) {
    _message = message.isNotEmpty ? message : 'Time to break!';
  }

  void setWorkdayOnly(bool workdayOnly) {
    _workdayOnly = workdayOnly;
    _restartTimer();
  }

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const macOSSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macOSSettings,
      ),
    );

    // Initialize audio player and load the notification sound
    try {
      // await _audioPlayer.setAsset('assets/notification.mp3');
    } catch (e) {
      debugPrint('Error loading audio asset: $e');
      // Continue execution even if audio fails to load
    }
  }

  void setTimeRange(TimeOfDay start, TimeOfDay end) {
    _startTime = start;
    _endTime = end;
    _restartTimer();
  }

  void setFrequency(Duration frequency) {
    _frequency = frequency;
    _restartTimer();
  }

  bool _isWithinActiveHours() {
    final now = DateTime.now();
    final currentTimeOfDay = TimeOfDay.fromDateTime(now);
    final currentMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    
    if (_workdayOnly && (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)) {
      return false;
    }
    
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Periodic reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const osxDetails = DarwinNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();

    await _notifications.show(
      0,
      'Reminder',
      _message,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: osxDetails,
        linux: linuxDetails,
      ),
    );

    // // Play notification sound
    // try {
    //   await _audioPlayer.seek(Duration.zero); // Reset to beginning
    //   await _audioPlayer.play();
    // } catch (e) {
    //   debugPrint('Error playing notification sound: $e');
    // }
  }

  void startReminders() {
    _stopTimer();
    debugPrint("start timer {$_frequency}");
    _reminderTimer = Timer.periodic(_frequency, (timer) {
      if (_isWithinActiveHours()) {
        _showNotification();
      }
    });
  }

  void stopReminders() {
    _stopTimer();
  }

  void _restartTimer() {
    if (_reminderTimer?.isActive ?? false) {
      startReminders();
    }
  }

  void _stopTimer() {
    debugPrint('stop timer');
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  void dispose() {
    _stopTimer();
    // _audioPlayer.dispose();
  }
}
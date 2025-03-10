import 'package:flutter/material.dart';

class ReminderEvent {
  final String id;
  final String message;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TimeOfDay reminderTime;
  final int frequencyMinutes;
  final bool isActive;
  final bool workdayOnly;
  final bool timeRangeEnabled;

  ReminderEvent({
    required this.id,
    required this.message,
    required this.startTime,
    required this.endTime,
    required this.reminderTime,
    required this.frequencyMinutes,
    required this.isActive,
    required this.workdayOnly,
    required this.timeRangeEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'reminderTime': {'hour': reminderTime.hour, 'minute': reminderTime.minute},
      'frequencyMinutes': frequencyMinutes,
      'isActive': isActive,
      'workdayOnly': workdayOnly,
      'timeRangeEnabled': timeRangeEnabled,
    };
  }

  factory ReminderEvent.fromJson(Map<String, dynamic> json) {
    return ReminderEvent(
      id: json['id'],
      message: json['message'],
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      reminderTime: TimeOfDay(
        hour: json['reminderTime']['hour'],
        minute: json['reminderTime']['minute'],
      ),
      frequencyMinutes: json['frequencyMinutes'],
      isActive: json['isActive'],
      workdayOnly: json['workdayOnly'],
      timeRangeEnabled: json['timeRangeEnabled'],
    );
  }

  ReminderEvent copyWith({
    String? id,
    String? message,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    TimeOfDay? reminderTime,
    int? frequencyMinutes,
    bool? isActive,
    bool? workdayOnly,
    bool? timeRangeEnabled,
  }) {
    return ReminderEvent(
      id: id ?? this.id,
      message: message ?? this.message,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminderTime: reminderTime ?? this.reminderTime,
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      isActive: isActive ?? this.isActive,
      workdayOnly: workdayOnly ?? this.workdayOnly,
      timeRangeEnabled: timeRangeEnabled ?? this.timeRangeEnabled,
    );
  }
}
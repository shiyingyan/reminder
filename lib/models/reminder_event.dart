import 'package:flutter/material.dart';
import 'dart:convert';

class ReminderEvent {
  final String id;
  final String message;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int frequencyMinutes;
  final bool isActive;
  final bool workdayOnly;

  ReminderEvent({
    required this.id,
    required this.message,
    required this.startTime,
    required this.endTime,
    required this.frequencyMinutes,
    this.isActive = true,
    this.workdayOnly = false,
  });

  // Convert TimeOfDay to a format that can be stored
  Map<String, dynamic> _timeOfDayToJson(TimeOfDay time) {
    return {
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  // Convert stored format back to TimeOfDay
  static TimeOfDay _timeOfDayFromJson(Map<String, dynamic> json) {
    return TimeOfDay(hour: json['hour'], minute: json['minute']);
  }

  // Convert ReminderEvent to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'startTime': _timeOfDayToJson(startTime),
      'endTime': _timeOfDayToJson(endTime),
      'frequencyMinutes': frequencyMinutes,
      'isActive': isActive,
      'workdayOnly': workdayOnly,
    };
  }

  // Create ReminderEvent from JSON data
  factory ReminderEvent.fromJson(Map<String, dynamic> json) {
    return ReminderEvent(
      id: json['id'],
      message: json['message'],
      startTime: _timeOfDayFromJson(json['startTime']),
      endTime: _timeOfDayFromJson(json['endTime']),
      frequencyMinutes: json['frequencyMinutes'],
      isActive: json['isActive'],
      workdayOnly: json['workdayOnly'] ?? false,
    );
  }

  // Create a copy of the event with some fields updated
  ReminderEvent copyWith({
    String? id,
    String? message,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? frequencyMinutes,
    bool? isActive,
    bool? workdayOnly,
  }) {
    return ReminderEvent(
      id: id ?? this.id,
      message: message ?? this.message,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      isActive: isActive ?? this.isActive,
      workdayOnly: workdayOnly ?? this.workdayOnly,
    );
  }
}
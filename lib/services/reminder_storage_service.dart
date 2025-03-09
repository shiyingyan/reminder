import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_event.dart';

class ReminderStorageService {
  static const String _storageKey = 'reminder_events';
  static final ReminderStorageService _instance = ReminderStorageService._internal();
  factory ReminderStorageService() => _instance;
  ReminderStorageService._internal();

  Future<List<ReminderEvent>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString(_storageKey);
    if (eventsJson == null) return [];

    final List<dynamic> jsonList = json.decode(eventsJson);
    return jsonList.map((json) => ReminderEvent.fromJson(json)).toList();
  }

  Future<void> saveEvents(List<ReminderEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsJson = json.encode(
      events.map((event) => event.toJson()).toList(),
    );
    await prefs.setString(_storageKey, eventsJson);
  }

  Future<void> addEvent(ReminderEvent event) async {
    final events = await loadEvents();
    events.add(event);
    await saveEvents(events);
  }

  Future<void> updateEvent(ReminderEvent event) async {
    final events = await loadEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final events = await loadEvents();
    events.removeWhere((event) => event.id == eventId);
    await saveEvents(events);
  }
}
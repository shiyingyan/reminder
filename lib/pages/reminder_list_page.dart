import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_event.dart';
import '../services/reminder_storage_service.dart';
import '../reminder_service.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  final ReminderStorageService _storageService = ReminderStorageService();
  final ReminderService _reminderService = ReminderService();
  List<ReminderEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _initializeActiveReminders();
  }

  Future<void> _loadEvents() async {
    final events = await _storageService.loadEvents();
    setState(() {
      _events = events;
    });
  }

  Future<void> _initializeActiveReminders() async {
    final events = await _storageService.loadEvents();
    for (final event in events) {
      if (event.isActive) {
        _reminderService.setMessage(event.message);
        _reminderService.setTimeRange(
          event.startTime,
          event.endTime,
        );
        _reminderService.setFrequency(
          Duration(minutes: event.frequencyMinutes),
        );
        _reminderService.startReminders();
      }
    }
  }

  Future<void> _addNewEvent() async {
    final event = await Navigator.push<ReminderEvent>(
      context,
      MaterialPageRoute(builder: (context) => const ReminderEditPage()),
    );

    if (event != null) {
      await _storageService.addEvent(event);
      await _loadEvents();
    }
  }

  Future<void> _toggleEventActive(ReminderEvent event) async {
    final updatedEvent = event.copyWith(isActive: !event.isActive);
    await _storageService.updateEvent(updatedEvent);

    if (updatedEvent.isActive) {
      _reminderService.setMessage(updatedEvent.message);
      _reminderService.setTimeRange(
        updatedEvent.startTime,
        updatedEvent.endTime,
      );
      _reminderService.setFrequency(
        Duration(minutes: updatedEvent.frequencyMinutes),
      );
      _reminderService.startReminders();
    } else {
      _reminderService.stopReminders();
    }

    await _loadEvents();
  }

  Future<void> _editEvent(ReminderEvent event) async {
    final updatedEvent = await Navigator.push<ReminderEvent>(
      context,
      MaterialPageRoute(builder: (context) => ReminderEditPage(event: event)),
    );

    if (updatedEvent != null) {
      await _storageService.updateEvent(updatedEvent);
      await _loadEvents();
    }
  }

  Future<void> _deleteEvent(ReminderEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reminder'),
            content: const Text(
              'Are you sure you want to delete this reminder?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed ?? false) {
      await _storageService.deleteEvent(event.id);
      if (event.isActive) {
        _reminderService.stopReminders();
      }
      await _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(event.message),
              subtitle: Text(
                '${event.startTime.format(context)} - ${event.endTime.format(context)}\nFrequency: ${event.frequencyMinutes} minutes',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editEvent(event),
                  ),
                  Switch(
                    value: event.isActive,
                    onChanged: (value) => _toggleEventActive(event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteEvent(event),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReminderEditPage extends StatefulWidget {
  final ReminderEvent? event;

  const ReminderEditPage({super.key, this.event});

  @override
  State<ReminderEditPage> createState() => _ReminderEditPageState();
}

class _ReminderEditPageState extends State<ReminderEditPage> {
  final TextEditingController _messageController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  int _frequencyMinutes = 60;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _messageController.text = widget.event!.message;
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
      _frequencyMinutes = widget.event!.frequencyMinutes;
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _updateFrequency(int minutes) {
    setState(() {
      _frequencyMinutes = minutes;
    });
  }

  void _saveEvent() {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    final event = ReminderEvent(
      id: widget.event?.id ?? const Uuid().v4(),
      message: _messageController.text,
      startTime: _startTime,
      endTime: _endTime,
      frequencyMinutes: _frequencyMinutes,
    );

    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'New Reminder' : 'Edit Reminder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Reminder Message',
                hintText: 'Enter message (不能超过10个字符)',
                counterText: '${_messageController.text.length}/10',
                errorText:
                    _messageController.text.length > 10
                        ? 'Message too long'
                        : null,
              ),
              maxLength: 10,
            ),
            const SizedBox(height: 16),
            const Text(
              'Active Hours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _selectTime(true),
                  icon: const Icon(Icons.access_time),
                  label: Text('Start: ${_startTime.format(context)}'),
                ),
                TextButton.icon(
                  onPressed: () => _selectTime(false),
                  icon: const Icon(Icons.access_time),
                  label: Text('End: ${_endTime.format(context)}'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Reminder Frequency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _frequencyMinutes,
              items:
                  [1, 15, 30, 45, 60, 120]
                      .map(
                        (minutes) => DropdownMenuItem(
                          value: minutes,
                          child: Text(
                            'Every ${minutes >= 60 ? '${minutes ~/ 60} hour${minutes >= 120 ? 's' : ''}' : '$minutes minutes'}',
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  (value) => value != null ? _updateFrequency(value) : null,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveEvent,
        child: const Icon(Icons.save),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'pages/reminder_list_page.dart';
import 'reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final reminderService = ReminderService();
  await reminderService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const ReminderListPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ReminderService _reminderService = ReminderService();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  int _frequencyMinutes = 60;
  bool _isActive = false;
  final TextEditingController _messageController = TextEditingController();

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
      _reminderService.setTimeRange(_startTime, _endTime);
    }
  }

  void _updateFrequency(int minutes) {
    setState(() {
      _frequencyMinutes = minutes;
    });
    _reminderService.setFrequency(Duration(minutes: minutes));
  }

  void _toggleReminders() {
    setState(() {
      _isActive = !_isActive;
    });
    if (_isActive) {
      _reminderService.startReminders();
    } else {
      _reminderService.stopReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Hours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Reminder Message',
                hintText: 'Enter message (no more than 20 characters)',
                counterText: '${_messageController.text.length}/20',
                errorText:
                    _messageController.text.length > 20
                        ? 'Message too long'
                        : null,
              ),
              maxLength: 20,
              onChanged: (value) {
                setState(() {});
                if (value.length <= 10) {
                  _reminderService.setMessage(value);
                }
              },
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
                  [1, 5, 15, 30, 45, 60, 120]
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleReminders,
        icon: Icon(_isActive ? Icons.stop : Icons.play_arrow),
        label: Text(_isActive ? 'Stop' : 'Start'),
        backgroundColor: _isActive ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _reminderService.dispose();
    super.dispose();
  }
}

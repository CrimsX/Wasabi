import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showFloatingButton = false;

  // Update the _events map to use List<Event>
  final Map<DateTime, List<Event>> _events = {
    DateTime.utc(2024, 2, 20): [
      Event(name: 'Event 1', time: TimeOfDay(hour: 10, minute: 30)),
      Event(name: 'Event 2', time: TimeOfDay(hour: 14, minute: 45)),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20.0),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white),
            ),
            calendarStyle: CalendarStyle(
              defaultDecoration: BoxDecoration(shape: BoxShape.circle),
              weekendDecoration: BoxDecoration(shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _showFloatingButton = true;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() { _calendarFormat = format; });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => _getEventsForDay(day),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(date, events),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDay != null ? _getEventsForDay(_selectedDay!).length : 0,
              itemBuilder: (context, index) {
                if (_selectedDay != null) {
                  final events = _getEventsForDay(_selectedDay!);
                  final event = events[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.event, color: Colors.white), // Icon color changed to white
                      title: Text(
                        event.name,
                        style: TextStyle(color: Colors.white), // Text color changed to white
                      ),
                      subtitle: Text(
                        event.time?.format(context) ?? '',
                        style: TextStyle(color: Colors.white), // Text color changed to white
                      ), // Icon color changed to white
                    ),
                    color: Colors.green, // Add this to change the card's background color to ensure white text is visible
                  );
                } else {
                  return Container(); // No selected day
                }
              },
            ),
          ),

        ],
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showAddEventDialog(context),
        child: Icon(Icons.add, color: Colors.white)
      )
          : null,
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[_normalizeDateTime(day)] ?? [];
  }

  DateTime _normalizeDateTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.green[700]),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(color: Colors.white, fontSize: 12.0),
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddEventDialog(
        onSave: (String eventName, TimeOfDay? pickedTime, String shareToUser, String shareToServer) {
          if (eventName.isNotEmpty && pickedTime != null) {
            final selectedDayNormalized = _normalizeDateTime(_selectedDay ?? _focusedDay);
            if (_events[selectedDayNormalized] != null) {
              _events[selectedDayNormalized]!.add(Event(name: eventName, time: pickedTime));
            } else {
              _events[selectedDayNormalized] = [Event(name: eventName, time: pickedTime)];
            }
            setState(() {}); // Refresh UI to show new event
          }
        },
      ),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  final Function(String eventName, TimeOfDay? pickedTime, String shareToUser, String shareToServer) onSave;

  const AddEventDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController shareToUserController = TextEditingController();
  final TextEditingController shareToServerController = TextEditingController();
  TimeOfDay? pickedTime;

  void _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        pickedTime = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Event"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: eventNameController,
              decoration: InputDecoration(hintText: "Name of Event"),
            ),
            ListTile(
              title: Text("Time of Event: ${pickedTime?.format(context) ?? 'Not Set'}"),
              trailing: Icon(Icons.timer),
              onTap: _selectTime,
            ),
            TextField(
              controller: shareToUserController,
              decoration: InputDecoration(hintText: "Share to user (Optional)"),
            ),
            TextField(
              controller: shareToServerController,
              decoration: InputDecoration(hintText: "Share to server (Optional)"),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            widget.onSave(
              eventNameController.text,
              pickedTime,
              shareToUserController.text,
              shareToServerController.text,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class Event {
  final String name;
  final TimeOfDay? time;

  Event({required this.name, this.time});
}

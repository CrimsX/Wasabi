import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:client/services/network.dart';

class Event {
  final String name;
  final TimeOfDay? time;

  Event({required this.name, this.time});
}

class CalendarScreen extends StatefulWidget {
  String username = '';
  String serverIP = '';

  CalendarScreen({Key? key, required this.username, required this.serverIP}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();


}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showFloatingButton = false;
  IO.Socket? _socket;

  final Map<DateTime, List<CalendarEvent>> _events = {
    DateTime.utc(2024, 2, 20): [
      CalendarEvent(name: 'Event 1', time: TimeOfDay(hour: 10, minute: 30)),
      CalendarEvent(name: 'Event 2', time: TimeOfDay(hour: 14, minute: 45)),
    ],
  };


//  @override
//  void initState() {
 //   super.initState();
 //   initializeSocket();

  //  _socket!.on('eventsResponse', (events) {
   //   setState(() {
        // Update _events map with fetched events
  //      _updateEvents(events);
  //    });
  //  });
 // }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    print(widget.username);
    if (widget.serverIP == '') {
     // widget.serverIP = "https://wasabi-server.fly.dev/";
      widget.serverIP = "'http://192.168.56.1:3000";
    } //else {
     // widget.serverIP = "http://" + widget.serverIP + ":3000/";
    //}

    super.initState();

    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
    );

    _socket = NetworkService.instance.socket;
    initializeSocket();

    _socket!.emit('getEvents');

    _socket!.on('eventsResponse', (events) {
      setState(() {
        // Update _events map with fetched events
        _updateEvents(events);
        });
    });
  }






  void _updateEvents(List<dynamic> events) {
    _events.clear();
    for (var event in events) {
      DateTime eventDate = DateTime.parse(event['eventTIME']);
      if (_events[eventDate] == null) {
        _events[eventDate] = [];
      }
      _events[eventDate]!.add(CalendarEvent(name: event['eventNAME'], time: TimeOfDay.fromDateTime(eventDate)));
    }
  }

  void initializeSocket() {

    // Listen for socket connection successful
    _socket!.on('connect', (_) => print('Connected to the socket server'));

    // Listen for socket connection error
    _socket!.on('connect_error', (data) => print('Connection error: $data'));

    // Listen for socket connection timeout
    _socket!.on('connect_timeout', (data) => print('Connection timeout: $data'));

    // Listen for any errors
    _socket!.on('error', (data) => print('Error: $data'));

    // Listen for socket disconnection
    _socket!.on('disconnect', (_) => print('Disconnected from the socket server'));
  }

  // Create event
  void emitCreateEvent({required String eventName, required String eventTime, String? shareToUser, String? shareToServer}) {
    print('Emitting createEvent with name: $eventName, time: $eventTime');

      _socket!.emit('createEvent', {
        'eventName': eventName,
        'eventTime': eventTime,
        'userID': widget.username,
      });
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.close();
    super.dispose();
  }

  // M3


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
                setState(() {
                  _calendarFormat = format;
                });
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
              itemCount: _selectedDay != null ? _getEventsForDay(_selectedDay!)
                  .length : 0,
              itemBuilder: (context, index) {
                if (_selectedDay != null) {
                  final events = _getEventsForDay(_selectedDay!);
                  final event = events[index];
                  return Card(
                    margin: EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.event, color: Colors.white),
                      // Icon color changed to white
                      title: Text(
                        event.name,
                        style: TextStyle(color: Colors
                            .white), // Text color changed to white
                      ),
                      subtitle: Text(
                        event.time?.format(context) ?? '',
                        style: TextStyle(color: Colors
                            .white), // Text color changed to white
                      ), // Icon color changed to white
                    ),
                    color: Colors
                        .green, // Add this to change the card's background color to ensure white text is visible
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

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[_normalizeDateTime(day)]?.cast<CalendarEvent>() ?? [];
  }

  DateTime _normalizeDateTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle, color: Colors.green[700]),
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
    TextEditingController eventNameController = TextEditingController();
    TimeOfDay? pickedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) => AddEventDialog(
        onSaveEvent:(eventName, eventTime, shareToUser, shareToServer) {
          if (eventName.isNotEmpty && eventTime!= null) {
            print("1");
            final selectedDayNormalized = _normalizeDateTime(_selectedDay ?? _focusedDay);
            print("2");
            if (_events[selectedDayNormalized] != null) {
              _events[selectedDayNormalized]!.add(CalendarEvent(name: eventName, time: pickedTime));
              print("3");
            } else {
              emitCreateEvent(eventName: eventName, eventTime: eventTime, shareToUser: shareToUser, shareToServer: shareToServer);
              print("4");
            }
            setState(() {}); // Refresh UI to show new event
            print("5");
          }
          print('6');
        },
      ),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  final Function(String eventName, String eventTime, String? shareToUser, String? shareToServer) onSaveEvent;

  const AddEventDialog({Key? key, required this.onSaveEvent}) : super(key: key);

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
              title: Text(
                  "Time of Event: ${pickedTime?.format(context) ?? 'Not Set'}"),
              trailing: Icon(Icons.timer),
              onTap: _selectTime,
            ),
            TextField(
              controller: shareToUserController,
              decoration: InputDecoration(hintText: "Share to user (Optional)"),
            ),
            TextField(
              controller: shareToServerController,
              decoration: InputDecoration(
                  hintText: "Share to server (Optional)"),
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
            if (eventNameController.text.isNotEmpty && pickedTime != null) {
              // Format the time and call the onSaveEvent callback
              final DateTime now = DateTime.now();
              final DateTime eventDateTime = DateTime(now.year, now.month, now.day, pickedTime!.hour, pickedTime!.minute);
              final String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(eventDateTime);
              widget.onSaveEvent(eventNameController.text, formattedTime, shareToUserController.text, shareToServerController.text);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class CalendarEvent {
  final String name;
  final TimeOfDay? time;

  CalendarEvent({required this.name, this.time});
}
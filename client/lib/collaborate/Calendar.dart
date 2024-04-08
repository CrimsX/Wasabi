import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
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
  Socket? socket;

  CalendarScreen({Key? key, required this.username, required this.serverIP, required this.socket}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();


}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showFloatingButton = false;
  final List<dynamic> _friends = [];
  final List<dynamic>_groups = [];
  GlobalKey _calendarKey = GlobalKey();


  final Map<DateTime, List<CalendarEvent>> _events = {
    DateTime.utc(2024, 2, 20): [
      CalendarEvent(name: 'Event 1', time: TimeOfDay(hour: 10, minute: 30)),
      CalendarEvent(name: 'Event 2', time: TimeOfDay(hour: 14, minute: 45)),
    ],
  };

  void _shareForm(event) {
    int selectedOption = 0; // Track the selected radio button option

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Would you like to share this event?"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RadioListTile(
                      title: Text('Share with friends'),
                      value: 0,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Share with group'),
                      value: 1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Don\'t share'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Next'),
                  onPressed: () {

                    Navigator.of(context).pop();
                    _shareSelect(selectedOption, event);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _shareSelect(option, event) {
    List<dynamic> items = [];
    String key = "";
    if (option == 0){
      items = _friends;
      key = 'FriendID';
    } else if (option == 1) {
      items = _groups;
      key = 'ServerName';
    }
    List<bool> checkedItems = List<bool>.filled(items.length, false); // Initialize with false values
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Items'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    items.length,
                        (index) {
                      return CheckboxListTile(
                        title: Text(items[index][key]),
                        value: checkedItems[index],
                        onChanged: (newValue) {
                          print('Checkbox $index tapped');
                          setState(() {
                            checkedItems[index] = newValue!;
                          });
                          print('Checkbox $index is now ${checkedItems[index]}');
                        },
                      );
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Perform actions based on the checked items
                    for (int i = 0; i < items.length; i++) {

                      if (checkedItems[i] && option == 0) {
                        print('Emitting shareEvent with data:');
                        print({
                          'user': _friends[i][key],
                          'eventname': event.name,
                          'eventTIME': event.time.toString(),
                          'userID': widget.username,
                        });
                        widget.socket!.emit('shareEvent', {
                          'user': _friends[i][key],
                          'eventname': event.name,
                          'eventTIME': event.time.toString(),
                          'userID': widget.username,
                        });
                      } else if (checkedItems[i] && option == 1) {
                        print('Emitting shareEventGroup with data:');
                        print({
                          'group': _groups[i][key],
                          'user': widget.username,
                          'eventname': event.name,
                          'eventTIME': event.time.toString(),
                        });
                        widget.socket!.emit('shareEventGroup', {
                          'group': _groups[i][key],
                          'user': widget.username,
                          'eventname': event.name,
                          'eventTIME': event.time.toString(),
                        });
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );
  }




  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    print(widget.username);

    super.initState();
    initializeSocket();
    /*
    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
    );

    _socket = NetworkService.instance.socket;
    */



    widget.socket!.emit('getEvents', widget.username);
    widget.socket!.on('eventResponse', (events) {
      print("Received events: $events"); // Log the received events
      if (mounted) {
        setState(() {
          // Update _events map with fetched events
          _updateEvents(events);
        });
      }
    });





    widget.socket!.on('eventCreated', (eventData) {
      print("New event created: $eventData");
      if (mounted) {
        setState(() {
          DateTime eventDateTimeUTC = DateTime.parse(eventData['eventTIME']);
          DateTime eventDateTimeAdjusted = eventDateTimeUTC.add(Duration(hours: 0)); // Add a fixed 0 hour offset
          DateTime eventDate = DateTime(eventDateTimeAdjusted.year, eventDateTimeAdjusted.month, eventDateTimeAdjusted.day);
          TimeOfDay eventTime = TimeOfDay(hour: eventDateTimeAdjusted.hour, minute: eventDateTimeAdjusted.minute);

          // Format the event time before adding it to _events
          String formattedEventTime = '${eventTime.hour}:${eventTime.minute}';

          var newEvent = CalendarEvent(name: eventData['eventNAME'], time: eventTime);

          DateTime normalizedEventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);

          if (_events.containsKey(normalizedEventDate)) {
            _events[normalizedEventDate]!.add(newEvent);
          } else {
            _events[normalizedEventDate] = [newEvent];
          }

          // Reset the GlobalKey to force the TableCalendar widget to rebuild
          _calendarKey = GlobalKey();

          print("setState is called! Events after update: $_events");
        });
      }
    });




  }









  void _updateEvents(List<dynamic> events) {
    // Clear existing events
    _events.clear();

    // Process each event received from the backend
    for (var event in events) {
      DateTime eventDateTimeUTC = DateTime.parse(event['eventTime']);
      DateTime eventDateTimeAdjusted = eventDateTimeUTC.add(Duration(hours: 0)); // Add a fixed 0 hour offset
      DateTime eventDate = DateTime(eventDateTimeAdjusted.year, eventDateTimeAdjusted.month, eventDateTimeAdjusted.day);
      TimeOfDay eventTime = TimeOfDay(hour: eventDateTimeAdjusted.hour, minute: eventDateTimeAdjusted.minute);

      _events.putIfAbsent(eventDate, () => []).add(CalendarEvent(name: event['eventName'], time: eventTime));
      print(eventDate);
    }

    // Trigger a UI refresh
    setState(() {});
  }



  void initializeSocket() {

    // Listen for socket connection successful
    widget.socket!.on('connect', (_) => print('Connected to the socket server'));

    // Listen for socket connection error
    widget.socket!.on('connect_error', (data) => print('Connection error: $data'));

    // Listen for socket connection timeout
    widget.socket!.on('connect_timeout', (data) => print('Connection timeout: $data'));

    // Listen for any errors
    widget.socket!.on('error', (data) => print('Error: $data'));

    // Listen for socket disconnection
    widget.socket!.on('disconnect', (_) => print('Disconnected from the socket server'));


    widget.socket!.emit('buildfriendscollab', widget.username);
    widget.socket!.emit('buildgroupscollab', widget.username);

    // Listen for responses to build friends collaboration
    widget.socket!.on('buildfriendscollab', (data) {
      if (mounted) {
        setState(() {
          _friends.addAll(data);
        });
      }
    });

    // Listen for responses to build groups collaboration
    widget.socket!.on('buildgroupscollab', (data) {
      if (mounted) {
        setState(() {
          _groups.addAll(data);
        });
      }
    });



  }


  void emitCreateEvent({required String eventName, required String eventTime}) {
    print('Emitting createEvent with name: $eventName, time: $eventTime');

    widget.socket!.emit('createEvent', {
      'eventName': eventName,
      'eventTime': eventTime,
      'userID': widget.username,
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          TableCalendar(
            key: _calendarKey, // edited
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2090, 3, 14),
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
              itemCount: _selectedDay != null ? _getEventsForDay(_selectedDay!).length : 0,
              itemBuilder: (context, index) {
                if (_selectedDay != null) {
                  final events = _getEventsForDay(_selectedDay!);
                  final event = events[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.event, color: Colors.white),
                      title: Text(
                        event.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        event.time?.format(context) ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.group_add_outlined, color: Colors.white),
                        onPressed: () => _shareForm(event),
                      ),
                    ),
                    color: Colors.green,
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
        selectedDay: _selectedDay ?? _focusedDay, // For selected day
        onSaveEvent: (eventName, eventTime) {
          if (eventName.isNotEmpty && eventTime != null) {
            final selectedDayNormalized =
            _normalizeDateTime(_selectedDay ?? _focusedDay);

            // Check if pickedTime is not null
            if (pickedTime != null) {
              // Add the event only if pickedTime is not null
              if (_events.containsKey(selectedDayNormalized)) {
                _events[selectedDayNormalized]!.add(
                    CalendarEvent(name: eventName, time: pickedTime));
              } else {
                _events[selectedDayNormalized] = [
                  CalendarEvent(name: eventName, time: pickedTime)
                ];
              }
            }

            // Move the emitCreateEvent call here
            emitCreateEvent(
                eventName: eventName,
                eventTime: eventTime);

          }
        },
      ),
    );
  }
}




class AddEventDialog extends StatefulWidget {
  final DateTime selectedDay;
  final Function(String eventName, String eventTime) onSaveEvent;

  const AddEventDialog({
    Key? key,
    required this.selectedDay,
    required this.onSaveEvent
  }) : super(key: key);



  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final TextEditingController eventNameController = TextEditingController();
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
              final eventDateTimeUTC = DateTime.utc(
                widget.selectedDay.year,
                widget.selectedDay.month,
                widget.selectedDay.day,
                pickedTime!.hour,
                pickedTime!.minute,
              );
              final String formattedTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(eventDateTimeUTC);

              widget.onSaveEvent(eventNameController.text, formattedTime);
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

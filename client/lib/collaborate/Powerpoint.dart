import 'package:client/widgets/rAppBar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client/services/network.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:async';

class PowerPointScreen extends StatefulWidget {
  String username = '';
  String serverIP = '';
  Socket? socket;

  PowerPointScreen({required this.username, required this.serverIP, required this.socket});
  _PowerPointScreenState createState() => _PowerPointScreenState();
}

class _PowerPointScreenState extends State<PowerPointScreen> {
  final List<dynamic> _powerpoints = [];
  final List<dynamic> _friends = [];
  final List<dynamic>_groups = [];
  //Socket? _socket;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    /*
    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
    );
    _socket = NetworkService.instance.socket;
    */
    _connectSocket();

    widget.socket!.emit('getpowerpoints', widget.username);
    widget.socket!.emit('buildfriendsppt', widget.username);
    widget.socket!.emit('buildgroupsppt', widget.username);
  }

  void _connectSocket() {
    widget.socket!.on('getpowerpoints', (data) {
      if(mounted) {
        print(data);
        setState(() {
          for (int i = 0; i < data.length; i++) {
            _powerpoints.add(data[i]);
          }
        });
      }
    });

    widget.socket!.on('createppt', (data) {
      _createTile(data);
    });

    widget.socket!.on('buildfriendsppt', (data) {
      _friends.addAll(data);
    });

    widget.socket!.on('buildgroupsppt', (data) {
      _groups.addAll(data);
    });
  }

  void _createTile(data) {
    if (mounted) {
      setState(() {
      _powerpoints.add(data[0]);
    });}
  }

  void _createPptInDatabase(username, title, url) {
    widget.socket!.emit('createppt', {
      'userID': username,
      'title': title,
      'url': url
    });
  }

  void _createPowerpoint() {
    TextEditingController addTitleController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New PowerPoint"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: addTitleController,
                  decoration: InputDecoration(hintText: "PowerPoint Title"),
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
              child: Text('Next'),
              onPressed: () {
                if (addTitleController.text.isNotEmpty) {
                  _launchUrl('https://slides.google.com/create');
                  Navigator.of(context).pop();
                  enterLinkToPpt(addTitleController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _launchUrl(url) async {
     url = Uri.parse(url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void enterLinkToPpt(title) {
    TextEditingController addURLController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Please enter PowerPoint URL"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: addURLController,
                  decoration: InputDecoration(hintText: "Insert PowerPoint URL"),
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
              child: Text('Create'),
              onPressed: () {
                if (addURLController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  _createPptInDatabase(widget.username, title, addURLController.text);
                  _reminder();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _reminder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
    return AlertDialog(
      title: Text("Reminder"),
      content: Text("Remember to change share settings if you want to collaborate!"),
      actions: <Widget>[
        Align(
          alignment: Alignment.center,
          child: TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        )
      ]
    );}
    );
  }

  void _confirmDeleteTask(int index, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Task"),
          content: Text("Are you sure you want to delete this PowerPoint?"),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                deletePpt(index, id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deletePpt(index, pptid) {
    widget.socket!.emit('deleteppt', {'PptID':pptid, 'user':widget.username});
    setState(() {
      _powerpoints.removeAt(index);
    });
  }

  void _shareForm(Ppt) {
    int selectedOption = 0; // Track the selected radio button option

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Share Options"),
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
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Next'),
                  onPressed: () {

                    Navigator.of(context).pop();
                    _shareSelect(selectedOption, Ppt);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _shareSelect(option, Ppt) {
    List<dynamic> items = [];
    String key = "";
    if (option == 0){
      print(Ppt);
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
                        widget.socket!.emit('sharepptfriend', {
                          'user': _friends[i][key],
                          'Ppt': Ppt
                          });
                      } else if (checkedItems[i] && option == 1) {
                        widget.socket!.emit('sharepptgroup', {
                          'group': _groups[i][key],
                          'Ppt': Ppt
                          });
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }


 Widget _buildPptList(List<dynamic> powerPoints) {
  return ListView.builder(
    itemCount: powerPoints.length,
    itemBuilder: (context, index) {
      return FractionallySizedBox(
        widthFactor: 0.7, // Set width to 70% of the parent width
        child: Card(
          margin: EdgeInsets.all(8.0),
          color: Colors.green,
          child: ListTile(
            title: Text(
              powerPoints[index]['PptName'],
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.open_in_browser_outlined, color: Colors.white),
                  onPressed: () {
                    _launchUrl(powerPoints[index]['Ppturl']);
                  },
                  tooltip: "Open",
                ),
                IconButton(
                  icon: Icon(Icons.group_add_outlined, color: Colors.white),
                  onPressed:() {
                    _shareForm(powerPoints[index]);
                  },
                  tooltip: "Share",
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteTask(index, powerPoints[index]['PptID']),
                  tooltip: "Delete",
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
            child: Text(
              'PowerPoints',
              style: TextStyle(
                fontSize: 24, // Adjust font size as needed
                fontWeight: FontWeight.bold, // Adjust font weight as needed
                color: Colors.green, // Adjust color as needed
              ),

            ),
            )
          ),
          Expanded(
            child: _buildPptList(_powerpoints)
                 ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _createPowerpoint,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

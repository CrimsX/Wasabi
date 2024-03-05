import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client/services/network.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:async';

class PowerPointScreen extends StatefulWidget {
  String username = '';
  String serverIP = '';

  PowerPointScreen({required this.username, required this.serverIP});
  _PowerPointScreenState createState() => _PowerPointScreenState();
}

class _PowerPointScreenState extends State<PowerPointScreen> {
  final List<String> _powerpoints = [];
  Socket? _socket;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    print(widget.username);
    super.initState();
    print(_socket == null);
    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
    );
    _socket = NetworkService.instance.socket;
    print(widget.serverIP);
    _connectSocket();

    _socket!.emit('getpowerpoints', widget.username);
  }

  void _connectSocket() {
    _socket!.on('getpowerpoints', (data) {
      if(mounted) {
        setState(() {
          for (int i = 0; i < data.length; i++) {
            _powerpoints.add(data[i]['Pptname']);
          }
        });
      }
    });
  }

  _createPptInDatabase(username, title, url) {
    _socket!.emit('createppt', {
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
                  setState(() {
                    _powerpoints.add(title);
                    // Optionally handle user/server sharing here
                  });
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                Text("Remember to change share settings if you want to collaborate!")
              ]
            ),
          ),
          actions: <Widget>[
            Align(
            alignment: Alignment.center,
            child: TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),)
            ]
          );
      });
  }

  void _confirmDeleteTask(int index) {
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
                setState(() {
                  _powerpoints.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildTaskList(List<String> powerPoints) {
    return ListView.builder(
      itemCount: powerPoints.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          color: Colors.green,
          child: ListTile(
            title: Text(
              powerPoints[index],
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.open_in_browser_outlined, color: Colors.white),
                  onPressed: () {
                    //launchurl()
                    return;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteTask(index),
                ),
              ],
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
            child: _buildTaskList(_powerpoints)
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

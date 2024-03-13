import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';




import 'package:client/services/network.dart';
import 'package:client/collaborate/Calendar.dart';
import 'package:client/collaborate/Todo.dart';
import 'package:client/collaborate/Draw.dart';
import 'package:client/collaborate/Powerpoint.dart';
import 'package:client/collaborate/FileEditing.dart';

// Ensure all necessary imports are here.
class Collaborate extends StatefulWidget {
  final String username;
  final String serverIP;

  const Collaborate({super.key, required this.username, required this.serverIP});

  @override
  _CollaborateState createState() => _CollaborateState();
}

class _CollaborateState extends State<Collaborate> {
  int _selectedTile = 0; // Assuming Calendar is the first tile with index 0
  Socket? _socket;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
    );
    _socket = NetworkService.instance.socket;
  }

  // Function to determine the content based on the selected tile
  Widget _getContentForSelectedTile(int index, String username, String serverIP) {
    switch (index) {
      case 0:
        return CalendarScreen(username: widget.username, serverIP: widget.serverIP, socket: _socket);
      case 1:
        return TodoScreen(username: widget.username, serverIP: widget.serverIP, socket: _socket);
      case 2:
        return const DrawScreen();
      case 3:
        return PowerPointScreen(username: username, serverIP: serverIP, socket: _socket);
      case 4:
        return const FileEditingScreen();
      default:
        return CalendarScreen(username: widget.username, serverIP: widget.serverIP, socket: _socket);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Collaborate', style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          Container(
            width: 200, // Sidebar width
            color: Colors.green, // Sidebar background color
            child: ListView(
              children: <Widget>[
                _buildTile(icon: Icons.calendar_today, title: 'Calendar', index: 0),
                _buildTile(icon: Icons.checklist_rtl, title: 'Todo List', index: 1),
                _buildTile(icon: Icons.brush, title: 'Draw', index: 2),
                _buildTile(icon: Icons.slideshow, title: 'Powerpoint', index: 3),
                _buildTile(icon: Icons.edit, title: 'File Editing', index: 4),
              ],
            ),
          ),
          Expanded(
            child: _getContentForSelectedTile(_selectedTile, widget.username, widget.serverIP), // Dynamically display content based on selected tile
          ),
        ],
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required int index}) {
    bool isSelected = _selectedTile == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.black),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontFamily: "Roboto", fontSize: 18, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? Colors.white : Colors.white,
      onTap: () {
        setState(() {
          _selectedTile = index;
        });
      },
    );
  }
}

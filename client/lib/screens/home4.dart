import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:client/providers/home.dart';
import 'package:client/model/message.dart';

class HomeScreen extends StatefulWidget {
  String username = '';
  HomeScreen({Key? key, required this.username}) : super(key: key);

  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();


  late IO.Socket _socket;


  @override
  void initState() {
    print(widget.username);
    super.initState();
    _socket = IO.io('http://localhost:3000',
      IO.OptionBuilder().setTransports(['websocket']).setQuery(
          {'username': widget.username}).build(),
    );
    _connectSocket();
  }


  _sendMessage() {
    _socket.emit('message', {
      'message': _controller.text,
      'sender': widget.username,
    });

    setState(() {
      // Removed the local list of messages
      _controller.clear();
    });
  }

  _connectSocket() {
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error: $data'));
    _socket.onDisconnect((data) => print('Socket.IO server disconnected'));
    _socket.on(
      'message',
          (data) => Provider.of<HomeProvider>(context, listen: false).addNewMessage(
        Message.fromJson(data),
      ),
    );
  }

  @override
  Widget _buildHoverableTile({
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.green : Colors.grey,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: selected ? Colors.grey.withOpacity(0.5) : Color(0xFF0a3107),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF031003),
      appBar: AppBar(
        title: Text(
          'Wasabi',
          style: TextStyle(
            color: Colors.green,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Color(0xFF0a3107),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF0a3107),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHoverableTile(
                title: 'My Profile',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Direct Message',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Group Message',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Collaborate',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Logout',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (_, provider, __) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  return Wrap(
                    alignment: message.senderUsername == widget.username
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    children: [
                      Card(
                        color: message.senderUsername == widget.username
                            ? Theme.of(context).primaryColorLight
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                            message.senderUsername == widget.username
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(message.message),
                              Text(
                                DateFormat('hh:mm a').format(message.sentAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: provider.messages.length,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            color: Color(0xFF0a3107),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.green,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

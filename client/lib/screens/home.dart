import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:client/providers/home.dart';
import 'package:client/model/message.dart';

import 'dart:io';

class HomeScreen extends StatefulWidget {
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    _socket = IO.io('http://localhost:3000',
    IO.OptionBuilder().setTransports(['websocket']).setQuery(
    {'username': 'Bob'}).build(),
    );
    _connectSocket();
  }

  _sendMessage() {
    //print("test");
     _socket.emit('message', {
          'message': _controller.text,
          'sender': 'Sender',
        });

    setState(() {
        _messages.add({
            'sender': 'Sender',
            'message': _controller.text,
          });
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
                //itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  return Wrap(
                    alignment: message.senderUsername == 'Sender'
                      ? WrapAlignment.end
                      : WrapAlignment.start,
                    children: [
                      Card(
                        color: message.senderUsername == 'Sender'
                          ? Theme.of(context).primaryColorLight
                          : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                              message.senderUsername == 'Sender'
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(message.message),
                              //Text(
                                //DateFormat('hh:mm a').format(message.sentAt),
                              //  style: Theme.of(context).textTheme.bodySmall,
                              //),
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
          
          //Container(
          //  decoration: BoxDecoration(
          //    color: Colors.grey.shade200,
          //  ),
          //), 

         /* 
          Expanded(
            child: Consumer<HomeProvider>(

            ),
          ), */
          Expanded(
            /* Background Colour */
            child: Container(
              //color: Color(0xFF031003),
              color: Color(0xFF90EE90),
              child: ListView.builder(
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: Alignment.centerRight,
                    //alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                        left: 80.0,
                        right: 8.0,
                      ),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF0a3107),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(0.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_messages[index]['sender']}:',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            _messages[index]['message'] ?? '',
                            style:
                            TextStyle(color: Colors.grey, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

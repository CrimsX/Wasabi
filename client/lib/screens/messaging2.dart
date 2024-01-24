/// messaging2.dart
///
/// The code below has the contacts as a drawer still,
/// I kept this incase the new design won't work, or populate the friends
/// on the row. This code is basically the original home.dart, just moved things around




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:client/providers/home.dart';
import 'package:client/model/message.dart';

import 'package:intl/intl.dart';

import 'dart:io';

import 'package:flutter/services.dart';





class HomeScreen extends StatefulWidget {
  String username = '';

  HomeScreen({Key? key, required this.username}) : super(key: key);
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// key for the drawer:
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final List<Widget> _friendsList =  [];
  String currentChatRoom = '';
  String currentChatFriend= '';
  dynamic friend;

  late IO.Socket _socket;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    print(widget.username);
    super.initState();
    _socket = IO.io(

      'http://localhost:3000',
      //Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000',
      IO.OptionBuilder().setTransports(['websocket']).setQuery(
          {'username': widget.username}).build(),
    );
    _connectSocket();
    //_joinRoom(widget.username);
    _socket.emit('friends', widget.username);
  }

  ///Socet Connection

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

    _socket.on(
        'friends',
            (data) => _buildFriendList(data)
    );

    _socket.on(
        'chat',
            (data) => _connectToChat(data)
    );

    _socket.on(
        'chatCreated',
            (data) => _connectToChat(data)
    );
    _socket.on(
        'fetchchat',
            (data) =>
            _loadChatHistory(data)
    );
  }

  ///Helper functions

  ///emits message to server when send button hit
  _sendMessage() {
    if (_controller.text == '') {
      return;
    }
    _socket.emit('message', {
      'message': _controller.text,
      'sender': widget.username,
      'receiver': currentChatFriend,
      'chatroom': currentChatRoom
    });

    setState(() {
      _messages.add({
        'sender': widget.username,
        'message': _controller.text,
      });
      _controller.clear();
    });
  }

  ///sends chat room number to server to join socket.io room
  _joinRoom(room) {
    _socket.emit('join', room);
  }

  ///sends chat room number to server to leave socket.io room
  _leaveRoom(room) {
    _socket.emit('leave', room);
  }

  ///checks if chat room exists between two users
  ///if not, it will create a new chatid in data base
  ///connects client to socket io room
  _connectToChat(data) {
    if (data.length == 0) {
      _createChatRoom(data);
      return;
    }
    currentChatRoom = data[0]['ChatID'].toString();
    _joinRoom(currentChatRoom);
    _fetchChat(currentChatRoom);
  }

  ///creates a chatID in db serving as unique chatroom between two users
  _createChatRoom(data) {
    _socket.emit('createChat', {'User1': widget.username, 'User2': currentChatFriend});
  }

  ///Gets chat history between user and the chat that is currently focused
  _fetchChat(chatID) {
    _socket.emit('fetchchat', {'chatID': chatID});
  }

  ///Gets chat history between user and chat partner from the db
  ///adds message to the screen after fetching
  _loadChatHistory(data) {
    for (var message in data) {
      Provider.of<HomeProvider>(context, listen: false).addNewMessage(
          Message.fromJson(message));
    }
  }


  ///build list of friends based on userID
  ///builds tiles on the end drawer for each friend in the db

  List<Widget> _buildFriendList(data) {
    for (var friend in data) {
      _friendsList.add(
          _buildHoverableTile(
            title: friend['FriendID'],
            onTap: () {
              //check if previously connected to another chat and leaves chat room if it is
              if (currentChatFriend !=  friend['FriendID']) {
                if (currentChatRoom != '') {
                  _leaveRoom(currentChatRoom);
                }
                // Clears chat screen when clicking onto new chat
                Provider.of<HomeProvider>(context, listen: false).messages.clear();
                Provider.of<HomeProvider>(context, listen: false).notifyListeners();
                currentChatFriend = friend['FriendID'];
                _socket.emit('chat', {'User1': widget.username,
                  'User2': currentChatFriend});
              }
              Navigator.pop(context);
            },
          ));
    }
    return _friendsList;
  }


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

  /// the drawer and header
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// key:
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
        backgroundColor: Colors.green,

        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.face),
          /// key
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // Handle Direct Message tap
            },
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.groups_2_rounded),
            onPressed: () {
              // Handle Group Message tap
            },
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.folder_copy_rounded),
            onPressed: () {
              // Handle Collaborate tap
            },
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle Settings tap
            },
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              // Handle Logout tap
            },
            color: Colors.white,
          ),
        ],
      ),



      /// I moved the end drawer to the left, so it's just drawer but what's inside is the same
      drawer: Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _friendsList,
          ),
        ),
      ),


      /// where messages show up :
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





          /*
          Expanded(
            // Background Colour
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
          */









          /// container design for the textfield bottom:
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    // Handle image button tap
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        border: InputBorder.none,
                      ),
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

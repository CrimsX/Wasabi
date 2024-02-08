import 'package:client/home/view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:socket_io_client/socket_io_client.dart';
//import 'package:client/providers/home.dart';
//import 'package:client/model/message.dart';
import 'package:client/login/view_model.dart';
import 'package:client/login/model.dart';
import 'package:intl/intl.dart';
import 'dart:io';


import 'dart:async';
import 'package:client/login/view.dart';
import 'dart:math';

import 'package:client/services/network.dart';
import 'package:client/widgets/menuBar.dart';



class Group extends StatefulWidget {
  String username = '';
  String serverIP = '';

  //Group({Key? key, required this.username}) : super(key: key);
  Group({required this.username, required this.serverIP});
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  /// key for the drawer:
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerServerName = TextEditingController();
  final List<Widget> _serverList = [];
  final List<Widget> _serverMemberList = [];
  final FocusNode _focusNode = FocusNode();
  String currentChatServer= '';
  dynamic server;


  late Completer<List<Widget>> _serverListCompleter;

  ScrollController _scrollController = ScrollController();

  final String selfCallerID = Random().nextInt(999999).toString().padLeft(6, '0');
  final String remoteCallerID = 'Offline';

  Socket? _socket;

   dynamic incomingSDPOffer;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    print(widget.username);
    if (widget.serverIP == '') {
        widget.serverIP = "http://localhost:3000/";
      } else {
          widget.serverIP = "http://" + widget.serverIP + ":3000/";
        }
    super.initState();
    _serverListCompleter = Completer<List<Widget>>();


    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
      selfCallerID: selfCallerID,
    );

    _socket = NetworkService.instance.socket;

    _connectSocket();
    _socket!.emit('servers', widget.username);
    print(_serverListCompleter.hashCode);
  }

  ///Socet Connection

  _connectSocket() {
    _socket!.onConnect((data) => print('Connection established'));
    _socket!.onConnectError((data) => print('Connect Error: $data'));
    _socket!.onDisconnect((data) => print('Socket.IO server disconnected'));
    _socket!.on(
      'groupmsg',
      (data) => Provider.of<HomeProvider>(context, listen: false).addNewMessage(
        Message.fromJson(data),
      ),
    );

    _socket!.on(
      'servers',
      (data) => _buildServerList(data)
    );

    _socket!.on(
      'fetchgroupchat',
      (data) =>
      _loadChatHistory(data)
    );

    _socket!.on('addServer', (data) =>
      _createGroupResponse(data)
    );

    _socket!.on('getservermembers', (data) =>
      _buildServerMemberList(data)
    );

  }

  ///Helper functions

  ///emits message to server when send button hit
  _sendMessage() {
    if (_controller.text == '') {
      return;
    }
     _socket!.emit('groupmsg', {
          'message': _controller.text,
          'sender': widget.username,
          'serverID': currentChatServer
        });

    setState(() {
        _messages.add({
            'sender': widget.username,
            'message': _controller.text,
          });
        _controller.clear();
      });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  ///sends serverID to server to join socket.io room
  _joinRoom(room) {
    _socket!.emit('joingroupchat', room);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  ///sends serverID to server to leave socket.io room
  _leaveRoom(room) {
    _socket!.emit('leave', room);
  }

  ///checks if chat room exists between two users
  ///if not, it will create a new chatid in data base
  ///connects client to socket io room
  _connectToGroupChat(serverID) {
    _joinRoom(serverID);
    _fetchGroupChat(serverID);
  }


  ///Gets chat history between user and the chat that is currently focused
  _fetchGroupChat(serverID) {
    _socket!.emit('fetchgroupchat', {'serverID': serverID});
  }

  ///Gets chat history between user and chat partner from the db
  ///adds message to the screen after fetching
  _loadChatHistory(data) {
    for (var message in data) {
      Provider.of<HomeProvider>(context, listen: false).addNewMessage(
        Message.fromJson(message));
    }
  }

  ///sends request to server to add server to db
  _createGroup(serverName){
    _socket!.emit('addserver', {'owner': widget.username,'serverName': serverName});
  }

  ///when server responds, updates serverslist side panel
  ///displays popup message if server is not added
  _createGroupResponse(result) {
    if (result['result']) {
      setState(() {
        _serverList.add(_buildServerTile(result['serverName'], result['serverID']));
      });
    }
    else {
      _showPopupMessage(context, result['serverName']);
    }
  }

  // Function to show the popup message
  void _showPopupMessage(BuildContext context, String serverName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Failed to add server'),
          content: Text(serverName + ' could not be added'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  _buildServerTile(serverName, serverID){
    return _buildHoverableTile(
                title: serverName,
                onTap: () {
                  if (currentChatServer == serverID) {
                    return;
                  }
                  //check if previously connected to another chat and leaves chat room if it is
                  if (currentChatServer != '' && currentChatServer !=  serverID) {
                    _socket!.emit('leavegroupchat', currentChatServer);
                  }
                    // Clears chat screen when clicking onto new chat
                    Provider.of<HomeProvider>(context, listen: false).messages.clear();
                    Provider.of<HomeProvider>(context, listen: false).notifyListeners();
                    currentChatServer = serverID;
                    print(currentChatServer);
                    _connectToGroupChat(currentChatServer);
                    FocusScope.of(context).requestFocus(_focusNode);
                },
                );
    }

  ///build list of servers based on userID
  ///builds tiles on the end drawer for each server in the db
  _buildServerList(data) {
    for (var server in data) {
      _serverList.add(
        _buildHoverableTile(
          title: server['ServerName'],
          onTap: () {
            if (currentChatServer == server['ServerID'].toString()) {
              return;
            }
            //check if previously connected to another chat and leaves chat room if it is
            if (currentChatServer != '' && currentChatServer !=  server['ServerID'].toString()) {
              _socket!.emit('leavegroupchat', currentChatServer);
            }
              // Clears chat screen when clicking onto new chat
              Provider.of<HomeProvider>(context, listen: false).messages.clear();
              Provider.of<HomeProvider>(context, listen: false).notifyListeners();
              currentChatServer = server['ServerID'].toString();
              print(currentChatServer);
              _connectToGroupChat(currentChatServer);
              _socket!.emit('getservermembers', currentChatServer);
              FocusScope.of(context).requestFocus(_focusNode);
          },
          )
        );
    }
    _serverListCompleter.complete(_serverList);
  }

  _buildServerMemberList(members) {
      _serverMemberList.clear();
      for (var member in members) {
        _serverMemberList.add(
          _buildHoverableTile(
                  title: member['UserID'],
                  onTap: (){},
          )
        );
      }
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
          color: selected ? Colors.green : const Color.fromARGB(255, 255, 255, 255),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: selected ? Colors.white : Color.fromARGB(255, 67, 153, 70),
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
        title: const Text(
          'Groups',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        leadingWidth: 200,

        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                _socket!.disconnect();
                Navigator.pop(context);
              },
              tooltip: 'Back',
            ),
            const SizedBox(width: 1),
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed:() {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Create Group'),
                    content: TextField(
                      controller: _controllerServerName,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Group Name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _createGroup(_controllerServerName.text);
                          _controllerServerName.clear();
                        },
                        child: const Text('Create'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
              },
              tooltip: 'Create Group',
            ),
          ]
        ),

        actions:[
          menuBar(),
        ],
      ),

      endDrawer: Drawer( // Define the end drawer
      child: ListView(
        padding: EdgeInsets.zero,
        children: _serverMemberList
      ),
    ),


      body: Row(
        children: [
          // Left side for server list
          Container(
            width: 200, // Adjust the width as needed
            child: Drawer(
              child: FutureBuilder<List<Widget>>(
              future: _serverListCompleter.future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Display the servers list once data is available
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: snapshot.data ?? [],
                  );
                }
              },
              ),
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<HomeProvider>(
                    builder: (_, provider, __) => ListView.separated(
                      controller: _scrollController,
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
                                  crossAxisAlignment: message.senderUsername == widget.username
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(message.senderUsername,
                                    style: Theme.of(context).textTheme.bodyLarge
                                    ),
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
                            focusNode: _focusNode,
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
          ),
        ],
      ),
    );
  }
}

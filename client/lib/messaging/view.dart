/// Redesigned Home.dart. Instead of drawers i used rows for the friend list
/// The navigation is not a drawer as well, it's in the header now
/// I added a + button on top that would add friends, which will open a pop up.
/// But it does not have the backend yet.

// ! checks if null
// ? runs even if null

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:socket_io_client/socket_io_client.dart';
//import 'package:client/providers/home.dart';
//import 'package:client/model/message.dart';
import 'package:client/login/view_model.dart';
import 'package:client/login/model.dart';

import 'package:intl/intl.dart';

import 'dart:io';

import 'package:flutter/services.dart';
import 'dart:async';

import 'package:client/login/view.dart';

// Random
import 'dart:math';

import 'package:client/voice/view.dart';
import 'package:client/services/network.dart';

import 'package:client/widgets/menuBar.dart';



/* don't delete yet
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context) => _ViewModel(),
      child: MaterialApp(
        title: "",
          home: _(),
      ),
    );
  }
}

class _ extends StatelessWidget {

}
*/

class HomeScreen extends StatefulWidget {
  String username = '';
  String serverIP = '';


  //HomeScreen({Key? key, required this.username}) : super(key: key);
  HomeScreen({required this.username, required this.serverIP});
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// key for the drawer:
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerAddFriend = TextEditingController();
  final List<Widget> _friendsList = [];
  final FocusNode _focusNode = FocusNode();
  String currentChatRoom = '';
  String currentChatFriend= '';
  dynamic friend;

  late Completer<List<Widget>> _friendsListCompleter;

  ScrollController _scrollController = ScrollController();

  // maybe hash name salted with current time
  final String selfCallerID = Random().nextInt(999999).toString().padLeft(6, '0');
  final String remoteCallerID = 'Offline';
 
  Socket? _socket;

  // VoIP
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
    _friendsListCompleter = Completer<List<Widget>>();

    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
      selfCallerID: selfCallerID,
    );

    _socket = NetworkService.instance.socket;
    
    _connectSocket();

    _socket!.emit('friends', widget.username);
    
    _socket!.on("newCall", (data) {
        if (mounted) {
            //print("received");
            setState(() => incomingSDPOffer = data);
        }
        //print(incomingSDPOffer);
    });
    /*
    NetworkService.instance.socket!.on("newCall", (data) {
      if (mounted) {
        setState(() => incomingSDPOffer = data);
      }
    });
    */
  }

  ///Socet Connection
  //
  // should be able to move this to network.dart
  _connectSocket() {
    //_socket?.onConnect((data) => print('Connection established'));
    //_socket?.onConnectError((data) => print('Connect Error: $data'));
    //_socket?.onDisconnect((data) => print('Socket.IO server disconnected'));

    _socket!.on(
      'message',
      (data) => Provider.of<HomeProvider>(context, listen: false).addNewMessage(
        Message.fromJson(data),
      ),
    );

    _socket!.on(
      'friends',
      (data) => _buildFriendList(data)
    );

    _socket!.on(
      'chat',
      (data) => _connectToChat(data)
    );

    _socket!.on(
      'chatCreated',
      (data) => _connectToChat(data)
    );

    _socket!.on(
      'fetchchat',
      (data) => _loadChatHistory(data)
    );

    _socket!.on(
      'addfriends',
      (data) => _addFriendResponse(data)
    );


    //_socket!.emit("requestFriendVoIPID", widget.username);

    /*
    _socket!.on(
      'receivefriendVoIPID',
      (data) => _requestFriendVoIPID(data)
    );
    */
      
  }

  ///Helper functions

  ///emits message to server when send button hit
  _sendMessage() {
    if (_controller.text == '') {
      return;
    }
     _socket!.emit('message', {
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

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  ///sends chat room number to server to join socket.io room
  _joinRoom(room) {
    _socket!.emit('join', room);
  }

  ///sends chat room number to server to leave socket.io room
  _leaveRoom(room) {
    _socket!.emit('leave', room);
  }

  ///checks if chat room exists between two users
  ///if not, it will create a new chatid in data base
  ///connects client to socket io room
  _connectToChat(data) {
    if (data.length == 0) {
      print(data);
      _createChatRoom(data);
      return;
    }
    currentChatRoom = data[0]['ChatID'].toString();
    _joinRoom(currentChatRoom);
    _fetchChat(currentChatRoom);
  }

  ///creates a chatID in db serving as unique chatroom between two users
  _createChatRoom(data) {
    _socket!.emit('createChat', {'User1': widget.username, 'User2': currentChatFriend});
  }

  ///Gets chat history between user and the chat that is currently focused
  _fetchChat(chatID) {
    _socket!.emit('fetchchat', {'chatID': chatID});
  }

  ///Gets chat history between user and chat partner from the db
  ///adds message to the screen after fetching
  _loadChatHistory(data) {
    for (var message in data) {
      Provider.of<HomeProvider>(context, listen: false).addNewMessage(
        Message.fromJson(message));
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  ///sends request to server to add friend to db
  _addFriendRequest(friendID){
    if (friendID == widget.username) {
      return;
    }
    _socket!.emit('addfriend', {'userID': widget.username,'friendID': friendID});
  }

  ///when server responds, updates friendslist side panel
  ///displays popup message if friend is not added
  _addFriendResponse(result) {
    if (result['result']) {
      _friendsList.add(_buildFriendTile(result['friendID']));
      setState(() {});
    }
    else {
      _showPopupMessage(context, result['friendID']);
    }
  }

  // Function to show the popup message
  void _showPopupMessage(BuildContext context, String friendID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Failed to add friend'),
          content: Text(friendID + ' could not be added'),
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

  _buildFriendTile(friendID){
    return _buildHoverableTile(
                title: friendID,
                onTap: () {
                  //check if previously connected to another chat and leaves chat room if it is
                  if (currentChatFriend !=  friendID) {
                    if (currentChatRoom != '') {
                    _leaveRoom(currentChatRoom);
                  }
                    // Clears chat screen when clicking onto new chat
                    Provider.of<HomeProvider>(context, listen: false).messages.clear();
                    Provider.of<HomeProvider>(context, listen: false).notifyListeners();
                    currentChatFriend = friendID;
                    _socket!.emit('chat', {'User1': widget.username,
                      'User2': currentChatFriend});
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                },
              );
  }


  ///build list of friends based on userID
  ///builds tiles on the end drawer for each friend in the db

  _buildFriendList(data) {
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
                    //print(currentChatFriend);
                    NetworkService.instance.setFriend(currentChatFriend);
                    _socket!.emit('chat', {'User1': widget.username,
                      'User2': currentChatFriend});
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                },
              ));
    }
    _friendsListCompleter.complete(_friendsList);
    setState(() {});
    }

    _requestFriendVoIPID(data) {
      _socket!.emit('receivefriendVoIPID', widget.username);
      //NetworkService.instance.setRemoteCallerID = data;
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

  // Join VoIP
  _joinCall({
    required String callerId,
    required String calleeId,
    dynamic offer,
    required bool showVid,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoIP(
          callerId: callerId,
          calleeId: calleeId,
          offer: offer,
          showVid: showVid,
        ),
      ),
    );
  }

 /// the drawer and header
  @override
  Widget build(BuildContext context) {
    /*
    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.username,
      selfCallerID: selfCallerID,
    );
    */
    //print(incomingSDPOffer);

    return Scaffold(
      /// key:
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Direct Messages',
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
                Navigator.pop(context);
              },
              tooltip: 'Back',
            ),
            const SizedBox(width: 1),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Add Friend'),
                    content: TextField(
                      controller: _controllerAddFriend,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Friend ID'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _addFriendRequest(_controllerAddFriend.text);
                          _controllerAddFriend.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
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
              tooltip: 'Add Friend',
            ),
          ]
        ),

        actions:[
          menuBar(),
        ],
      ),

      body: Row(
        children: [
          // Left side for friend list
          Container(
            width: 200, // Adjust the width as needed
            child: Drawer(
              child: FutureBuilder<List<Widget>>(
                future: _friendsListCompleter.future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Display the friends list once data is available
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
          
          if (incomingSDPOffer != null) 
            /*
            Positioned(
              child: Row(
                title: Text(
                  "Incoming Call from ${incomingSDPOffer["callerId"]}",
                 ),
                trailing: Row(
                  //mainAxisSize: MainAxisSize.min,
                  children: [ 
                  */
        Column(
        children: [
                    IconButton(
                      icon: const Icon(Icons.call_end),
                      color: Colors.redAccent,
                      onPressed: () {
                        setState(() => incomingSDPOffer = null);
                        },
                    ),
                    IconButton(
                      icon: const Icon(Icons.call),
                      color: Colors.greenAccent,
                      onPressed: () {
                        _joinCall(
                          callerId: incomingSDPOffer["callerId"]!,
                          calleeId: NetworkService.instance.getselfCallerID,
                          offer: incomingSDPOffer["sdpOffer"],
                          showVid: incomingSDPOffer["showVid"],
                        );
                      },
                    ),
                    ],
                    ),
          
          /*
                  ],
                ),
              ),
            ),
            */
        ],
      ),
    );
  }
}


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

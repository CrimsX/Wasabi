import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'view_model.dart';
import 'model.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

import 'package:livekit_client/livekit_client.dart' as LK;

import 'package:client/widgets/userDrawer.dart';
import 'package:client/widgets/rAppBar.dart';
import 'package:client/widgets/landingPage.dart';
import 'package:client/widgets/hoverableTile.dart';

import 'package:client/voice/view.dart';
import 'package:client/room/view.dart';

import 'package:intl/intl.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  String username = '';
  String serverIP = '';
  Socket? socket;


  //HomeScreen({Key? key, required this.username}) : super(key: key);
  HomeScreen({super.key, required this.username, required this.serverIP, required this.socket});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// key for the drawer:
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  // dm
  final TextEditingController _controllerAddFriend = TextEditingController();
  final List<Widget> _friendsList = [];
  final FocusNode _focusNode = FocusNode();
  String currentChatRoom = '';
  String currentChatFriend= '';
  dynamic friend;

  // server
  final TextEditingController _controllerServerName = TextEditingController();
  final List<Widget> _serverList = [];
  final List<Widget> _serverMemberList = [];
  final List<String> _serverMemberIDs = [];
  final List<String> _friendIDs = [];
  String currentChatServer= '';
  String currentChatServerName= '';
  dynamic server;

  late Completer<List<Widget>> _friendsListCompleter;
  late Completer<List<Widget>> _serverListCompleter;

  final ScrollController _scrollController = ScrollController();

  Socket? _socket;

  // VoIP
  dynamic incomingSDPOffer;
  dynamic offerRoom;

  bool isServer = false;
  bool start = true;


  @override
  void initState() {
    super.initState();
    _friendsListCompleter = Completer<List<Widget>>();
    _serverListCompleter = Completer<List<Widget>>();

    _socket = widget.socket;

    _connectSocket();

    _socket!.emit('friends', widget.username);
    _socket!.emit('servers', widget.username);

    _socket!.on('joinRoom', (data) {
      //print(data);
        if (mounted) {
            setState(() => offerRoom = data);
        }
    });

    /*
    _socket!.on("newCall", (data) {
      if (mounted) {
        setState(() => incomingSDPOffer = data);
      }
    });
    */
  }

  @override
  void dispose() {
    super.dispose();
    _socket!.disconnect();
  }

  ///Socet Connection
  //
  // should be able to move this to network.dart
  _connectSocket() {
    _socket!.on('message', (data) {
      Provider.of<MessageProvider>(context, listen: false).addNewMessage(
        Message.fromJson(data),);
    });

    ///build list of friends based on userID
    ///builds tiles on the end drawer for each friend in the db
    _socket!.on('friends', (data) {
      for (var friend in data) {
        _friendIDs.add(friend['FriendID']);
        _friendsList.add(
          hoverableTile(
            title: friend['FriendID'],
            onTap: () {
              //check if previously connected to another chat and leaves chat room if it is
              if (currentChatFriend !=  friend['FriendID']) {
                if (currentChatRoom != '') {
                  _socket!.emit('leave', currentChatRoom);
                }
                // Clears chat screen when clicking onto new chat
                Provider.of<MessageProvider>(context, listen: false).messages.clear();
                Provider.of<MessageProvider>(context, listen: false).notifyListeners();
                currentChatFriend = friend['FriendID'];
                //print(currentChatFriend);
                NetworkService.instance.setFriend(currentChatFriend);
                _socket!.emit('chat', {
                  'User1': widget.username,
                  'User2': currentChatFriend
                });
                FocusScope.of(context).requestFocus(_focusNode);
              }
            },
          )
        );
      }
      _friendsListCompleter.complete(_friendsList);
      setState(() {});
    });

    _socket!.on('chat', (data) => _connectToChat(data));

    _socket!.on('chatCreated', (data) => _connectToChat(data));

    // Gets chat history between user and chat partner from the db
    // adds message to the screen after fetching
    _socket!.on('fetchchat', (data) {
      for (var message in data) {
        Provider.of<MessageProvider>(context, listen: false).addNewMessage(
        Message.fromJson(message));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

   //when server responds, updates friendslist side panel
   //displays popup message if friend is not added
    _socket!.on('addfriends', (data) {
      if (data['result']) {
        _friendsList.add(_buildFriendTile(data['friendID']));
        setState(() {});
      } else {
        _showPopupMessage(context, data['friendID']);
      }
    });

    _socket!.on('receivefriends', (data) {
      if (data['result']) {
        _friendsList.add(_buildFriendTile(data['friendID']));
        setState(() {});
      }
    });

    _socket!.on('groupmsg',
      (data) => Provider.of<MessageProvider>(context, listen: false).addNewMessage(
        Message.fromJson(data),
      ),
    );

    ///build list of servers based on userID
    ///builds tiles on the end drawer for each server in the db
    _socket!.on('servers', (data) {
      for (var server in data) {
        _serverList.add(
          hoverableTile(
            key: ValueKey<int>(server['ServerID']),
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
              Provider.of<MessageProvider>(context, listen: false).messages.clear();
              Provider.of<MessageProvider>(context, listen: false).notifyListeners();
              currentChatServer = server['ServerID'].toString();
              print(currentChatServer);
              currentChatServerName= server['ServerName'];
              print(currentChatServerName);
              NetworkService.instance.setRoomName(currentChatServerName);
              _connectToGroupChat(currentChatServer);
              _socket!.emit('getservermembers', currentChatServer);
              FocusScope.of(context).requestFocus(_focusNode);
            },
          )
        );
      }
      _serverListCompleter.complete(_serverList);
    });

    ///Gets chat history between user and chat partner from the db
    ///adds message to the screen after fetching
    _socket!.on('fetchgroupchat', (data) {
      for (var message in data) {
        Provider.of<MessageProvider>(context, listen: false).addNewMessage(
        Message.fromJson(message));
      }
    });

    ///when server responds, updates serverslist side panel
    ///displays popup message if server is not added
    _socket!.on('addServer', (data) {
      if (data['result']) {
        setState(() {
          _serverList.add(_buildServerTile(data['serverName'], data['serverID']));
        });
      } else {
      _showPopupMessage(context, data['serverName']);
      }
    });

    _socket!.on('getservermembers', (data) {
      _serverMemberList.clear();
      _serverMemberIDs.clear();
      for (var member in data) {
        if (member['UserID'] != widget.username) {
          NetworkService.instance.groupNames.add(member['UserID']);
        }
        _serverMemberIDs.add(member['UserID']);
        _serverMemberList.add(
          hoverableTile(
            title: member['UserID'],
              onTap: (){},
          )
        );
      }
    });

    _socket!.on('invite', (data) {
      print(data);
      setState(() {
          _serverList.add(_buildServerTile(data['serverName'], data['serverID']));
        });
    });

    _socket!.on('leaveserver', (data) {
      print(_serverList);
      for (int i = 0; i < _serverList.length; i++) {
        int serverKey = (_serverList[i].key as ValueKey<int>).value;
        print(serverKey);
        if (serverKey == int.parse(data['serverID']))
        {
          print('hi');
          setState(() {
            _serverList.removeAt(i);
          });
          print(_serverList);
          return;
        }
      }
    });

    _socket!.on('createRoom', (data) {
      print('Room created');
      final room = LK.Room();

      //print(data);
      //print(data['url']);
      //print(data['result']);
       //var room = LK.Room();
      room.connect(data['url'], data['result']);
      // Turns camera track on
      //room.localParticipant!.setCameraEnabled(true);

      // Turns microphone track on
      //room.localParticipant!.setMicrophoneEnabled(true);
      //final listener = room.createListener();
      //NetworkService.instance.setRoom = room;
      Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomPage(
                    room,
                    room.createListener(),
                  ),
                ),
              );
    });

  }

  ///Helper functions

  ///emits message to server when send button hit
  _sendMessage() {
    if (_controller.text != '') {
      if (!isServer) {
        _socket!.emit('message', {
          'message': _controller.text,
          'sender': widget.username,
          'receiver': currentChatFriend,
          'chatroom': currentChatRoom
        });
      } else {
        _socket!.emit('groupmsg', {
          'message': _controller.text,
          'sender': widget.username,
          'serverID': currentChatServer
        });
      }
      setState(() {
        _messages.add({
          'sender': widget.username,
          'message': _controller.text,
        });
        _controller.clear();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  ///checks if chat room exists between two users
  ///if not, it will create a new chatid in data base
  ///connects client to socket io room
  _connectToChat(data) {
    if (data.length == 0) {
      print(data);
      _socket!.emit('createChat', {'User1': widget.username, 'User2': currentChatFriend});
      return;
    }
    currentChatRoom = data[0]['ChatID'].toString();
    _socket!.emit('join', currentChatRoom);
    _socket!.emit('fetchchat', {'chatID': currentChatRoom});
  }

  ///checks if chat room exists between two users
  ///if not, it will create a new chatid in data base
  ///connects client to socket io room
  _connectToGroupChat(serverID) {
    _socket!.emit('joingroupchat', serverID);
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    _socket!.emit('fetchgroupchat', {'serverID': serverID});
  }

  // Function to show the popup message
  void _showPopupMessage(BuildContext context, String friendID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (!isServer) {
          return AlertDialog(
            title: const Text('Failed to add friend'),
            content: Text('$friendID could not be added'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Failed to add server'),
            content: Text('$friendID could not be added'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        }
      },
    );
  }

  getFriendIndex(friendID) {
    for (int i = 0; i < _friendIDs.length; i++){
      if (_friendIDs[i] == friendID) {
        return i;
      }
    }
  }

  // Function to build the friend tile
  _buildFriendTile(friendID){
    _friendIDs.add(friendID);
    return hoverableTile(
      title: friendID,
      onTap: () {
        //check if previously connected to another chat and leaves chat room if it is
        if (currentChatFriend !=  friendID) {
          if (currentChatRoom != '') {
            _socket!.emit('leave', currentChatRoom);
          }
          // Clears chat screen when clicking onto new chat
          Provider.of<MessageProvider>(context, listen: false).messages.clear();
          Provider.of<MessageProvider>(context, listen: false).notifyListeners();
          currentChatFriend = friendID;
          _socket!.emit('chat', {'User1': widget.username,
                                'User2': currentChatFriend});
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
    );
  }

  // Function to build the server tile
  _buildServerTile(serverName, serverID){
    return hoverableTile(
      key: ValueKey<int>(int.parse(serverID)),
      title: serverName,
      onTap: () {
        //check if previously connected to another chat and leaves chat room if it is
        if (currentChatServer !=  serverID) {
          if (currentChatRoom != '') {
            _socket!.emit('leave', currentChatRoom);
          }
          // Clears chat screen when clicking onto new chat
          Provider.of<MessageProvider>(context, listen: false).messages.clear();
          Provider.of<MessageProvider>(context, listen: false).notifyListeners();
          currentChatServer = serverID;
          currentChatServerName= serverName;
          _connectToGroupChat(serverID);
          _socket!.emit('getservermembers', currentChatServer);
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
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

  // Join VoIP
  _joingroupCall({
    required String callerId,
    required List<String> groupcalleeId,
    dynamic offer,
    required bool showVid,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => groupVoIP(
          callerId: callerId,
          groupcalleeId: groupcalleeId,
          offer: offer,
          showVid: showVid,
        ),
      ),
    );
  }

  populateInviteList(inviteList) {
    for (var username in _friendIDs) {
      if (!_serverMemberIDs.contains(username)) {
        inviteList.add(username);
      }
    }
  }

  /// the drawer and header
  @override
  Widget build(BuildContext context) {
    String titleName;
    if (start) {
      titleName = 'Home';
    } else {
      titleName = !isServer ? "Direct Messages" : 'Groups';
    }
    Completer<List<Widget>> listCompleter = !isServer ? _friendsListCompleter : _serverListCompleter;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(titleName,
          style: const TextStyle(
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
        leadingWidth: 250,

        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),

            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                start = true;
                setState(() {});
              },
            ),
            Visibility(
              visible: (start || isServer),
              child: IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    start = false;
                    isServer = false;
                    NetworkService.instance.setType('DM');

                    setState(() {});
                  },
                  tooltip: 'DM',
                ),
            ),
            Visibility(
              visible: (start || !isServer),
              child: IconButton(
                icon: const Icon(Icons.groups_2_rounded),
                onPressed: () {
                  start = false;
                  isServer = true;
                  NetworkService.instance.setType('group');
                  currentChatServer = '';
                  currentChatServerName = '';

                  setState(() {});
                },
                tooltip: 'Server',
                )
              ),

            const SizedBox(width: 1),

            if (!start && !isServer)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                  if (_controllerAddFriend.text != widget.username) {
                                    _socket!.emit('addfriend', {'userID': widget.username,'friendID': _controllerAddFriend.text});
                                  }
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
                ],
              ),

            if (!start && isServer)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box),
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
                                  _socket!.emit('addserver', {'owner': widget.username,'serverName': _controllerServerName.text});
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
                  )
                ],
              ),
          ]
        ),

        actions:[
          // Hide EndDrawer
          Container(),

          if (!start) ... {
            rAppBar(),
            Visibility(
              visible: isServer && currentChatServer != "",
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.group_add),
                    onPressed: () {
                      List<String> inviteList = [];
                      populateInviteList(inviteList);
                      if (inviteList.length == 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Invite to $currentChatServerName'),
                              content: Text(
                                'No Friends To Invite :(', // Center the body text horizontally
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Ok'),
                                ),
                              ]
                            );
                        }
                        );
                      } else {
                        List<bool> checkedItems = List<bool>.filled(inviteList.length, false); // Initialize with false values
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: Text('Invite to $currentChatServerName'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        inviteList.length,
                                        (index) {
                                          return CheckboxListTile(
                                            title: Text(inviteList[index]),
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
                                        for (int i = 0; i < inviteList.length; i++) {
                                          if (checkedItems[i]){
                                            print(inviteList[i]);
                                            print(currentChatServer);
                                            widget.socket!.emit('invite', {
                                              'friendID': inviteList[i],
                                              'serverName': currentChatServerName,
                                              'serverID': currentChatServer
                                              });
                                             _serverMemberIDs.add(inviteList[i]);
                                              _serverMemberList.add(
                                                hoverableTile(
                                                  title: inviteList[i],
                                                    onTap: (){},
                                                )
                                              );
                                          }
                                        }
                                        setState(() => {});
                                        Navigator.pop(context);
                                      },
                                      child: Text('Invite'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }

                    },
                    color: Colors.white,
                    tooltip: "Invite to Group",
                  ),

                  IconButton(
                    icon: const Icon(Icons.group_rounded),
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    color: Colors.white,
                    tooltip: "Server Members",
                  ),

                  IconButton(
                      icon: const Icon(Icons.door_back_door),
                      onPressed:() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                  'Leave Server',
                                ),
                              content: Text(
                                'Are you sure you want to leave $currentChatServerName?', // Center the body text horizontally
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _socket!.emit('leaveserver', {'username': widget.username, 'serverID': currentChatServer});
                                  },
                                  child: const Text('Leave'),
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
                      tooltip: 'Leave Group',
                    ),
                ]
              )
            ),
            Visibility(
              visible: (!isServer && currentChatFriend != ""),
              child: IconButton(
                icon: const Icon(Icons.person_remove),
                onPressed: () {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Remove Friend'),
                        content: Text(
                          'Remove $currentChatFriend from friends?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              int index = getFriendIndex(currentChatFriend);
                              _friendIDs.removeAt(index);
                              setState(() {_friendsList.removeAt(index);});
                              _socket!.emit('removefriend', {'userID': widget.username,'friendID': currentChatFriend});
                              Navigator.of(context).pop();
                            },
                            child: const Text('Remove'),
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
              tooltip: "Remove Friend",
            )
          )
          }
        ],
      ),

      drawer:
        userDrawer(),

      endDrawer: Drawer( // Define the end drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: _serverMemberList
        ),
      ),

      body: start
        ? landingPage()
        : Row(
            children: [
              // Left side for friend list
              SizedBox(
                width: 200, // Adjust the width as needed
                child: Drawer(
                  child: FutureBuilder<List<Widget>>(
                    future: listCompleter.future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Loading indicator
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
                      child: Consumer<MessageProvider>(
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
                if(currentChatFriend != '' || currentChatServer != '')
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: Row(
                    children: [
                    // TODO: Send images
                    /*
                      IconButton(
                        icon: const Icon(
                          Icons.image,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          // Handle image button tap
                        },
                      ),
                      */
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
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
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
          if (offerRoom != null)
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
                    setState(() => offerRoom = null);
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.call),
                  color: Colors.greenAccent,
                  onPressed: () {
                    print(offerRoom['roomOffer']);
                    NetworkService.instance.socket!.emit("createRoom", {'roomName': offerRoom['roomOffer']});
/*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomPage(
                    NetworkService.instance.room,
                    NetworkService.instance.getListener,
                  ),
                ),
              );
              */
                    //if (!isServer) {
                      /*
                      _joinCall(
                        callerId: incomingSDPOffer["callerId"]!,
                        calleeId: NetworkService.instance.getselfCallerID,
                        offer: incomingSDPOffer["sdpOffer"],
                        showVid: incomingSDPOffer["showVid"],
                      );
                      */
                    //} else {
                      /*
                      List<String> groupNames = NetworkService.instance.getGroupNames;
                      List<String> groupCallerID = [];
                      for (int i = 0; i < groupNames.length; i++) {
                        _socket!.emit("requestVoIPID", groupNames[i]);
                        //NetworkService.instance.addGroupCallerID(NetworkService.instance.getRemoteCallerID);
                      }
                      groupCallerID = NetworkService.instance.getGroupCallerID;
                      _joingroupCall(
                        callerId: incomingSDPOffer["callerId"]!,
                        //groupcalleeId: NetworkService.instance.groupNames,
                        groupcalleeId: groupCallerID,
                        //calleeId: NetworkService.instance.getselfCallerID,
                        offer: incomingSDPOffer["sdpOffer"],
                        showVid: incomingSDPOffer["showVid"],
                      );
                      */
                   // }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

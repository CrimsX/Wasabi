//import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart';

import 'package:livekit_client/livekit_client.dart';

import 'dart:math';

class NetworkService {
  Socket? socket;

  String serverIP = '';
  String username = '';
  // maybe hash name salted with current time
  String selfCallerID = Random().nextInt(999999).toString().padLeft(6, '0');
  String remoteCallerID = 'Offline';
  String friend = '';
  String type = '';
  List<String> groupNames = [];
  List<String> groupCallerID = [];
  final room = Room();
  String roomName = '';


  NetworkService._();
  static final instance = NetworkService._();

  init({required String serverIP, required String username}) {
    // init Socket
    socket = io(serverIP, {
      "transports": ['websocket'],
      "query": {
        "username": username,
        "callerId": selfCallerID
      }   
    });

    this.serverIP = serverIP;
    this.username = username;
    selfCallerID = selfCallerID;

    /*
    socket = IO.io(
      serverIP,
    IO.OptionBuilder().setTransports(['websocket']).setQuery(
    {'username': username,
    'callerId': selfCallerID}).build(),
    );
    */

    socket!.onConnect((data) => print('Connection established'));
    socket!.onConnectError((data) => print('Connect Error: $data'));
    socket!.onDisconnect((data) => print('Socket.IO server disconnected'));

/*
    // listen onConnect event
    socket!.onConnect((data) {
      log("Socket connected !!");
    });
  
    // listen onConnectError event
    socket!.onConnectError((data) {
      log("Connect Error $data");
    });
    */
    
    //socket!.onDisconnect((data) => print('Socket.IO server disconnected')); 

   socket!.on(
      'r_VoIPID',
      (data) => _responseFriendVoIPID(data)
    ); 

    // connect socket
    //socket!.connect();
    /*
     socket!.on('createRoom', (data) {
      print('Room created');
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
    });
     */
  }

   _responseFriendVoIPID(data) {
    remoteCallerID = data;
    groupCallerID.add(remoteCallerID);
    //print("test2");
    //NetworkService.instance.socket!.emit('s_VoIPID', "test");
  } 


    // Getters
    String get getserverIP => serverIP;
    String get getusername => username;
    String get getselfCallerID => selfCallerID;
    String get getRemoteCallerID => remoteCallerID;
    String get getFriend => friend;
    String get getType => type;
    List<String> get getGroupNames => groupNames;
    List<String> get getGroupCallerID => groupCallerID;
    Room get getRoom => room;
    EventsListener<RoomEvent> get getListener => room.createListener();

    // Setters
    set setRemoteCallerID(String remoteCallerID) {
      this.remoteCallerID = remoteCallerID;
    }
    
    setFriend (String friend) {
      this.friend = friend;
    } 

    //String set setFriend(String friend) = friend;
    /*
    set setFriend(String friend) {
        this.friend = friend;
    }
    */

    setType (String type) {
      this.type = type;
    }

    addGroupNames(String Name) {
      groupNames.add(Name);
    }

    addGroupCallerID(String groupCallerID) {
      this.groupCallerID.add(groupCallerID);
    }
    
    set setRoom(Room room) => room = room;

    /*
    setRoom(Room room) {
      this.room = room;
    }
    */

    setRoomName(String roomName) {
      this.roomName = roomName;
    }
}

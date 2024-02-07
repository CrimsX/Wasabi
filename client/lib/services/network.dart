import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart';

class NetworkService {
  Socket? socket;

  String serverIP = '';
  String username = '';
  String selfCallerID = '';
  String remoteCallerID = 'Offline';

  NetworkService._();
  static final instance = NetworkService._();

  init({required String serverIP, required String username, required String selfCallerID}) {
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
    this.selfCallerID = selfCallerID;

    /*
    socket = IO.io(
      serverIP,
    IO.OptionBuilder().setTransports(['websocket']).setQuery(
    {'username': username,
    'callerId': selfCallerID}).build(),
    );
    */

    // listen onConnect event
    socket!.onConnect((data) {
      log("Socket connected !!");
    });

    // listen onConnectError event
    socket!.onConnectError((data) {
      log("Connect Error $data");
    });
    
    //socket!.onDisconnect((data) => print('Socket.IO server disconnected'));
    
   socket!.on(
      'r_VoIPID',
      (data) => _responseFriendVoIPID(data)
    ); 

    // connect socket
    socket!.connect();
  }

   _responseFriendVoIPID(data) {
    remoteCallerID = data;
    //print("test2");
    //NetworkService.instance.socket!.emit('s_VoIPID', "test");
  }
    // Getters
    String get getserverIP => serverIP;
    String get getusername => username;
    String get getselfCallerID => selfCallerID;
    String get getRemoteCallerID => remoteCallerID;

    // Setters
    set setRemoteCallerID(String remoteCallerID) {
      this.remoteCallerID = remoteCallerID;
    }
}

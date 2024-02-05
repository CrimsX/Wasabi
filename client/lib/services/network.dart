import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart';

class NetworkService {
  Socket? socket;

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

    // connect socket
    socket!.connect();
  }
}

import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart';

class NetworkService {
  // instance of Socket
  Socket? socket;

  NetworkService._();
  static final instance = NetworkService._();

  init({required String websocketUrl, required String selfCallerID}) {
    // init Socket
    socket = io(websocketUrl, {
      "transports": ['websocket'],
      "query": {"callerId": selfCallerID}
    });

    // listen onConnect event
    socket!.onConnect((data) {
      log("Socket connected !!");
    });

    // listen onConnectError event
    socket!.onConnectError((data) {
      log("Connect Error $data");
    });

    // connect socket
    socket!.connect();
  }
}
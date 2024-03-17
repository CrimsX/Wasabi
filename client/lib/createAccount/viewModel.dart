import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';

class SocketEvents extends ChangeNotifier {
  late Socket? _socket;
  Socket get socket => _socket!;

  bool accountCreated = false;

  // Initialize socket connection
  void connect(String serverIP) {
    _socket = io(serverIP, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();
  }

  // Disconnect socket
  void disconnect() {
    _socket!.disconnect();
  }

  // Create account response
  void createAccountResponse(BuildContext context) {
    _socket!.on('createaccountResponse', (data) {
      if (data["success"]) {
        accountCreated = true;
      } else {
        accountCreated = false;
      }

      // Dialog response
      String dialogTitle = accountCreated ? "Account Created" : "Account Creation Failed";
      String dialogContent = accountCreated ? "Your account has been successfully created." : "Please try again with a different username.";

      // Show dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green,
            title: Text(dialogTitle, style: TextStyle(color: Colors.white)),
            content: Text(dialogContent, style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  if (accountCreated) {
                    Navigator.of(context)..pop()..pop();
                  } else {
                    Navigator.of(context)..pop();
                  }
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    });
  }

  // Create account
  void createAccount(BuildContext context, String username, String displayName, String password) {
    // Validate input
    if (username.isEmpty || displayName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all the fields."),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _socket!.emit('createaccount', {'userID': username, 'displayName': displayName, 'password': password});
    }
  }
}

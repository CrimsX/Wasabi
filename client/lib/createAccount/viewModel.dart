import 'package:flutter/material.dart';

import 'model.dart';

import 'package:socket_io_client/socket_io_client.dart';

class createAccountViewModel extends ChangeNotifier {
  createAccountModel model = new createAccountModel();
  bool get isAccountCreated => model.accountCreated;
  bool get isPasswordVisible => model.isPasswordVisible;

  late Socket? _socket;
  Socket get socket => _socket!;

  // Model updates
  //
  // Toggle password visibility
  void togglePasswordVisibility() {
    model.isPasswordVisible = !model.isPasswordVisible;
    notifyListeners();
  }

  // Socket events
  // 
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
        model.accountCreated = true;
      } else {
        model.accountCreated = false;
      }

      // Dialog response
      String dialogTitle = model.accountCreated ? "Account Created" : "Account Creation Failed";
      String dialogContent = model.accountCreated ? "Your account has been successfully created." : "Please try again with a different username.";

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
                  if (model.accountCreated) {
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

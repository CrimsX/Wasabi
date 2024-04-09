import 'package:flutter/material.dart';

import 'model.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

import 'package:provider/provider.dart';
import 'package:client/home/view.dart';
import 'package:client/home/view_model.dart';

class LoginViewModel extends ChangeNotifier {
  LoginModel model = new LoginModel();
  Servers? get selectedServer => model.selectedServer;
  bool get isPasswordVisible => model.isPasswordVisible;

  late Socket? _socket;
  Socket get socket => _socket!;

  // Model updates
  //
  // Set selected server
  void setServer(Servers? server) {
    model.selectedServer = server;
    notifyListeners();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    model.isPasswordVisible = !model.isPasswordVisible;
    notifyListeners();
  }

  // Socket events
  //
  // Initialize socket connection
  void connect(String serverIP, String username) {
    NetworkService.instance.init(
      serverIP: serverIP,
      username: username,
    );
    _socket = NetworkService.instance.socket;
  }

  // Disconnect socket
  void disconnect() {
    _socket!.disconnect();
  }

  // Send login request
  void userLogin(BuildContext context, String username, String password) {
    String serverIP = NetworkService.instance.serverIP;
    print(username);
    print(password);

    _socket!.emit('login', {
      'userID': username,
      'password': password,
    });

    _socket!.on('loginResponse', (data) {
      // Handle login response
      if (data['success']) {
        _socket!.emit('getUsername', username);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (context) => MessageProvider(),
              child: HomeScreen(
                username: username,
                serverIP: serverIP,
                socket: _socket,
              ),
            ),
          ),
        );
      } else {
        // Handle login failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Login failed"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}

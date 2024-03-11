import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:provider/provider.dart';

import 'package:client/home/view_model.dart';

import '../createAccount/view.dart';
import 'package:client/home/view.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController serverIPController = TextEditingController();
  IO.Socket? _socket; // Now nullable to safely handle initialization
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    initializeSocket();
  }

  void initializeSocket() {
    // Assuming serverIPController contains the full server IP including protocol and port
    //String serverIP = serverIPController.text.isNotEmpty ? "http://${serverIPController.text}" : 'http://192.168.56.1:3000';
    String serverIP = "http://localhost:3000";

    // Initialize socket connection
    _socket = IO.io(serverIP, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false, // Changed to true to ensure connection starts immediately
    });
  }

  void _login(BuildContext context) {
    _socket!.connect(); 
    // Check if _socket is initialized
    if (_socket != null) {
      _socket!.emit('login', {
        'userID': usernameController.text.trim(),
        'password': passwordController.text.trim(),
      });

      _socket!.on('loginResponse', (data) {
        if (data['success']) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (context) => MessageProvider(),
                child: HomeScreen(
                  username: usernameController.text.trim(),
                  serverIP: serverIPController.text.trim(),
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
    } else {
      print('Socket not initialized');
      // Consider showing an error message or retrying the initialization
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              color: Colors.lightGreen,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/Wasabi.png',
                        width: 200,
                        height: 220,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your Username',
                      prefixIcon: const Icon(Icons.person, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.black),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        child: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: serverIPController,
                    decoration: InputDecoration(
                      labelText: 'Server IP (optional)',
                      hintText: 'Enter server IP',
                      prefixIcon: const Icon(Icons.data_usage, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateAccount(),
                            ),
                          );
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.lightGreen,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  MaterialButton(
                    onPressed: () => _login(context),
                    height: 45,
                    color: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.close();
    super.dispose();
  }
}

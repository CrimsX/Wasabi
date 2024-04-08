import 'package:flutter/material.dart';

import 'viewModel.dart';
import 'model.dart';

import '../createAccount/view.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController serverController = TextEditingController();
  final TextEditingController serverIPController = TextEditingController();

  final LoginViewModel viewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clear the server IP input
    serverIPController.clear();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SingleChildScrollView(
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
                      // Username using TextFormField
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

                      // Password using TextFormField
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !viewModel.isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.black),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                viewModel.togglePasswordVisibility();
                              });
                            },
                            child: Icon(
                              viewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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

                      // Create Account Button
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccount(
                                    serverIP: serverIPController.text.isNotEmpty
                                      ? "http://" + serverIPController.text.trim() + ":8080/" 
                                      : viewModel.selectedServer!.serverIP
                                  ),
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

                      // Login Button
                      const SizedBox(height: 30),
                      MaterialButton(
                        onPressed: () {
                          String serverIP = serverIPController.text.isNotEmpty
                            ? "http://" + serverIPController.text.trim() + ":8080/"
                            : viewModel.selectedServer!.serverIP;

                          // Connect to the server
                          viewModel.connect(serverIP, usernameController.text.trim());

                          // Attempt to login
                          viewModel.userLogin(context, usernameController.text.trim(), passwordController.text.trim());
                        },
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Server Selection
          if (viewModel.selectedServer != Servers.server4) ... {
            Positioned(
              bottom: 0,
              right: 0,
              child: DropdownMenu<Servers>(
                initialSelection: Servers.server1,
                controller: serverController,
                requestFocusOnTap: true,
                label: const Text('Server'),
                onSelected: (Servers? server) {
                  setState(() {
                    viewModel.setServer(server);
                  });
                },
                dropdownMenuEntries:
                Servers.values.map<DropdownMenuEntry<Servers>>((Servers server) {
                  return DropdownMenuEntry<Servers>(
                    value: server,
                    label: server.serverName,
                  );
                }).toList(),
              ),
            ),
          } else ... {
            // Server IP Input
            Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
                width: 200,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: serverIPController,
                        decoration: InputDecoration(
                          labelText: 'Server IP',
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
                    ),
                    // Close Button
                    const SizedBox(width: 10),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          viewModel.setServer(Servers.server1);
                        });
                      },
                      minWidth: 50,
                      height: 50,
                      color: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          }
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'viewModel.dart';

class CreateAccount extends StatefulWidget {
  String serverIP = "";

  CreateAccount({super.key, required this.serverIP});
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  SocketEvents socketEvents = SocketEvents();

  @override
  void initState() {
    super.initState();
    socketEvents.connect(widget.serverIP);
    socketEvents.createAccountResponse(context);
  }

  @override
  void dispose() {
    super.dispose();
    socketEvents.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.green,
            ),
            Container(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Image.asset('assets/Hi.png', width: 200, height: 220),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            // Screen description
            const SizedBox(height: 20),
            const Text(
              'Create your Account',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
            const Text(
              'Create your account to start collaborating',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.normal
              )
            ),

            // Username, Display Name, Password fields
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Create Username',
                      prefixIcon: const Icon(Icons.person, color: Colors.black, size: 18),
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
                    controller: displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter Display Name',
                      prefixIcon: const Icon(Icons.person, color: Colors.black, size: 18),
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
                      hintText: 'Create password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.black, size: 18),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => isPasswordVisible = !isPasswordVisible),
                        child: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black, size: 18),
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

                  // Create Account button
                  const SizedBox(height: 30),
                  MaterialButton(
                    onPressed: () {
                      socketEvents.createAccount(
                        context,
                        usernameController.text.trim(),
                        displayNameController.text.trim(),
                        passwordController.text.trim()
                      );
                    },
                    height: 45,
                    color: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: const Text('Create Account', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

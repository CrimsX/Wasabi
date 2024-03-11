import 'package:client/login/view.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(const MaterialApp(home: CreateAccount(),));

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController serverIPController = TextEditingController();
  final TextEditingController FirstNameController = TextEditingController();
  final TextEditingController LastNameController = TextEditingController();
  bool isPasswordVisible = false;


  late IO.Socket _socket; // Declare the _socket variable

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }



  void _initializeSocket() {
    // Assuming serverIPController contains the full server IP including protocol and port
    String serverIP = serverIPController.text.isNotEmpty ? "http://${serverIPController.text}" : 'http://192.168.56.1:3000';

    // Initialize socket connection
    _socket = IO.io(serverIP, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    // Optional: Setup listeners here if needed, similar to HomeScreen
    _socket.onConnect((_) {
      print('Connected to socket server at $serverIP');
    });
    _socket.onConnectError((data) {
      print('Connect Error: $data');
    });
  }

  void _showAccountCreatedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: const Text("Account Created!", style: TextStyle(color: Colors.white)),
          content: const Text("Your account has been successfully created.", style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _createAccount(BuildContext context) {
    String username = usernameController.text.trim();
    String firstname = FirstNameController.text.trim();
    String lastname = LastNameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both username and password."),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _socket.emit('createaccount', {'userID': username, 'Firstname': firstname, 'Lastname': lastname, 'password': password});
      _showAccountCreatedDialog(context);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.green),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                }
                  ),
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
                  const SizedBox(height: 20),
                  const Text('Create your Account', style: TextStyle(color: Colors
                .black, fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Create your account to start collaborating', style: TextStyle(color: Colors.black, fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.normal)),
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
                  TextFormField(
                    controller: FirstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      hintText: 'Enter First Name',
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
                  TextFormField(
                    controller: LastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Enter Last Name',
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

                  const SizedBox(height: 30),
                  MaterialButton(
                    onPressed: () => _createAccount(context),
                    height: 45,
                    color: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: const Text('Create Account', style: TextStyle(color: Colors.white)),
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
    _socket.disconnect();
    super.dispose();
  }
}

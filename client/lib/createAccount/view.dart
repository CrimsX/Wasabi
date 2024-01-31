import 'package:client/login/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model.dart';

//import 'package:client/screens/home.dart';
import 'package:client/home/view.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Homepage(),));

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController serverIPController = TextEditingController();
  bool isPasswordVisible = false;

  _login(BuildContext context, TextEditingController usernameController) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomePage(
          loggedInUsername: usernameController.text.trim(),
          serverIP: serverIPController.text.trim(),
        ),
      ),
    );
  }

  _showAccountCreatedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green, // Set the background color to green
          title: Text(
            "Account Created!",
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          content: Text(
            "Your account has been successfully created.",
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
          ],
        );
      },
    );
  }

  void _createAccount(BuildContext context) {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      // Show an error message if either username or password is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter both username and password."),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // If both fields are filled, show the "Account Created" dialog
      _showAccountCreatedDialog(context);
      // Add logic to create account if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              // Add the AppBar with a back button
              AppBar(
                backgroundColor: Colors.white,
                elevation: 0, // Remove shadow
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.green),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              Container(
                height: 300,
                color: Colors.white,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/Hi.png',
                          width: 200,
                          height: 220,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Text(
                'Create your Account',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Create your account to start collaborating',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),

              // For enter username:
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Create Username',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.black, size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // for enter password:
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create password',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.black, size: 18),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // For Create Account button:
                    SizedBox(height: 30),
                    MaterialButton(
                      onPressed: () {
                        _createAccount(context);
                      },
                      height: 45,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.lightGreen,
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Added bottom padding to the container
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
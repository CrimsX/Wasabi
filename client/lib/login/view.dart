/// Just redesigned log in
/// When Log in is clicked , we still go to home instead of menu
/// Tried fixing it, and was able to go to menu.dart and pass on the user name,
/// However when i navigate to home.dart from menu.dart
/// I can open the screen but there was an error.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model.dart';
import '../createAccount/view.dart';
//import 'package:client/screens/home.dart';
import 'package:client/home/view.dart';
import 'package:flutter/services.dart';

// Don't delete yet
/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context) => _ViewModel(),
      child: MaterialApp(
        title: "",
          home: _(),
      ),
    );
  }
}

class _ extends StatelessWidget {
    
}
*/

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
        builder: (_) => ChangeNotifierProvider(
          create: (context) => HomeProvider(),
            child: WelcomePage(
              loggedInUsername: usernameController.text.trim(),
              serverIP: serverIPController.text.trim()
            ),
          /*child: HomeScreen(
            username: usernameController.text.trim(),
          ),
          */
        ),
      ),
    );
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
              Container(
                height: 300,
                color: Colors.lightGreen,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/Wasabi.png',
                          width: 200,
                          height: 220,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
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
                        hintText: 'Enter your Username',
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
                        hintText: 'Enter your password',
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

                    // For server IP:
                    SizedBox(height: 20),
                    TextFormField(
                      controller: serverIPController,
                      decoration: InputDecoration(
                        labelText: 'Server IP (optional)',
                        hintText: 'Enter server IP',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.data_usage, color: Colors.black, size: 18),
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

                    // For Create Account:
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => createAccount(),
                               ),
                             );


                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.lightGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // For Log in:
                    SizedBox(height: 30),
                    MaterialButton(
                      onPressed: () {
                        _login(context, usernameController);
                      },
                      height: 45,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.lightGreen,
                      child: Text(
                        'Login',
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

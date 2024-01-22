import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:client/providers/home.dart';

import 'package:client/screens/home.dart';

import'package:flutter/services.dart';
/*
void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Homepage(),
  ),
);
*/

void main() => runApp(MaterialApp(home: Homepage(),));

void initState() => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

_login(BuildContext context, TextEditingController usernameController) {
  //final provider = Provider.of<LoginProvider>(context, listen: false);
  //provider.setErrorMessage('');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (context) => HomeProvider(),
        child: HomeScreen(
          username: usernameController.text.trim(),
        ),
      ),
    ),
  );
}
  
class Homepage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();

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
                color: Colors.green,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Text(
                          "Wasabi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60,  // Adjusted font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,  // Adjusted font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Container(
                  height: 200,
                  width: 600,
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle login button action
                      _login(context, usernameController);
                    },
                    child: Text('Log In'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password action
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model.dart';

import 'package:client/login/view.dart';
import 'package:client/messaging/view.dart';

import 'package:client/login/view_model.dart';
import 'package:client/login/model.dart';
import 'package:client/login/view.dart';

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

void main() {
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomePage(loggedInUsername: 'Username',
      serverIP: 'IP'),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}

class WelcomePage extends StatelessWidget {
  final String loggedInUsername;
  final String serverIP;

  WelcomePage({required this.loggedInUsername, required this.serverIP});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification button click
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => NotificationsScreen(),
              //   ),
              // );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Handle logout button click
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Homepage(), // Replace with your logout screen
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/Wasabi.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    loggedInUsername,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('My Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => MyProfileScreen(),
                //   ),
                // );
              },
            ),
            ListTile(
              title: Text('Collaborate'),
              leading: Icon(Icons.file_copy),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => CollaborateScreen(),
                //   ),
                // );
              },
            ),

            /// This is the button goes to home.dart and passed on the username.
            ListTile(
              title: Text('Messages'),
              leading: Icon(Icons.notifications),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (context) => HomeProvider(),
                      child: HomeScreen(
                        username: loggedInUsername,
                        serverIP: serverIP
                      ),
                    ),
                    //builder: (context) => HomeScreen(username: loggedInUsername),
                  ),
                );
              },
            ),

            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => SettingsScreen(),
                //   ),
                // );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/Welcome.png', // replace with your logo image path
                width: 300,
                height: 300,
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                "What's up, $loggedInUsername?",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "You don't have any listed tasks.",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

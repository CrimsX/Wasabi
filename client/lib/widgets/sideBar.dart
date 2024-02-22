import 'package:flutter/material.dart';

// Connection
import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

// Screens
import 'package:client/voice/view.dart';
import 'package:client/login/view.dart';
import 'package:client/groupvoice/view.dart';

import 'package:client/login/view.dart';
import 'package:client/messaging/view.dart';
import 'package:client/group/view.dart';

import 'package:client/messaging/view_model.dart';
import 'package:client/messaging/model.dart';
import 'package:client/messaging/view.dart';
import 'package:provider/provider.dart';


class sideBar extends StatelessWidget {
  String loggedInUsername = NetworkService.instance.getusername;
  String serverIP = NetworkService.instance.getserverIP;

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              title: Text('Notifications'),
              leading: Icon(Icons.notifications),
              onTap: () {
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

            ListTile(
              title: Text('Log Out'),
              leading: Icon(Icons.exit_to_app),
              onTap: () {
              // Handle logout button click
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(), // Replace with your logout screen
                ),
              );
              },
            ),

          ],
        ),
      );
  }
}

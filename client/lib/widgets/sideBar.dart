import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:client/home/view_model.dart';
import 'package:client/home/model.dart';

import 'package:client/services/network.dart';

import 'package:client/collaborate/view.dart';
import 'package:client/login/view.dart';

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

          // Handle profile button click
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

          // Handle notifications button click
          ListTile(
            title: Text('Notifications'),
            leading: Icon(Icons.notifications),
            onTap: () {
            },
          ),

          // Handle collaborate button click
          ListTile(
            title: Text('Collaborate'),
            leading: Icon(Icons.file_copy),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: Collaborate(
                      username: loggedInUsername,
                      serverIP: serverIP
                    ),
                  ),
                    //builder: (context) => HomeScreen(username: loggedInUsername),
                ),
              );
            },
          ),

          // Handle settings button click
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

          // Handle logout button click
          ListTile(
            title: Text('Log Out'),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

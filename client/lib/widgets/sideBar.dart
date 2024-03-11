import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:client/home/view_model.dart';

import 'package:client/services/network.dart';

import 'package:client/collaborate/view.dart';
import 'package:client/login/view.dart';

class sideBar extends StatelessWidget {
  String loggedInUsername = NetworkService.instance.getusername;
  String serverIP = NetworkService.instance.getserverIP;

  sideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
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

                const SizedBox(height: 10),
                Text(
                  loggedInUsername,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Handle profile button click
          ListTile(
            title: const Text('My Profile'),
            leading: const Icon(Icons.person),
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
            title: const Text('Notifications'),
            leading: const Icon(Icons.notifications),
            onTap: () {
            },
          ),

          // Handle collaborate button click
          ListTile(
            title: const Text('Collaborate'),
            leading: const Icon(Icons.file_copy),
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
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
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
            title: const Text('Log Out'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

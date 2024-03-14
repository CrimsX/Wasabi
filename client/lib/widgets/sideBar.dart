import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:provider/provider.dart';
import 'package:client/home/view_model.dart';

import 'package:client/services/network.dart';

import 'package:client/collaborate/view.dart';
import 'package:client/login/view.dart';

import 'package:client/collaborate/Calendar.dart';
import 'package:client/collaborate/Todo.dart';
import 'package:client/collaborate/Draw.dart';
import 'package:client/collaborate/Powerpoint.dart';
import 'package:client/collaborate/FileEditing.dart';

class sideBar extends StatelessWidget {
  sideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return myDrawer(); 
  }
}

class myDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String loggedInUsername = NetworkService.instance.getusername;
  String serverIP = NetworkService.instance.getserverIP;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        key: _scaffoldKey,

        drawer: collabDrawer(),

        body: ListView(
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
              },
            ),

            // Handle notifications button click
            ListTile(
              title: const Text('Notifications'),
              leading: const Icon(Icons.notifications),
              onTap: () {
              },
            ),

            ListTile(
              title: const Text('Collaborate'),
              leading: const Icon(Icons.file_copy),
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();


              /*
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
                ),
              );
              */
              
          


            },
          ),
                     // )},

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
      ),
    );
  }
}

class collabDrawer extends StatelessWidget {
  //const SecondDrawer({Key? key}) : super(key: key);

  String loggedInUsername = NetworkService.instance.getusername;
  String serverIP = NetworkService.instance.getserverIP;

  Socket? _socket = NetworkService.instance.socket;

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
              title: const Text('Calendar'),
              leading: const Icon(Icons.calendar_today),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: CalendarScreen(
                    username: loggedInUsername, 
                    serverIP: serverIP, socket: _socket
                    ),

                    

                  
                  ),
                ),
              );
              },
            ),

            // Handle todo List button click
            ListTile(
              title: const Text('Todo List'),
              leading: const Icon(Icons.checklist_rtl),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: TodoScreen(username: loggedInUsername, serverIP: serverIP, socket: _socket),
                  ),
                ),
              );
              },
            ),

            // Handle draw button click
            ListTile(
              title: const Text('Draw'),
              leading: const Icon(Icons.brush),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: const DrawScreen(),
                  ),
                ),
              );
              },
            ),

            // Handle powerpoint button click
            ListTile(
              title: const Text('Powerpoint'),
              leading: const Icon(Icons.slideshow),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: PowerPointScreen(username: loggedInUsername, serverIP: serverIP, socket: _socket),
                  ),
                ),
              );
              },
            ),

            // Handle document editing button click
            ListTile(
              title: const Text('File Editing'),
              leading: const Icon(Icons.edit),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: const FileEditingScreen(),
                  ),
                ),
              );
              },
            ),
    ],
    ),
    );
      
  }
}


import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

import 'package:provider/provider.dart';
import 'package:client/home/view_model.dart';

import 'package:client/login/view.dart';
import 'package:client/collaborate/documents/landingpage.dart';
import 'package:client/collaborate/Calendar.dart';
import 'package:client/collaborate/Todo.dart';
import 'package:client/collaborate/draw/view.dart';
import 'package:client/collaborate/slides/view.dart';


class userDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Socket? _socket = NetworkService.instance.socket;
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
              },
            ),

            // Handle settings button click
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
              },
            ),

            // Handle logout button click
            ListTile(
              title: const Text('Log Out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () {
                _socket?.disconnect();
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
  Socket? _socket = NetworkService.instance.socket;
  String loggedInUsername = NetworkService.instance.getusername;
  String serverIP = NetworkService.instance.getserverIP;

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
              Navigator.of(context)..pop()..pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: CalendarScreen(
                      username: loggedInUsername,
                      serverIP: serverIP,
                      socket: _socket
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
              Navigator.of(context)..pop()..pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: TodoScreen(
                      username: loggedInUsername,
                      serverIP: serverIP,
                      socket: _socket
                    ),
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
              Navigator.of(context)..pop()..pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: DrawScreen(
                      username: loggedInUsername,
                      socket: _socket
                    ),
                  ),
                ),
              );
            },
          ),

          // Handle slides button click
          ListTile(
            title: const Text('Slides'),
            leading: const Icon(Icons.slideshow),
            onTap: () {
              Navigator.of(context)..pop()..pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: SlidesView(),
                  ),
                ),
              );
            },
          ),

          // Handle document editing button click
          ListTile(
            title: const Text('Documents'),
            leading: const Icon(Icons.edit),
            onTap: () {
              Navigator.of(context)..pop()..pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => MessageProvider(),
                    child: DocumentsMenu( //DocumentsScreen
                        username: loggedInUsername,
                        serverIP: serverIP,
                        socket: _socket
                    ),
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

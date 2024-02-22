import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'view_model.dart';

import 'package:client/login/view.dart';
import 'package:client/messaging/view.dart';
import 'package:client/group/view.dart';

import 'package:client/messaging/view_model.dart';
import 'package:client/messaging/model.dart';
import 'package:client/messaging/view.dart';

import 'package:client/widgets/sideBar.dart';
import 'package:client/widgets/menuBar.dart';
import 'package:client/widgets/landingPage.dart';

import 'package:client/services/network.dart';

class Home extends StatefulWidget {
  final String loggedInUsername;
  final String serverIP;

  Home({required this.loggedInUsername, required this.serverIP});
  //@override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
 
    NetworkService.instance.init(
      serverIP: widget.serverIP,
      username: widget.loggedInUsername,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [ 
          menuBar(),
        ],
      ),
      drawer: 
        sideBar(),

      body:
        landingPage(),
    );
  }
}

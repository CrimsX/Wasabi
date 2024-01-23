import 'package:flutter/material.dart';

class GroupMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Messages'),
      ),
      body: Center(
        child: Text(
          'Group Messages Screen Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

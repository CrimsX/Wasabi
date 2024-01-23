import 'package:flutter/material.dart';

class CollaborateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collaborate'),
      ),
      body: Center(
        child: Text(
          'Collaborate Screen Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

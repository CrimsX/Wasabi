// profile.dart

import 'package:flutter/material.dart';

class MyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              'User Name', // Replace with the actual user name or fetch it from somewhere
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Add other profile information or content here
          ],
        ),
      ),
    );
  }
}

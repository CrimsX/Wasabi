import 'package:flutter/material.dart';

import 'package:client/services/network.dart';

class landingPage extends StatelessWidget {
  String loggedInUsername = NetworkService.instance.getusername;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Makes the body scrollable
      child: Padding(
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
                "What's up, ${loggedInUsername}?",
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

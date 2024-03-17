import 'package:flutter/material.dart';

import 'package:whiteboard/whiteboard.dart';

class DrawScreen extends StatelessWidget {
  const DrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw'),
        backgroundColor: Colors.green,
      ),
      /*
      body: Center(
        child: Image.asset('assets/DrawingImage.webp'),
      ),
      */
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: WhiteBoard(),
            ),
          ],
        ),
      ),
    );
  }
}

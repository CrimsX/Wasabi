import 'package:flutter/material.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Documents'),
      backgroundColor: Colors.green,
    ),
      body: Center(
        // Replace 'path_to_your_image' with your actual image path
        child: Image.asset('assets/FileEdit.webp'),
      ),
    );
  }
}

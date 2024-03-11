import 'package:flutter/material.dart';

class FileEditingScreen extends StatelessWidget {
  const FileEditingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Replace 'path_to_your_image' with your actual image path
        child: Image.asset('assets/FileEdit.webp'),
      ),
    );
  }
}

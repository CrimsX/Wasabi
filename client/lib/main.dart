import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:client/screens/login.dart';

void main() {
  runApp(const MyApp());
}
  
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     title: 'Wasabi',
     debugShowCheckedModeBanner: false,
     theme: ThemeData(
       primarySwatch: Colors.green,
     ),
      home: Homepage(),
    );
  }
}

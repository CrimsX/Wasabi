import 'package:flutter/material.dart'
import 'package:client/lib/screens/messaging.dart';

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
      home: ChangeNotiferProvider(
        create: (context) => HomeProvider(),
        child: const HomeScreen(),
      ),
    );
  }
}

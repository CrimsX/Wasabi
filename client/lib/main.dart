import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:client/login/view.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const WasabiApp());
}
  
class WasabiApp extends StatelessWidget {
  const WasabiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     title: 'Wasabi',
     /* dark mode?
     darkTheme: ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(),
     ),
     */
     // themeMode: ThemeMode.dark,
     debugShowCheckedModeBanner: false,
     theme: ThemeData(
       primarySwatch: Colors.green,
     ),
      home: const Login(),
    );
  }
}

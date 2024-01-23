import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context) => _ViewModel(),
      child: MaterialApp(
        title: "",
          home: _(),
      ),
    );
  }
}

class _ extends StatelessWidget {
    
}

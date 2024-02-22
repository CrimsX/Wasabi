import 'package:flutter/material.dart';
import 'model.dart';

//import 'package:flutter/foundation.dart';

class LoginViewModel {
  //final String _loggedInUsername = '';
  //final String _serverIP = '';
  final List<Login> _login = [];

  List <Login> get login => _login;
  //String get loggedinUsername => _loggedInUsername;
  //String get serverIP => _serverIP;

 // addNewLogin(Login login) {
 //   _login.add(login);
 //   notifyListeners();
 // }
}

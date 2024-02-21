import 'package:flutter/material.dart';
import 'model.dart';

//import 'package:flutter/foundation.dart';

class MessageProvider extends ChangeNotifier {
  final List<Message> _messages = [];

  List <Message> get messages => _messages;

  addNewMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }
}

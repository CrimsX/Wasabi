import 'package:flutter/foundation.dart';
import 'package:client/model/message.dart';

class HomeProvider extends ChangeNotifier {
    final List<Message> _messages = [];

    List <Message> get messages => _messages;

    addNewMessage(Message message) {
        _messages.add(message);
        notifyListeners();
      }
  }

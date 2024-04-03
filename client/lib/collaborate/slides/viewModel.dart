import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

import 'view.dart';
import 'model.dart';

import 'package:url_launcher/url_launcher.dart';

class slidesViewModel extends ChangeNotifier {
  slidesModel model = new slidesModel();
  List<dynamic> get powerpoints => model.powerpoints;
  List<dynamic> get WasabiSlides => model.WasabiSlides;
  List<dynamic> get friends => model.friends;
  List<dynamic> get groups => model.groups;

  late Socket? _socket = NetworkService.instance.socket;
  Socket get socket => _socket!;

  String username = NetworkService.instance.getusername;

  // Toggle between Website and Wasabi Slides
  void toggleIsWebsite() {
    model.isWebsite = !model.isWebsite;
    notifyListeners();
  }

  // Socket events
  void socketEvents() {
    socket!.on('getSlides', (data) {
      for (int i = 0; i < data.length; i++) {
        model.WasabiSlides.add(data[i]);
      }
    });

    socket!.on('getpowerpoints', (data) {
      for (int i = 0; i < data.length; i++) {
        model.powerpoints.add(data[i]);
      }
    });

    socket!.on('buildfriendscollab', (data) {
      model.friends.addAll(data);
    });

    socket!.on('buildgroupscollab', (data) {
      model.groups.addAll(data);
    });

    socket!.emit('getpowerpoints', username);
    socket!.emit('getSlides', username);

    socket!.emit('buildfriendscollab', username);
    socket!.emit('buildgroupscollab', username);
  }

  // Create a new google slides
  void createPowerpoint(BuildContext context) {
    TextEditingController addTitleController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New PowerPoint"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: addTitleController,
                  decoration: InputDecoration(hintText: "PowerPoint Title"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Next'),
              onPressed: () {
                if (addTitleController.text.isNotEmpty) {
                  launchUrl(Uri.parse('https://slides.google.com/create'));
                  Navigator.of(context).pop();
                  _enterLinkToPpt(context, addTitleController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Enter the link
  void _enterLinkToPpt(BuildContext context, title) {
    TextEditingController addURLController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Please enter PowerPoint URL"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: addURLController,
                  decoration: InputDecoration(hintText: "Insert PowerPoint URL"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (addURLController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  socket!.emit('createppt', {
                    'userID': NetworkService.instance.username,
                    'title': title,
                    'url': addURLController.text,
                  });
                  _reminder(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Reminder to change share settings
  void _reminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reminder"),
          content: Text("Remember to change share settings if you want to collaborate!"),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ]
        );
      }
    );
  }

  // Share a slides
  void shareForm(BuildContext context, Ppt, bool isWebsite) {
    int selectedOption = 0; // Track the selected radio button option

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Share Options"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RadioListTile(
                      title: Text('Share with friends'),
                      value: 0,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Share with group'),
                      value: 1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                TextButton(
                  child: Text('Next'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    shareSelect(context, selectedOption, Ppt, isWebsite);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Select who to share with
  void shareSelect(BuildContext context, option, Ppt, bool isWebsite) {
    List<dynamic> items = [];
    String key = "";
    if (option == 0){
      print(Ppt);
      items = model.friends;
      key = 'FriendID';
    } else if (option == 1) {
      items = model.groups;
      key = 'ServerName';
    }
    List<bool> checkedItems = List<bool>.filled(items.length, false); // Initialize with false values
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Items'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    items.length,
                    (index) {
                      return CheckboxListTile(
                        title: Text(items[index][key]),
                        value: checkedItems[index],
                        onChanged: (newValue) {
                          print('Checkbox $index tapped');
                          setState(() {
                            checkedItems[index] = newValue!;
                          });
                          print('Checkbox $index is now ${checkedItems[index]}');
                        },
                      );
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if(!isWebsite) {
                      // Perform actions based on the checked items
                      for (int i = 0; i < items.length; i++) {
                        if (checkedItems[i] && option == 0) {
                          print(Ppt);
                          socket!.emit('shareSlideFriend', {
                            'user': NetworkService.instance.getusername,
                            'name': Ppt['Name'],
                            'friend': model.friends[i][key],
                            }); 
                        } else if (checkedItems[i] && option == 1) {
                          socket!.emit('shareSlideServer', {
                            'group': model.groups[i][key],
                            'user': username,
                            'name': Ppt['Name'],
                          });
                        }
                      }
                    } else {
                      for (int i = 0; i < items.length; i++) {
                        if (checkedItems[i] && option == 0) {
                          socket!.emit('sharepptfriend', {
                            'user': model.friends[i][key],
                            'Ppt': Ppt
                          });
                        } else if (checkedItems[i] && option == 1) {
                          socket!.emit('sharepptgroup', {
                            'group': model.groups[i][key],
                            'Ppt': Ppt
                          });
                        }
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  } 
}

class wasabiSlidesViewModel extends ChangeNotifier {

}

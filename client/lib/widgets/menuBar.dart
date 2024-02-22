import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

import 'package:client/voice/view.dart';
import 'package:client/groupvoice/view.dart';

import 'package:client/messaging/view.dart';
import 'package:provider/provider.dart';
import 'package:client/messaging/view_model.dart';

import 'package:client/group/view.dart';

class menuBar extends StatelessWidget {
  String friend = NetworkService.instance.getFriend;
  String type = NetworkService.instance.getType;

  String loggedInUsername = NetworkService.instance.getusername;
  String serverIP = NetworkService.instance.getserverIP;

  // Join VoIP
  _joinCall(BuildContext context, {
    required String callerId,
    required String calleeId,
    dynamic offer,
    required bool showVid,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoIP(
          callerId: callerId,
          calleeId: calleeId,
          offer: offer,
          showVid: showVid,
        ),
      ),
    );
  }

  _joingroupCall(BuildContext context, {
    required String callerId,
    required List<String> groupcalleeId,
    dynamic offer,
    required bool showVid,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => groupVoIP(
          callerId: callerId,
          groupcalleeId: groupcalleeId,
          offer: offer,
          showVid: showVid,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Socket? _socket = NetworkService.instance.socket;

    String selfCallerID = NetworkService.instance.getselfCallerID;
    String remoteCallerID = NetworkService.instance.getRemoteCallerID;
    List<String> groupNames = NetworkService.instance.getGroupNames;
    List<String> groupCallerID = [];
    
    return Row(
      children: [
        IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              if (type == 'DM') {
              _socket!.emit("requestVoIPID", friend);
                remoteCallerID = NetworkService.instance.getRemoteCallerID;
                print(remoteCallerID);
                print(friend);

                if (remoteCallerID != 'Offline') {
                  _joinCall(
                    context,
                   callerId: selfCallerID,
                   calleeId: remoteCallerID,
                   showVid: false,
                  );
                }
              } else if (type == 'group') {
                  for (int i = 0; i < groupNames.length; i++) {
                    _socket!.emit("requestVoIPID", groupNames[i]);
                    //NetworkService.instance.addGroupCallerID(NetworkService.instance.getRemoteCallerID);
                  }
                  groupCallerID = NetworkService.instance.getGroupCallerID;

                if (groupCallerID.length != 0) {
                  _joingroupCall(
                    context,
                   callerId: selfCallerID,
                   groupcalleeId: groupCallerID,
                   showVid: false,
                  );
                }
                }

              },
            color: Colors.white
          ),

          IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () {
                if (type == 'DM') {
                //_receiveFriendVoIPID(context);
                //NetworkService.instance.socket!.emit!("requestVoIPID");
                _socket!.emit("requestVoIPID", friend);
                remoteCallerID = NetworkService.instance.getRemoteCallerID;
                print(remoteCallerID);
                print(friend);

                if (remoteCallerID != 'Offline') {
                  _joinCall(
                    context,
                   callerId: selfCallerID,
                   calleeId: remoteCallerID,
                   showVid: true,
                  );
                }
                } else if (type == 'group') {
                  for (int i = 0; i < groupNames.length; i++) {
                    _socket!.emit("requestVoIPID", groupNames[i]);
                    //NetworkService.instance.addGroupCallerID(NetworkService.instance.getRemoteCallerID);
                  }
                  groupCallerID = NetworkService.instance.getGroupCallerID;

                  /*
                  for (int j = 0; j < groupCallerID.length; j++) {
                    print(groupCallerID[j]);
                  }
                  */

                  //print(remoteCallerID);
                  //print(friend);
                  /*
                  for(int i = 0; i < groupCallerID.length; i++) {
                    print(groupCallerID[i]);
                  }
                  */

                if (groupCallerID.length != 0) {
                  _joingroupCall(
                    context,
                   callerId: selfCallerID,
                   groupcalleeId: groupCallerID,
                   showVid: true,
                  );
                }
                }

                /*
                // Handle video tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoIP(selfCallerId: selfCallerID),
                  ),
                );
                */
              },
              color: Colors.white,
          ),
          Padding(
            padding: EdgeInsets.only(right: 25),
          ),

          IconButton(
            icon: Icon(Icons.folder_copy_rounded),
            onPressed: () {
              // Handle Collaborate tap
            },
            color: Colors.white,
          ), 

          Padding(
            padding: EdgeInsets.only(right: 25),
          ),

          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // Handle Direct Message tap
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (context) => MessageProvider(),
                      child: HomeScreen(
                          username: loggedInUsername,
                          serverIP: serverIP
                      ),
                    ),
                    //builder: (context) => HomeScreen(username: loggedInUsername),
                  ),
              );
            },
            color: Colors.white,
          ),

          IconButton(
            icon: Icon(Icons.groups_2_rounded),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (context) => MessageProvider(),
                      child: Group(
                          username: loggedInUsername,
                          serverIP: serverIP
                      ),
                    ),
                    //builder: (context) => HomeScreen(username: loggedInUsername),
                  ),
                );

              //_scaffoldKey.currentState!.openEndDrawer();
            },
            color: Colors.white,
          ),
      ]
    );
  }
}

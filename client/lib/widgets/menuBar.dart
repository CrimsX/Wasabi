import 'package:flutter/material.dart';

// Connection
import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

// Screens
import 'package:client/voice/view.dart';
import 'package:client/login/view.dart';

class menuBar extends StatelessWidget {
  String friend = NetworkService.instance.getFriend;
  
  //String test3 = "sd";

  //_receiveFriendVoIPID(BuildContext context) {
    //print("test");
  /*
   NetworkService.instance.socket!.on(
      'r_VoIPID',
      (data) => _responseFriendVoIPID(data)
    );
   */
   //print(data);
  //}

  //_responseFriendVoIPID(data) {
  //  print(data);
    //print("test2");
    //NetworkService.instance.socket!.emit('s_VoIPID', "test");
  //}

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
  
  @override
  Widget build(BuildContext context) {
    Socket? _socket = NetworkService.instance.socket;

    String selfCallerID = NetworkService.instance.getselfCallerID;
    String remoteCallerID = NetworkService.instance.getRemoteCallerID;
    
    return Row(
      children: [
        IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
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
              },
            color: Colors.white
          ),

          IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () {
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

          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // Handle Direct Message tap
            },
            color: Colors.white,
          ),

          IconButton(
            icon: Icon(Icons.groups_2_rounded),
            onPressed: () {
              // Handle Group Message tap
            },
            color: Colors.white,
          ),

          IconButton(
            icon: Icon(Icons.folder_copy_rounded),
            onPressed: () {
              // Handle Collaborate tap
            },
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle Settings tap
            },
            color: Colors.white,
          ),

          IconButton(
            icon: Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              _socket!.disconnect();
              // Handle logout tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Homepage(), // Replace with your logout screen
                ),
              );
            },
            color: Colors.white,
          )
      ]
    );
  }
}

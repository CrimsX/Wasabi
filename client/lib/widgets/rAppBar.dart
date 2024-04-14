import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:client/services/network.dart';

import 'package:client/voice/view.dart';
import 'package:client/room/view.dart';

class rAppBar extends StatelessWidget {
  String friend = NetworkService.instance.getFriend;
  String type = NetworkService.instance.getType;

  String loggedInUsername = NetworkService.instance.getusername;
  String serverIP = NetworkService.instance.getserverIP;

  rAppBar({super.key});

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
    Socket? socket = NetworkService.instance.socket;

    String selfCallerID = NetworkService.instance.getselfCallerID;
    String remoteCallerID = NetworkService.instance.getRemoteCallerID;
    List<String> groupNames = NetworkService.instance.getGroupNames;
    List<String> groupCallerID = [];
    
    return Row(
      children: [
      /*
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            if (type == 'DM') {
              socket!.emit("requestVoIPID", friend);
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
                socket!.emit("requestVoIPID", groupNames[i]);
                //NetworkService.instance.addGroupCallerID(NetworkService.instance.getRemoteCallerID);
              }
              groupCallerID = NetworkService.instance.getGroupCallerID;

              if (groupCallerID.isNotEmpty) {
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
        */

        IconButton(
          icon: const Icon(Icons.video_call),
          onPressed: () {
            if (type == 'DM') {
              socket!.emit("requestVoIPID", friend);
              remoteCallerID = NetworkService.instance.getRemoteCallerID;
              print(remoteCallerID);
              if (remoteCallerID != 'Offline') {
                  socket!.emit("joinRoom", {'userName': loggedInUsername, 'calleeId': remoteCallerID});
                  socket!.emit("createRoom", {'roomName': loggedInUsername});
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomPage(
                    NetworkService.instance.room,
                    NetworkService.instance.getListener,
                  ),
                ),
              );
              }
              //NetworkService.instance.socket!.emit("joinRoom", {'userName': loggedInUsername, 'friend': friend});

                           
              //socket!.emit("createRoom");
              /*
              //_receiveFriendVoIPID(context);
              //NetworkService.instance.socket!.emit!("requestVoIPID");
              
              print(friend);

              if (remoteCallerID != 'Offline') {
                _joinCall(
                  context,
                  callerId: selfCallerID,
                  calleeId: remoteCallerID,
                  showVid: true,
                );
              }
              */
            } else if (type == 'group') {
              print(NetworkService.instance.roomName);
              NetworkService.instance.socket!.emit("createRoom", {'roomName': NetworkService.instance.roomName});
/*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomPage(
                    NetworkService.instance.room,
                    NetworkService.instance.getListener,
                  ),
                ),
              );*/
              /*
              for (int i = 0; i < groupNames.length; i++) {
                socket!.emit("requestVoIPID", groupNames[i]);
                //NetworkService.instance.addGroupCallerID(NetworkService.instance.getRemoteCallerID);
              }
              groupCallerID = NetworkService.instance.getGroupCallerID;
*/
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

                  /*

              if (groupCallerID.isNotEmpty) {
                _joingroupCall(
                  context,
                  callerId: selfCallerID,
                  groupcalleeId: groupCallerID,
                  showVid: true,
                );
              }
              */
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
        const Padding(
          padding: EdgeInsets.only(right: 25),
        ), 
      ]
    );
  }
}

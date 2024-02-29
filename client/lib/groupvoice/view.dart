import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../services/network.dart';

import 'package:client/widgets/rAppBar.dart';

class groupVoIP extends StatefulWidget {
  final String callerId; 
  final List<String> groupcalleeId;
  final dynamic offer;
  final bool showVid;
  const groupVoIP({
    super.key,
    this.offer,
    required this.callerId,
    required this.groupcalleeId,
    required this.showVid,
  });
  
  @override
  State<groupVoIP> createState() => _groupVoIPState();
}

class _groupVoIPState extends State<groupVoIP> {
  final socket = NetworkService.instance.socket;
  final _localRTCVideoRenderer = RTCVideoRenderer();
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  final _remoteRTCVideoRenderer2 = RTCVideoRenderer();

  //final List<RTCVideoRenderer> _remoteRTCVideoRenderers = [];

  MediaStream? _localStream;

  RTCPeerConnection? _rtcPeerConnection;

  RTCPeerConnection? _rtcPeerConnection2;

  List<RTCIceCandidate> rtcIceCadidates = [];
  List<RTCIceCandidate> rtcIceCadidates2 = [];

  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  @override
  void initState() {
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    _remoteRTCVideoRenderer2.initialize();

    //_remoteRTCVideoRenders = List.generate(widget.groupcalleeId.length, (index) => RTCVideoRenderer());

    /*
    for(var renderer in _remoteRTCVideoRenderers) {
        renderer.intialize();
    }
    */

    _setupPeerConnection();
    super.initState();

    isVideoOn = widget.showVid;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _setupPeerConnection() async {
    _rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    });

    
    _rtcPeerConnection2 = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun3.l.google.com:19302',
            'stun:stun4.l.google.com:19302'
          ]
        }
      ]
    });
    

    _rtcPeerConnection!.onTrack = (event) {
      //int index = widget.groupcalleeId.indexOf(event.track.id);
      /*
      for(int i = 0; i < widget.groupcalleeId.length; i++) {
        if (event.track.id == widget.groupcalleeId[i]) {
          _remoteRTCVideoRenderers[i].srcObject = event.streams[0];
          setState(() {});
        }
      }
      */

      /*
      if (index != -1) {
        _remoteRTCVideoRenderers[index].srcObject = event.streams[0];
        setState(() {});
      }
      */

      
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
      
    };

    
    _rtcPeerConnection2!.onTrack = (event) {
        _remoteRTCVideoRenderer2.srcObject = event.streams[0];
        setState(() {});
      };
    

    /*
    for (int i = 0; i < widget.groupcalleeId.length; i++) {
      _remoteRTCVideoRenderers.add(RTCVideoRenderer());
      await _remoteRTCVideoRenderers[i].initialize();
    }
    */

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
          ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
          : false,
    });

    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    if (widget.offer != null) {
      NetworkService.instance.socket!.on("IceCandidate", (data) {
        String candidate = data["iceCandidate"]["candidate"];
        String sdpMid = data["iceCandidate"]["id"];
        int sdpMLineIndex = data["iceCandidate"]["label"];

        _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex,
        ));
      });


      
      NetworkService.instance.socket!.on("IceCandidate", (data) {
        String candidate2 = data["iceCandidate"]["candidate"];
        String sdpMid2 = data["iceCandidate"]["id"];
        int sdpMLineIndex2 = data["iceCandidate"]["label"];

        _rtcPeerConnection2!.addCandidate(RTCIceCandidate(
          candidate2,
          sdpMid2,
          sdpMLineIndex2,
        ));
      });
      

      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      await _rtcPeerConnection2!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

      RTCSessionDescription answer2 = await _rtcPeerConnection2!.createAnswer();

      _rtcPeerConnection!.setLocalDescription(answer);

      _rtcPeerConnection2!.setLocalDescription(answer2);

      NetworkService.instance.socket!.emit("answerCall", {
        "callerId": widget.callerId,
        "sdpAnswer": answer.toMap(),
        "showVid": widget.showVid,
      });
    }
    else {
      _rtcPeerConnection!.onIceCandidate =
          (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

      NetworkService.instance.socket!.on("callAnswered", (data) async {
        await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

        for (RTCIceCandidate candidate in rtcIceCadidates) {
          //for (int i = 0; i < widget.groupcalleeId.length; i++) {
          NetworkService.instance.socket!.emit("IceCandidate", {
            "calleeId": widget.groupcalleeId[0],
            "iceCandidate": {
              "id": candidate.sdpMid,
              "label": candidate.sdpMLineIndex,
              "candidate": candidate.candidate
            }
          });
          }
        //}
        //)};
      });


    
      _rtcPeerConnection2!.onIceCandidate =
          (RTCIceCandidate candidate) => rtcIceCadidates2.add(candidate);

      NetworkService.instance.socket!.on("callAnswered", (data) async {
        await _rtcPeerConnection2!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

        for (RTCIceCandidate candidate in rtcIceCadidates2) {
          //for (int i = 0; i < widget.groupcalleeId.length; i++) {
          NetworkService.instance.socket!.emit("IceCandidate", {
            "calleeId": widget.groupcalleeId[1],
            "iceCandidate": {
              "id": candidate.sdpMid,
              "label": candidate.sdpMLineIndex,
              "candidate": candidate.candidate
            }
          });
          }
        //}
        //)};
      });

      


      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      RTCSessionDescription offer2 = await _rtcPeerConnection2!.createOffer();

      await _rtcPeerConnection!.setLocalDescription(offer);

      await _rtcPeerConnection2!.setLocalDescription(offer2);

      //print(offer.toMap());
      for (int i = 0; i < widget.groupcalleeId.length; i++) 
        NetworkService.instance.socket!.emit("makeCall", {
          "calleeId": widget.groupcalleeId[i],
          "sdpOffer": offer.toMap(),
          "showVid": widget.showVid,
        });
    }
  }

  _leaveCall() {
    Navigator.pop(context);
  }

  _toggleMic() {
    isAudioOn = !isAudioOn;

    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    isVideoOn = !isVideoOn;

    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(""),
        actions: [
          rAppBar(),
        ],
        backgroundColor: Colors.green,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(children: [
              Positioned(
              left:50,
              top: 80,
              child: SizedBox(
              height: 400,
              width: 400,
              child: RTCVideoView(
                  _remoteRTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                ),
                ),
                
                Positioned(
                right:50,
                top: 80,
                child: SizedBox(
                height: 400,
                width: 400,
                child: RTCVideoView(
                  _remoteRTCVideoRenderer2,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                ),
                ),
                
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: SizedBox(
                    height: 150,
                    width: 120,
                    child: RTCVideoView(
                      _localRTCVideoRenderer,
                      mirror: isFrontCameraSelected,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
                    onPressed: _toggleMic,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end),
                    iconSize: 30,
                    onPressed: _leaveCall,
                  ),
                  if (isVideoOn == true)
                  IconButton(
                    icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer2.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    _rtcPeerConnection2?.dispose();
    super.dispose();
  }
}

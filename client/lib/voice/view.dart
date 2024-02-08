import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../services/network.dart';

import 'package:client/widgets/menuBar.dart';

class VoIP extends StatefulWidget {
  final String callerId, calleeId;
  final dynamic offer;
  final bool showVid;
  const VoIP({
    super.key,
    this.offer,
    required this.callerId,
    required this.calleeId,
    required this.showVid,
  });
  
  @override
  State<VoIP> createState() => _VoIPState();
}

class _VoIPState extends State<VoIP> {
  final socket = NetworkService.instance.socket;
  final _localRTCVideoRenderer = RTCVideoRenderer();
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  MediaStream? _localStream;

  RTCPeerConnection? _rtcPeerConnection;

  List<RTCIceCandidate> rtcIceCadidates = [];

  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  @override
  void initState() {
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

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

    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

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
 
      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

      _rtcPeerConnection!.setLocalDescription(answer);

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
          NetworkService.instance.socket!.emit("IceCandidate", {
            "calleeId": widget.calleeId,
            "iceCandidate": {
              "id": candidate.sdpMid,
              "label": candidate.sdpMLineIndex,
              "candidate": candidate.candidate
            }
          });
        }
      });

      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      await _rtcPeerConnection!.setLocalDescription(offer);

      //print(offer.toMap());
      NetworkService.instance.socket!.emit("makeCall", {
        "calleeId": widget.calleeId,
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
          menuBar(),
        ],
        backgroundColor: Colors.green,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(children: [
                RTCVideoView(
                  _remoteRTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
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
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    super.dispose();
  }
}

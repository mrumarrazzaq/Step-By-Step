import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stepbystep/colors.dart';

// Generate an Agora token

// -${Random().nextInt(10000)}
class VideoCall extends StatefulWidget {
  const VideoCall({Key? key, required this.token}) : super(key: key);
  final String token;
  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  String appId = "f6a59f6c0f794394af3604bb174cb945";

  final channel = "sbs";

  int uid = 0;
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    log('---------------------------');
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    log('*************************************************');
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          log('************************* LOCAL USER JOINED *************************');
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          log('************************* REMOTE USER JOINED *************************');
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          log('************************* REMOTE USER LEFT *************************');
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: widget.token,
      channelId: channel,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
    setState(() {
      _localUserJoined = true;
    });
    log('************************* SUCCESSFULLY JOINED *************************');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        // leading: IconButton(
        //   onPressed: () async {
        //     await fetchToken(uid, channel, tokenRole);
        //   },
        //   icon: Icon(Icons.arrow_back),
        // ),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 100,
              height: 150,
              margin: const EdgeInsets.only(bottom: 40, right: 20),
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : CircularProgressIndicator(color: AppColor.orange),
              ),
            ),
          ),
          Visibility(
            visible: _localUserJoined,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                margin: const EdgeInsets.only(bottom: 20),
                child: InkWell(
                  onTap: () {
                    leave();
                    _remoteUid = null;
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 35.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  void join() async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await _engine.joinChannel(
      token: widget.token,
      channelId: channel,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      // _isJoined = false;
      _remoteUid = null;
    });
    _engine.leaveChannel();
  }

  // Clean up the resources when you leave
  @override
  void dispose() async {
    super.dispose();
    await _engine.leaveChannel();
  }
}

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String appId = "<--Insert app ID here-->";

class AudioCall extends StatefulWidget {
  const AudioCall({Key? key, required this.token}) : super(key: key);
  final String token;
  @override
  State<AudioCall> createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  String appId = "f6a59f6c0f794394af3604bb174cb945";
  final channel = "sbs";

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVoiceSDKEngine();
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
      RtcEngineContext(appId: appId),
    );

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
    setState(() {
      _isJoined = true;
    });
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Voice Calling'),
        ),
        body: Stack(
          // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          children: [
            // Status text
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 40,
                child: Center(
                  child: _status(),
                ),
              ),
            ),
            // Button Row
            Visibility(
              visible: !_isJoined,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: () {
                      setupVoiceSDKEngine();
                    },
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 35.0,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isJoined,
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
        ));
  }

  Widget _status() {
    String statusText;

    if (!_isJoined) {
      statusText = 'Join a channel';
    } else if (_remoteUid == null) {
      statusText = 'Waiting for a remote user to join...';
    } else {
      statusText = 'Connected to remote user, id:$_remoteUid';
    }

    return Text(
      statusText,
    );
  }

  Future<void> join() async {
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: widget.token,
      channelId: channel,
      options: options,
      uid: uid,
    );
    log('Joined Call **********');
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  // Clean up the resources when you leave
  @override
  void dispose() async {
    super.dispose();
    await agoraEngine.leaveChannel();
  }
}

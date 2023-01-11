import 'package:flutter/material.dart';
import 'package:record/record.dart';

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({Key? key}) : super(key: key);

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  final recorder = Record();

  bool isRecording = false;
  @override
  void initState() {
    super.initState();
    // initRecorder();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // StreamBuilder(
          //   stream: recorder.onProgress,
          //   builder: (context, snapshot) {
          //     final duration =
          //         snapshot.hasData ? snapshot.data!.duration : Duration.zero;
          //     return Text('${duration.inSeconds} s');
          //   },
          // ),
          ElevatedButton(
              onPressed: () async {
                isRecording = await recorder.isRecording();
                print(isRecording);
                if (isRecording) {
                  await stop();
                } else {
                  await record();
                }
                setState(() {});
              },
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                size: 80,
              )),
        ],
      ),
    );
  }

  Future stop() async {
    await recorder.stop();
  }

  Future record() async {
    if (await recorder.hasPermission()) {
      // Start recording
      await recorder.start(
        path: 'aFullPath/myFile.m4a',
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
      );
    }
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class VoiceMessage extends StatefulWidget {
  VoiceMessage(
      {Key? key,
      required this.url,
      required this.messageStatus,
      required this.time,
      required this.color,
      required this.left,
      required this.right})
      : super(key: key);
  String url;
  int messageStatus;
  String time;
  Color color;
  double left;
  double right;

  @override
  VoiceMessageState createState() => VoiceMessageState();
}

class VoiceMessageState extends State<VoiceMessage> {
  bool _isPlaying = false;
  bool _isPaused = false;

  late AudioPlayer _audioPlayer;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state.toString() == 'PlayerState.PLAYING') {
        _isPlaying = true;
        print('$state $_isPlaying');
      }
      if (state.toString() == 'PlayerState.STOPPED') {
        print('$state $_isPlaying');
      }
      if (state.toString() == 'PlayerState.COMPLETED') {
        _audioPlayer.stop();
        _isPlaying = false;
        print('$state $_isPlaying');
      }
      if (mounted) {
        setState(() {});
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    _audioPlayer.onAudioPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
          print(position);
          print('========');
          print(position.inSeconds);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: widget.color,
      margin:
          EdgeInsets.only(left: widget.left, bottom: 3, right: widget.right),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (!_isPlaying) {
                    print('PLAY');
                    _audioPlayer.play(widget.url);
                    _isPlaying = true;
                    _isPaused = false;
                    setState(() {});
                  } else if (!_isPaused) {
                    print('PAUSED');
                    _audioPlayer.pause();
                    _isPlaying = false;
                    _isPaused = true;
                    setState(() {});
                  }
                },
                icon:
                    Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 30),
              ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                activeColor: widget.color,
                inactiveColor: AppColor.grey,
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  print(value);
                  print('-----------');
                  print(position);
                  await _audioPlayer.seek(position);
                  // setState(() {});
                  await _audioPlayer.resume();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _printDuration(duration),
                style: TextStyle(fontSize: 12, color: AppColor.grey),
              ),
              const SizedBox(width: 100),
              Text(
                widget.time,
                style: TextStyle(fontSize: 12, color: AppColor.grey),
              ),
              Icon(
                  widget.messageStatus == 0
                      ? Icons.check
                      : Icons.access_time_sharp,
                  size: 15,
                  color: Colors.grey[400]),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      // ListTile(
      //   dense: true,
      //   minLeadingWidth: 0,
      //   leading: IconButton(
      //     onPressed: () {
      //       if (!_isPlaying) {
      //         _audioPlayer.play(widget.url);
      //         _isPlaying = true;
      //       } else {
      //         _audioPlayer.stop();
      //         _isPlaying = false;
      //       }
      //       setState(() {});
      //     },
      //     icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 30),
      //   ),
      //   title: Slider(
      //     min: 0,
      //     max: position.inSeconds.toDouble(),
      //     value: position.inSeconds.toDouble(),
      //     activeColor: widget.color,
      //     inactiveColor: AppColor.grey,
      //     onChanged: (value) async {
      //       final position = Duration(seconds: value.toInt());
      //       await _audioPlayer.seek(position);
      //
      //       await _audioPlayer.resume();
      //     },
      //   ),
      //   // subtitle: Row(
      //   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   //   children: [
      //   //     Text(_printDuration(position)),
      //   //     Text(_printDuration(duration - position)),
      //   //   ],
      //   // ),
      //   subtitle: Icon(
      //       widget.messageStatus == 0 ? Icons.check : Icons.access_time_sharp,
      //       size: 15,
      //       color: Colors.grey[400]),
      // ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

enum PlayerState { PLAYING, COMPLETED, STOPPED }

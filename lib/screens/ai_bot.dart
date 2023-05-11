import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/app_bot_utils/utils.dart';
import 'package:stepbystep/services/scan_text_service.dart';
import 'package:stepbystep/services/speech_to_text_service.dart';
import 'package:stepbystep/services/text_to_speech_service.dart';
import 'package:stepbystep/widgets/highlight_sub_string.dart';

//import 'package:alan_voice/alan_voice.dart';
// intent('hello world', p => {
// p.play('(hello|hi there)');
// });

class BotUI extends StatefulWidget {
  const BotUI({Key? key}) : super(key: key);

  @override
  _BotUIState createState() => _BotUIState();
}

class _BotUIState extends State<BotUI> {
  // _SearchState() {
  //   /// Init Alan Button with project key from Alan Studio
  //   AlanVoice.addButton(
  //       "b257d59e01d109f40da0e9ffb3917afc2e956eca572e1d8b807a3e2338fdd0dc/stage",
  //       bottomMargin: 50);
  //
  //   /// Handle commands from Alan Studio
  //   AlanVoice.onCommand.add((command) {
  //     debugPrint("got new command ${command.toString()}");
  //   });
  // }
  String text =
      'Hi! Welcome to Step By Step Family. I am your personal assistant .I am here to resolve your issues. You can ask me any query about this application. How can i help you?';
  String reply = '';
  bool isListening = false;
  bool isBotVisible = true;
  FlutterTts flutterTts = FlutterTts();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: !isListening,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Lottie.asset(
                        height: 200,
                        'animations/robot-bot-3d.json',
                      ),
                    ),
                    const Text('Ack Your Queries From Me'),
                    const Text(
                      'Press the button and start speaking',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Visibility(
                      visible: !isListening,
                      child: TextToSpeechService(voiceText: text),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: true,
                child: SingleChildScrollView(
                  reverse: true,
                  padding: const EdgeInsets.all(30).copyWith(bottom: 150),
                  child: SubstringHighlight(
                    text: text,
                    terms: Command.all,
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    textStyleHighlight: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        endRadius: 75,
        glowColor: Theme.of(context).primaryColor,
        child: FloatingActionButton(
          onPressed: toggleRecording,
          child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 36),
        ),
      ),
    );
  }

  Future toggleRecording() => SpeechToTextService.toggleRecording(
        onResult: (text) => setState(() {
          this.text = text;
        }),
        onListening: (isListening) {
          setState(() {
            this.isListening = isListening;
            if (isListening) {
              text = '';
              isBotVisible = false;
            }
          });

          if (!isListening) {
            reply = text;
            log(reply.toString());
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                text = '';
              });
            });
          }
          Future.delayed(const Duration(seconds: 4), () async {
            setState(() {
              text = ScanText.scan(reply);
            });

            await flutterTts.setVolume(1.0);
            await flutterTts.setSpeechRate(0.4);
            await flutterTts.setPitch(1.0);

            if (text.isNotEmpty) {
              await flutterTts.speak(text);
            }

            setState(() {
              text = '';
              isBotVisible = true;
            });
          });
        },
      );
}

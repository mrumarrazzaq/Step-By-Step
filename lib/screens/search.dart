import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/apis/speech_api.dart';
import 'package:stepbystep/app_utils/utils.dart';
import 'package:stepbystep/widgets/highlight_sub_string.dart';
//import 'package:alan_voice/alan_voice.dart';

// intent('hello world', p => {
// p.play('(hello|hi there)');
// });

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
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
  String text = 'Press the button and start speaking';
  bool isListening = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   child: Lottie.network(
        //       'https://assets2.lottiefiles.com/packages/lf20_ofa3xwo7.json'),
        // ),
        SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(30).copyWith(bottom: 150),
          child: SubstringHighlight(
            text: text,
            terms: Command.all,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            textStyleHighlight: const TextStyle(
              fontSize: 32.0,
              color: Colors.red,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        AvatarGlow(
          animate: isListening,
          endRadius: 75,
          glowColor: Theme.of(context).primaryColor,
          child: FloatingActionButton(
            onPressed: toggleRecording,
            child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 36),
          ),
        ),
      ],
    );
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => this.text = text),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);

          if (!isListening) {
            Future.delayed(const Duration(seconds: 1), () {
              Utils.scanText(text);
            });
          }
        },
      );
}

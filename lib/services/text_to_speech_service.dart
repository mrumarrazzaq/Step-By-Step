import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TextToSpeechService extends StatefulWidget {
  final String voiceText;

  const TextToSpeechService({Key? key, required this.voiceText})
      : super(key: key);
  @override
  _TextToSpeechServiceState createState() => _TextToSpeechServiceState();
}

class _TextToSpeechServiceState extends State<TextToSpeechService> {
  late FlutterTts flutterTts;
  String language = 'en-US';

  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();
    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
      _speak();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        log('Playing');
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          log('TTS Initialized');
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        log('Complete');
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        log('Cancel');
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        log('Paused');
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        log('Continued');
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        log('error: $msg');
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      log('Getting getDefaultEngine');
      log(engine.toString());
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      log('________________________________');
      log(voice.toString());
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);

    if (widget.voiceText.isNotEmpty) {
      await flutterTts.speak(widget.voiceText);
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
    flutterTts.setLanguage('en-US');
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(
        DropdownMenuItem(
          value: type as String?,
          child: Text(type as String),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btnSection(),
          // _futureBuilder(),
        ],
      ),
    );
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return const Text('Error loading languages...');
        } else {
          return const Text('Loading Languages...');
        }
      });

  Widget _btnSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
        _buildButtonColumn(
            Colors.blue, Colors.blueAccent, Icons.pause, 'PAUSE', _pause),
      ],
    );
  }

  Widget _languageDropDownSection(dynamic languages) => Container(
        padding: const EdgeInsets.only(top: 0.0),
        child: DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: (String? selectedType) {
            setState(
              () {
                language = selectedType!;
                log(
                  language.toString(),
                );
                flutterTts.setLanguage(language);
                if (isAndroid) {
                  flutterTts.isLanguageInstalled(language).then(
                        (value) => isCurrentLanguageInstalled = (value as bool),
                      );
                }
              },
            );
          },
        ),
      );

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon),
          color: color,
          splashColor: splashColor,
          onPressed: () => func(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12.0, fontWeight: FontWeight.w400, color: color),
          ),
        )
      ],
    );
  }
}

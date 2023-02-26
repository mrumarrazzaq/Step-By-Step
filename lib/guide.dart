import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';

class Guide extends StatefulWidget {
  const Guide({Key? key}) : super(key: key);

  @override
  State<Guide> createState() => _GuideState();
}

class _GuideState extends State<Guide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroStepBuilder(
        /// Guide order, can not be repeated with other
        order: 1,

        /// At least one of text and overlayBuilder
        /// Use text to quickly add leading text
        text: 'guide text',

        /// Using overlayBuilder can be more customized, please refer to advanced usage in example
        overlayBuilder: (params) {
          return Text('ABC');
        },

        /// You can specify configuration for individual guide here
        borderRadius: const BorderRadius.all(Radius.circular(64)),
        builder: (context, key) => Column(
          children: [
            Text('Umar'),
          ],
        ),
      ),
    );
  }
}

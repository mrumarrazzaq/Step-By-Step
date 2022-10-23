import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  AppDivider({Key? key, required this.text, required this.color})
      : super(key: key);
  String text;
  Color color;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 20.0),
          child: Divider(
            color: color,
            height: 36,
          ),
        ),
      ),
      Text(text),
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(left: 20.0, right: 10.0),
          child: Divider(
            color: color,
            height: 36,
          ),
        ),
      ),
    ]);
  }
}

import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  AppElevatedButton({
    Key? key,
    required this.text,
    required this.textColor,
    required this.function,
    this.backgroundColor = Colors.orange,
    this.foregroundColor = Colors.white,
    this.borderSideColor = Colors.transparent,
    this.width = 80,
    this.height = 35,
    this.fontSize = 10,
  }) : super(key: key);
  String text;
  Color textColor;
  Color foregroundColor;
  Color backgroundColor;
  Color borderSideColor;
  Function() function;
  double width;
  double height;
  double fontSize;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: function,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(Size(width, height)),
        foregroundColor: MaterialStateProperty.all<Color>(foregroundColor),
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(color: borderSideColor),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
    );
  }
}

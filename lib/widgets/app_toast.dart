import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stepbystep/colors.dart';

class AppToast extends StatelessWidget {
  AppToast(
      {Key? key,
      required this.widget,
      required this.color,
      this.height = 40,
      this.width = 200,
      this.radius = 10})
      : super(key: key);
  double width;
  double height;
  double radius;
  Color color;
  List<Widget> widget;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: widget,
      ),
    );
  }
}

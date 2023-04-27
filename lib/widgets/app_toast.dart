import 'package:flutter/material.dart';

class AppToast extends StatelessWidget {
  const AppToast(
      {Key? key,
      required this.widget,
      required this.color,
      this.height = 40,
      this.width = 200,
      this.radius = 10})
      : super(key: key);
  final double width;
  final double height;
  final double radius;
  final Color color;
  final List<Widget> widget;
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

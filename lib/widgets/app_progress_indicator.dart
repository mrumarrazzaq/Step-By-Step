import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    Key? key,
    this.size = 10,
    this.radius = 25,
    this.strokeWidth = 4.0,
    this.bgColor = Colors.black,
    this.circleBgColor = const Color(0xFFFF4C00),
    this.circleColor = Colors.white,
  }) : super(key: key);
  final double size;
  final double radius;
  final double strokeWidth;
  final Color bgColor;
  final Color circleColor;
  final Color circleBgColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: AppColor.black,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColor.white,
            backgroundColor: AppColor.orange,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

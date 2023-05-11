import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:stepbystep/colors.dart';

class AppDialog3 extends StatelessWidget {
  const AppDialog3({Key? key, required this.imageUrl, required this.text})
      : super(key: key);
  final String imageUrl;
  final String text;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      alignment: Alignment.center,
      backgroundColor: AppColor.lightOrange,
      titlePadding: EdgeInsets.zero,
      title: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(imageUrl),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.titilliumWeb(),
          ),
        ],
      ),
    );
  }
}

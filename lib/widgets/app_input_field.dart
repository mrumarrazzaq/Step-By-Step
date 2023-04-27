// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class RoundedInputField extends StatefulWidget {
  RoundedInputField(
      {Key? key,
      required this.label,
      required this.hint,
      this.radius = 30.0,
      required this.textInputType,
      this.isFieldDisable = true,
      this.enableSuffixIcon = false,
      this.obscureText = false,
      required this.prefixIcon,
      required this.controller,
      this.validate})
      : super(key: key);

  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isFieldDisable;
  final bool enableSuffixIcon;
  bool obscureText;
  final double radius;
  final TextInputType textInputType;
  final TextEditingController controller;
  String? Function(String?)? validate;
  @override
  State<RoundedInputField> createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: TextFormField(
        keyboardType: widget.textInputType,
        cursorColor: AppColor.black,
        obscureText: widget.obscureText,
        style: TextStyle(color: AppColor.black),
        decoration: InputDecoration(
          isDense: true,
          enabled: widget.isFieldDisable ? false : true,
          // fillColor: purpleColor,
          // filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(color: AppColor.grey, width: 2.0),
          ),

          hintText: widget.hint,
          // hintStyle: TextStyle(color: purpleColor),
          label: Text(
            widget.label,
            style: TextStyle(color: AppColor.grey),
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: AppColor.black,
          ),
          prefixText: '  ',
          suffixIcon: Visibility(
            visible: widget.enableSuffixIcon,
            child: GestureDetector(
              child: widget.obscureText
                  ? Icon(
                      Icons.visibility,
                      size: 18.0,
                      color: AppColor.black,
                    )
                  : Icon(
                      Icons.visibility_off,
                      size: 18.0,
                      color: AppColor.black,
                    ),
              onTap: () {
                setState(() {
                  widget.obscureText = !widget.obscureText;
                });
              },
            ),
          ),
        ),
        controller: widget.controller,
        validator: widget.validate,
      ),
    );
  }
}

class AppInputField extends StatefulWidget {
  const AppInputField(
      {Key? key,
      required this.label,
      required this.hint,
      required this.textInputType,
      this.maxLines = 1,
      required this.controller,
      this.validate})
      : super(key: key);

  final String label;
  final String hint;
  final TextInputType textInputType;
  final int maxLines;
  final TextEditingController controller;
  final String? Function(String?)? validate;

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: TextFormField(
        keyboardType: widget.textInputType,
        cursorColor: AppColor.black,
        maxLines: widget.maxLines,
        style: TextStyle(color: AppColor.black),
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: AppColor.grey, width: 1.5),
          ),

          hintText: widget.hint,
          // hintStyle: TextStyle(color: purpleColor),
          label: Text(
            widget.label,
            style: TextStyle(color: AppColor.black),
          ),
        ),
        controller: widget.controller,
        validator: widget.validate,
      ),
    );
  }
}

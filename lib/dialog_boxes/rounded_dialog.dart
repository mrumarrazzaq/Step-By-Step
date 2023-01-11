import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

Future<dynamic> openAlertBox(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          contentPadding: const EdgeInsets.only(top: 10.0),
          content: SizedBox(
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Rate",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.star_border,
                          color: AppColor.grey,
                          size: 30.0,
                        ),
                        Icon(
                          Icons.star_border,
                          color: AppColor.grey,
                          size: 30.0,
                        ),
                        Icon(
                          Icons.star_border,
                          color: AppColor.grey,
                          size: 30.0,
                        ),
                        Icon(
                          Icons.star_border,
                          color: AppColor.grey,
                          size: 30.0,
                        ),
                        Icon(
                          Icons.star_border,
                          color: AppColor.grey,
                          size: 30.0,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Divider(
                  color: Colors.grey,
                  height: 4.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Add Review",
                      border: InputBorder.none,
                    ),
                    maxLines: 8,
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      color: AppColor.grey,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32.0),
                          bottomRight: Radius.circular(32.0)),
                    ),
                    child: Text(
                      "Rate Product",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

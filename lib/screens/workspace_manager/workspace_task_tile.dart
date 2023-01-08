import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/colors.dart';

class WorkspaceTaskTile extends StatelessWidget {
  bool isOwner;
  String workspaceTaskCode;
  String docId;
  String title;
  String description;
  String email;
  String date;
  int taskStatusValue;
  Color color;
  bool leftButton;
  bool rightButton;
  WorkspaceTaskTile({
    Key? key,
    required this.isOwner,
    required this.workspaceTaskCode,
    required this.docId,
    required this.title,
    required this.description,
    required this.email,
    required this.date,
    required this.taskStatusValue,
    required this.color,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        log(docId);
        await FirebaseFirestore.instance
            .collection(workspaceTaskCode)
            .doc(docId)
            .delete();
        await Fluttertoast.showToast(
          msg: 'Task Deleted Successfully', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          backgroundColor: Colors.grey,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(left: 10, bottom: 10, top: 10, right: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Container(
            width: double.infinity,
            // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              border: Border(
                right: BorderSide(color: color, width: 10),
              ),
              //borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: double.infinity,
              // margin:
              // const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Task Title      :  ',
                          style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: title,
                          style: TextStyle(
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Assigned By :  ',
                          style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: email,
                          style: TextStyle(
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Due Date       :  ',
                          style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: date,
                          style: TextStyle(
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: leftButton,
                        child: GestureDetector(
                          onTap: () async {
                            if (leftButton) {
                              log('LB Task Status Value : ${taskStatusValue - 1}');
                              await FirebaseFirestore.instance
                                  .collection(workspaceTaskCode)
                                  .doc(docId)
                                  .update({
                                'Task Status': isOwner
                                    ? taskStatusValue - 2
                                    : taskStatusValue - 1,
                              });
                            }
                          },
                          child: RotatedBox(
                              quarterTurns: 2,
                              child: Lottie.asset(
                                  height: 20, 'animations/arrow.json')),
                        ),

                        // IconButton(
                        //   onPressed: () async {
                        //     if (leftButton) {
                        //       log('LB Task Status Value : ${taskStatusValue - 1}');
                        //       await FirebaseFirestore.instance
                        //           .collection(workspaceTaskCode)
                        //           .doc(docId)
                        //           .update({
                        //         'Task Status': isOwner
                        //             ? taskStatusValue - 2
                        //             : taskStatusValue - 1,
                        //       });
                        //     }
                        //   },
                        //   icon: const Icon(Icons.arrow_back),
                        // ),
                      ),
                      Visibility(
                        visible: rightButton,
                        child: GestureDetector(
                          onTap: () async {
                            if (rightButton) {
                              log('RB Task Status Value : ${taskStatusValue + 1}');
                              await FirebaseFirestore.instance
                                  .collection(workspaceTaskCode)
                                  .doc(docId)
                                  .update({
                                'Task Status': taskStatusValue + 1,
                              });
                            }
                          },
                          child:
                              Lottie.asset(height: 20, 'animations/arrow.json'),
                        ),
                        // IconButton(
                        //   onPressed: () async {
                        //     if (rightButton) {
                        //       log('RB Task Status Value : ${taskStatusValue + 1}');
                        //       await FirebaseFirestore.instance
                        //           .collection(workspaceTaskCode)
                        //           .doc(docId)
                        //           .update({
                        //         'Task Status': taskStatusValue + 1,
                        //       });
                        //     }
                        //   },
                        //   icon: const Icon(
                        //     Icons.arrow_forward,
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

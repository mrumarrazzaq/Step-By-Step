import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/apis/app_functions.dart';
import 'package:stepbystep/apis/messege_notification_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';

class WorkspaceTaskTile extends StatefulWidget {
  bool isOwner;
  String workspaceCode;
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
    required this.workspaceCode,
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
  State<WorkspaceTaskTile> createState() => _WorkspaceTaskTileState();
}

class _WorkspaceTaskTileState extends State<WorkspaceTaskTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        showTaskDeletionDialog(
          context: context,
          taskTitle: widget.title,
          workspaceTaskCode: widget.workspaceTaskCode,
          docId: widget.docId,
        );
        log(widget.docId);
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
              color: widget.color,
              border: Border(
                right: BorderSide(color: widget.color, width: 10),
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
                          text: widget.title,
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
                          text: widget.email,
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
                          text: widget.date,
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
                        visible: widget.leftButton,
                        child: GestureDetector(
                          onTap: () async {
                            if (widget.leftButton) {
                              log('LB Task Status Value : ${widget.taskStatusValue - 1}');
                              if (widget.taskStatusValue - 1 == 1) {
                                String userName =
                                    await AppFunctions.getNameByEmail(
                                        email: currentUserEmail.toString());
                                String workspaceName = await AppFunctions
                                    .getWorkspaceNameByWorkspaceCode(
                                        workspaceCode: widget.workspaceCode);
                                log(workspaceName);
                                String token =
                                    await AppFunctions.getTokenByEmail(
                                        email: widget.email);
                                MessageNotificationApi.send(
                                    token: token,
                                    title: '📝 Task Remove From Review',
                                    body:
                                        '$userName remove task from review in $workspaceName workspace.');
                              }
                              await FirebaseFirestore.instance
                                  .collection(widget.workspaceTaskCode)
                                  .doc(widget.docId)
                                  .update({
                                'Task Status': widget.isOwner
                                    ? widget.taskStatusValue - 2
                                    : widget.taskStatusValue - 1,
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
                        visible: widget.rightButton,
                        child: GestureDetector(
                          onTap: () async {
                            if (widget.rightButton) {
                              log('RB Task Status Value : ${widget.taskStatusValue + 1}');
                              await FirebaseFirestore.instance
                                  .collection(widget.workspaceTaskCode)
                                  .doc(widget.docId)
                                  .update({
                                'Task Status': widget.taskStatusValue + 1,
                              });
                              if (widget.taskStatusValue + 1 == 2) {
                                String userName =
                                    await AppFunctions.getNameByEmail(
                                        email: currentUserEmail.toString());
                                String workspaceName = await AppFunctions
                                    .getWorkspaceNameByWorkspaceCode(
                                        workspaceCode: widget.workspaceCode);
                                log(workspaceName);
                                String token =
                                    await AppFunctions.getTokenByEmail(
                                        email: widget.email);
                                MessageNotificationApi.send(
                                    token: token,
                                    title: '📝 Task In Review ',
                                    body:
                                        'Please review a task of $userName in $workspaceName workspace.');
                              }
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

  showTaskDeletionDialog(
      {required BuildContext context,
      required String taskTitle,
      required String workspaceTaskCode,
      required String docId}) {
    Widget cancelButton = MaterialButton(
      color: AppColor.white,
      child: const Text(
        'Cancel',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget deleteButton = MaterialButton(
      color: Colors.red,
      child: Text(
        'Delete',
        style: TextStyle(color: AppColor.white),
      ),
      onPressed: () async {
        Navigator.pop(context);
        await FirebaseFirestore.instance
            .collection(workspaceTaskCode)
            .doc(docId)
            .delete();
        await Fluttertoast.showToast(
          msg: 'Task Deleted Successfully', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          backgroundColor: AppColor.black,
        );
      },
    );

    AlertDialog alert = AlertDialog(
      // title: Text(taskTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              taskTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Lottie.asset(height: 70, 'animations/warning-red.json'),
            const SizedBox(height: 6),
            const Text("Do you want to delete Task ?"),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                cancelButton,
                deleteButton,
              ],
            ),
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

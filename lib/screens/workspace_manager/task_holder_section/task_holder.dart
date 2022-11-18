import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/task_view.dart';

class WorkspaceTaskHolder extends StatefulWidget {
  String docId;
  String workspaceCode;
  String workspaceName;
  String workspaceOwnerName;
  String workspaceOwnerEmail;
  WorkspaceTaskHolder({
    Key? key,
    required this.workspaceCode,
    required this.docId,
    required this.workspaceName,
    required this.workspaceOwnerName,
    required this.workspaceOwnerEmail,
  }) : super(key: key);
  @override
  _WorkspaceTaskHolderState createState() => _WorkspaceTaskHolderState();
}

class _WorkspaceTaskHolderState extends State<WorkspaceTaskHolder> {
  late final Stream<QuerySnapshot> _assignTasksData;
  DateTime dateTime = DateTime.now();
  int taskStatusValue = 0;
  Color tileColor = AppChartColor.blue;
  String imageURL = '';

  bool leftButton = false;
  bool rightButton = true;
  List<Color> taskTabsColor = [
    AppColor.orange,
    AppColor.white,
    AppColor.white,
    AppColor.white,
    AppColor.white
  ];

  @override
  void initState() {
    super.initState();
    _assignTasksData = FirebaseFirestore.instance
        .collection('$currentUserEmail ${widget.workspaceCode}')
        .orderBy('Created At', descending: true)
        .snapshots();
    fetchData();
  }

  fetchData() async {
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(widget.workspaceOwnerEmail)
          .get()
          .then((ds) {
        imageURL = ds['Image URL'];
      });
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size(30, 180),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColor.orange,
                    radius: 40,
                    foregroundImage:
                        imageURL.isEmpty ? null : NetworkImage(imageURL),
                    child: Center(
                      child: Text(
                        widget.workspaceOwnerName[0],
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 40,
                            color: AppColor.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Text(
                      widget.workspaceOwnerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                  ),
                  Text(
                    widget.workspaceOwnerEmail,
                    style: TextStyle(color: AppColor.grey, fontSize: 18),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                color: AppColor.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          taskStatusValue = 0;
                          tileColor = AppChartColor.blue;
                          leftButton = false;
                          rightButton = true;
                          taskTabsColor[0] = AppColor.orange;
                          taskTabsColor[1] = AppColor.white;
                          taskTabsColor[2] = AppColor.white;
                          taskTabsColor[3] = AppColor.white;
                          taskTabsColor[4] = AppColor.white;
                        });
                      },
                      child: Text(
                        'TODO',
                        style: TextStyle(
                          color: taskTabsColor[0],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          taskStatusValue = 1;
                          tileColor = AppChartColor.yellow;
                          leftButton = true;
                          rightButton = true;
                          taskTabsColor[0] = AppColor.white;
                          taskTabsColor[1] = AppColor.orange;
                          taskTabsColor[2] = AppColor.white;
                          taskTabsColor[3] = AppColor.white;
                          taskTabsColor[4] = AppColor.white;
                        });
                      },
                      child: Text(
                        'Doing',
                        style: TextStyle(
                          color: taskTabsColor[1],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          taskStatusValue = 2;
                          tileColor = AppChartColor.grey;
                          leftButton = true;
                          rightButton = false;
                          taskTabsColor[0] = AppColor.white;
                          taskTabsColor[1] = AppColor.white;
                          taskTabsColor[2] = AppColor.orange;
                          taskTabsColor[3] = AppColor.white;
                          taskTabsColor[4] = AppColor.white;
                        });
                      },
                      child: Text(
                        'Review',
                        style: TextStyle(
                          color: taskTabsColor[2],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          taskStatusValue = 3;
                          tileColor = AppChartColor.green;
                          leftButton = false;
                          rightButton = false;
                          taskTabsColor[0] = AppColor.white;
                          taskTabsColor[1] = AppColor.white;
                          taskTabsColor[2] = AppColor.white;
                          taskTabsColor[3] = AppColor.orange;
                          taskTabsColor[4] = AppColor.white;
                        });
                      },
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          color: taskTabsColor[3],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {});
                        taskStatusValue = 4;
                        tileColor = AppChartColor.red;
                        leftButton = false;
                        rightButton = false;
                        taskTabsColor[0] = AppColor.white;
                        taskTabsColor[1] = AppColor.white;
                        taskTabsColor[2] = AppColor.white;
                        taskTabsColor[3] = AppColor.white;
                        taskTabsColor[4] = AppColor.orange;
                      },
                      child: Text(
                        'Expired',
                        style: TextStyle(
                          color: taskTabsColor[4],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TaskView(
        isOwner: false,
        workspaceTaskCode: '$currentUserEmail ${widget.workspaceCode}',
        taskStatusValue: taskStatusValue,
        snapshot: _assignTasksData,
        color: tileColor,
        leftButton: leftButton,
        rightButton: rightButton,
      ),
    );
  }
}

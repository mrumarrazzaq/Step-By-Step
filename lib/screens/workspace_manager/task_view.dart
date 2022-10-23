import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_task_tile.dart';

class TaskView extends StatefulWidget {
  TaskView({
    Key? key,
    required this.taskStatusValue,
    required this.color,
    required this.snapshot,
    required this.leftFunction,
    required this.rightFunction,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);
  int taskStatusValue;
  Stream<QuerySnapshot> snapshot;
  Color color;
  Function() leftFunction;
  Function() rightFunction;
  bool leftButton;
  bool rightButton;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
          stream: widget.snapshot,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              log('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: AppColor.orange,
                strokeWidth: 2.0,
              ));
            }
            if (snapshot.hasData) {
              final List storedData = [];

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedData.add(id);
                id['id'] = document.id;
              }).toList();
              return Column(
                children: [
                  for (int i = 0; i < storedData.length; i++) ...[
                    if (storedData[i]['Task Status'] ==
                        widget.taskStatusValue) ...[
                      WorkspaceTaskTile(
                        title: storedData[i]['Task Title'],
                        description: storedData[i]['Task Description'],
                        email: storedData[i]['Assigned By'],
                        date: storedData[i]['Due Date'],
                        color: widget.color,
                        leftFunction: widget.leftFunction,
                        rightFunction: widget.rightFunction,
                        leftButton: widget.leftButton,
                        rightButton: widget.rightButton,
                      ),
                    ]
                  ],
                ],
              );
            }
            return Center(
                child: CircularProgressIndicator(
              color: AppColor.orange,
              strokeWidth: 2.0,
            ));
          }),
    );
  }
}

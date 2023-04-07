import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_task_tile.dart';

class TaskView extends StatefulWidget {
  TaskView({
    Key? key,
    required this.isOwner,
    required this.userEmail,
    required this.workspaceCode,
    required this.workspaceTaskCode,
    required this.taskStatusValue,
    required this.color,
    required this.snapshot,
    required this.leftButton,
    required this.rightButton,
  }) : super(key: key);
  bool isOwner;
  String userEmail;
  String workspaceCode;
  String workspaceTaskCode;
  int taskStatusValue;
  Stream<QuerySnapshot> snapshot;
  Color color;
  bool leftButton;
  bool rightButton;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  String dateFilter = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
  DateTime initialSelectedDate = DateTime.now();

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
              for (int i = 0; i < storedData.length; i++) {
                checkExpiredTask(storedData[i]['Due Date'],
                    storedData[i]['Raw Date'], storedData[i]['id']);
              }
              return Column(
                children: [
                  ListTile(
                    title: const Text('See Previous Date Task'),
                    textColor: AppColor.black,
                    trailing: GestureDetector(
                      onTap: () {
                        _pickDate();
                      },
                      child: Lottie.asset(
                          repeat: false,
                          height: 30,
                          'animations/calendar.json'),
                    ),
                  ),
                  Lottie.asset(repeat: false, 'animations/black-divider.json'),
                  DatePicker(
                    initialSelectedDate,
                    initialSelectedDate: initialSelectedDate,
                    selectionColor: Colors.black,
                    selectedTextColor: Colors.white,
                    width: 60,
                    onDateChange: (dateTime) {
                      setState(() {
                        dateFilter =
                            formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        log(dateTime.toString());
                        log(dateFilter.toString());
                      });
                    },
                  ),
                  for (int i = 0; i < storedData.length; i++) ...[
                    if (storedData[i]['Due Date'].isNotEmpty) ...[],
                    if (storedData[i]['Task Status'] ==
                            widget.taskStatusValue &&
                        dateFilter == storedData[i]['Date Filter']) ...[
                      WorkspaceTaskTile(
                        isOwner: widget.isOwner,
                        userEmail: widget.userEmail,
                        workspaceCode: widget.workspaceCode,
                        workspaceTaskCode: widget.workspaceTaskCode,
                        docId: storedData[i]['id'],
                        title: storedData[i]['Task Title'],
                        description: storedData[i]['Task Description'],
                        taskStatusValue: widget.taskStatusValue,
                        email: storedData[i]['Assigned By'],
                        date: storedData[i]['Due Date'],
                        fileName: storedData[i]['File Name'],
                        fileURL: storedData[i]['File URL'],
                        color: widget.color,
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

  void checkExpiredTask(String dueDate, var rawDate, String docId) async {
    if (dueDate != 'No Due Date') {
      if (rawDate.toDate().isBefore(DateTime.now())) {
        await FirebaseFirestore.instance
            .collection(widget.workspaceTaskCode)
            .doc(docId)
            .update({
          'Task Status': 4,
        });
      }
    }
  }

  void _pickDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 01, 01),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.orange,
              onPrimary: AppColor.white,
              onSurface: AppColor.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: AppColor.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickDate != null) {
      setState(() {
        initialSelectedDate = pickDate;
        log(initialSelectedDate.toString());
        //dateFilter = formatDate(pickDate, [dd, ' ', MM, ' ', yyyy]);
      });
    }
  }
}

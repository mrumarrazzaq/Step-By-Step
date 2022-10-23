import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/task_view.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_task_tile.dart';
import 'package:stepbystep/widgets/app_elevated_button.dart';

class TaskAssignment extends StatefulWidget {
  String name;
  String email;
  String docId;
  String workspaceCode;
  String workspaceName;
  TaskAssignment(
      {Key? key,
      required this.name,
      required this.email,
      required this.workspaceCode,
      required this.docId,
      required this.workspaceName})
      : super(key: key);
  @override
  _TaskAssignmentState createState() => _TaskAssignmentState();
}

class _TaskAssignmentState extends State<TaskAssignment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Stream<QuerySnapshot> _assignTasksData;
  DateTime dateTime = DateTime.now();

  String _date = '';
  bool isDateTimeChecked = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  int currentIndex = 0;
  int taskStatusValue = 0;
  Color tileColor = AppChartColor.blue;

  bool leftButton = false;
  bool rightButton = false;
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
        .collection('${widget.email} ${widget.workspaceCode}')
        .orderBy('Created At', descending: true)
        .snapshots();
    _date = '${formatDate(dateTime, [
          dd,
          '-',
          mm,
          '-',
          yyyy
        ])} ${formatDate(dateTime, [hh, ':', nn, ' ', am])}';
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
                    foregroundImage: const AssetImage('assets/dummy.jpg'),
                    radius: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                  ),
                  Text(
                    widget.email,
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
                          rightButton = false;
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
                          leftButton = false;
                          rightButton = false;
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
                          leftButton = false;
                          rightButton = true;
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
                          leftButton = true;
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
                // TabBar(
                //   controller: tabController,
                //   onTap: (index) {
                //     setState(() {
                //       currentIndex = index;
                //     });
                //   },
                //   indicatorColor: Colors.transparent,
                //   unselectedLabelColor: AppColor.white,
                //   labelColor: AppColor.orange,
                //   tabs: taskTabs,
                // ),
              ),
            ],
          ),
        ),
      ),
      body: TaskView(
        isOwner: true,
        workspaceTaskCode: '${widget.email} ${widget.workspaceCode}',
        taskStatusValue: taskStatusValue,
        snapshot: _assignTasksData,
        color: tileColor,
        leftButton: leftButton,
        rightButton: rightButton,
      ),

      // TabBarView(
      //   controller: tabController,
      //   children: [
      //     TaskView(
      //       taskStatusValue: 0,
      //       snapshot: _assignTasksData,
      //       color: AppChartColor.blue,
      //       leftButton: false,
      //       rightButton: true,
      //       leftFunction: () {},
      //       rightFunction: () {},
      //     ),
      //     StreamBuilder<QuerySnapshot>(
      //         stream: _assignTasksData,
      //         builder: (BuildContext context,
      //             AsyncSnapshot<QuerySnapshot> snapshot) {
      //           if (snapshot.hasError) {
      //             log('Something went wrong');
      //           }
      //           if (snapshot.connectionState == ConnectionState.waiting) {
      //             return Center(
      //                 child: CircularProgressIndicator(
      //               color: AppColor.orange,
      //               strokeWidth: 2.0,
      //             ));
      //           }
      //           if (snapshot.hasData) {
      //             final List storedData = [];
      //
      //             snapshot.data!.docs.map((DocumentSnapshot document) {
      //               Map id = document.data() as Map<String, dynamic>;
      //               storedData.add(id);
      //               id['id'] = document.id;
      //             }).toList();
      //             return Column(
      //               children: [
      //                 for (int i = 0; i < storedData.length; i++) ...[
      //                   if (storedData[i]['Task Status'] == 1) ...[
      //                     WorkspaceTaskTile(
      //                       title: storedData[i]['Task Title'],
      //                       description: storedData[i]['Task Description'],
      //                       email: storedData[i]['Assigned By'],
      //                       date: storedData[i]['Due Date'],
      //                       color: AppChartColor.yellow,
      //                       leftFunction: () {},
      //                       rightFunction: () {},
      //                       leftButton: true,
      //                       rightButton: true,
      //                     ),
      //                   ]
      //                 ],
      //               ],
      //             );
      //           }
      //           return Center(
      //               child: CircularProgressIndicator(
      //             color: AppColor.orange,
      //             strokeWidth: 2.0,
      //           ));
      //         }),
      //     TaskView(
      //       taskStatusValue: 2,
      //       snapshot: _assignTasksData,
      //       color: AppChartColor.grey,
      //       leftButton: false,
      //       rightButton: true,
      //       leftFunction: () {},
      //       rightFunction: () {},
      //     ),
      //     TaskView(
      //       taskStatusValue: 3,
      //       snapshot: _assignTasksData,
      //       color: AppChartColor.green,
      //       leftButton: false,
      //       rightButton: true,
      //       leftFunction: () {},
      //       rightFunction: () {},
      //     ),
      //     TaskView(
      //       taskStatusValue: 4,
      //       snapshot: _assignTasksData,
      //       color: AppChartColor.red,
      //       leftButton: false,
      //       rightButton: true,
      //       leftFunction: () {},
      //       rightFunction: () {},
      //     ),
      //   ],
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: currentIndex == 0
          ? AppElevatedButton(
              text: 'Assign Task',
              textColor: AppColor.white,
              backgroundColor: AppColor.orange,
              function: () {
                taskAssignmentDialog();
              },
            )
          : null,
    );
  }

  void taskAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                height: isDateTimeChecked ? 455 : 410,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColor.white),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Assign Task',
                        style: TextStyle(
                            color: AppColor.darkGrey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Title',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  cursorColor: AppColor.black,
                                  maxLength: 80,
                                  style: TextStyle(color: AppColor.black),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.black, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.grey, width: 1.0),
                                    ),
                                    hintText: 'Create Figma Prototype',
                                  ),
                                  controller: titleController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter task title';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Description',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  cursorColor: AppColor.black,
                                  style: TextStyle(color: AppColor.black),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.black, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: AppColor.grey, width: 1.0),
                                    ),
                                    hintText: 'Description [Optional]',
                                  ),
                                  controller: descriptionController,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      CheckboxListTile(
                        title: const Text('Due Date'),
                        value: isDateTimeChecked,
                        onChanged: (value) {
                          setState(() {
                            isDateTimeChecked = value!;
                          });
                        },
                      ),
                      Visibility(
                          visible: isDateTimeChecked,
                          child: buildDateTimePicker()),
                      const SizedBox(height: 25),
                      AppElevatedButton(
                        text: 'Assign',
                        width: 100,
                        textColor: AppColor.white,
                        backgroundColor: AppColor.orange,
                        function: () async {
                          if (_formKey.currentState!.validate()) {
                            final taskJson = {
                              'Task Title': titleController.text,
                              'Task Description':
                                  descriptionController.text.isEmpty
                                      ? ''
                                      : descriptionController.text,
                              'Due Date':
                                  isDateTimeChecked ? _date : 'No Due Date',
                              'Task Status': 0,
                              'Assigned By': currentUserEmail,
                              'Created At': DateTime.now(),
                            };

                            await FireBaseApi.createCollectionAutoDoc(
                              collection:
                                  '${widget.email} ${widget.workspaceCode}',
                              jsonData: taskJson,
                            );

                            final taskLogJson = {
                              'Workspace Task Code':
                                  '${widget.email} ${widget.workspaceCode}',
                              'TODO': 0,
                              'DOING': 0,
                              'REVIEW': 0,
                              'Created At': DateTime.now(),
                            };

                            await FireBaseApi.saveDataIntoFireStore(
                              collection: 'Workspaces Task Log',
                              document:
                                  '${widget.email} ${widget.workspaceCode}',
                              jsonData: taskLogJson,
                            );
                            if (mounted) {
                              titleController.clear();
                              descriptionController.clear();
                              isDateTimeChecked = false;
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget buildDateTimePicker() {
    return SizedBox(
      height: 55,
      child: CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.light),
        child: CupertinoDatePicker(
          minimumDate: DateTime.now(),
          initialDateTime: DateTime.now(),
          mode: CupertinoDatePickerMode.dateAndTime,
          maximumYear: 3050,
          minimumYear: DateTime.now().year,
          onDateTimeChanged: (pickDate) {
            setState(() {
              _date = '${formatDate(pickDate, [
                    dd,
                    '-',
                    mm,
                    '-',
                    yyyy
                  ])} ${formatDate(pickDate, [hh, ':', nn, ' ', am])}';
              log(_date);
            });
          },
        ),
      ),
    );
  }
}

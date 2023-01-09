import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/apis/app_functions.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/apis/messege_notification_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/task_view.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_members/workspace_members_handler.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/workspace_roles_handler.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_task_tile.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_view/workspace_view_home.dart';
import 'package:stepbystep/widgets/app_elevated_button.dart';

class TaskTeamAssignment extends StatefulWidget {
  String name;
  String email;
  String docId;
  String workspaceCode;
  String workspaceName;
  String workspaceOwnerEmail;
  String assignedRole;
  TaskTeamAssignment({
    Key? key,
    required this.name,
    required this.email,
    required this.workspaceCode,
    required this.docId,
    required this.workspaceName,
    required this.workspaceOwnerEmail,
    required this.assignedRole,
  }) : super(key: key);
  @override
  _TaskTeamAssignmentState createState() => _TaskTeamAssignmentState();
}

class _TaskTeamAssignmentState extends State<TaskTeamAssignment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Stream<QuerySnapshot> _assignTasksData;
  DateTime dateTime = DateTime.now();

  String _date = '';
  String selectedTab = 'Task';
  bool isDateTimeChecked = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  int currentIndex = 0;
  int taskStatusValue = 0;
  Color tileColor = AppChartColor.blue;
  String imageURL = '';

  bool spaceEvenly = false;
  bool leftButton = false;
  bool rightButton = false;

  bool teamControl = false;
  bool taskControl = false;
  bool roleControl = false;
  bool viewControl = false;
  bool isAssigning = false;
  List<Color> mainTabsColor = [AppColor.white, AppColor.orange];

  List<Color> taskTabsColor = [
    AppColor.orange,
    AppColor.white,
    AppColor.white,
    AppColor.white,
    AppColor.white
  ];
  List<Color> teamTabsColor = [AppColor.orange, AppColor.white, AppColor.white];
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
    fetchData();
    getRolesData();
  }

  fetchData() async {
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(widget.email)
          .get()
          .then((ds) {
        imageURL = ds['Image URL'];
      });
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  getRolesData() async {
    log('Role Data is fetching');
    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Roles')
          .doc(widget.assignedRole)
          .get()
          .then((ds) {
        teamControl = ds['Team Control'];
        taskControl = ds['Task Control'];
        roleControl = ds['Role Control'];
        viewControl = ds['View Control'];
      });
      if (teamControl && taskControl && roleControl ||
          teamControl && taskControl ||
          teamControl && roleControl ||
          taskControl && roleControl) {
        spaceEvenly = true;
      }
      log(teamControl.toString());
      log(taskControl.toString());
      log(roleControl.toString());
      log(viewControl.toString());
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
          preferredSize: const Size(30, 225),
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
                        widget.name[0],
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: teamControl,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      color: AppColor.orange,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTab = 'Task';
                                    mainTabsColor[0] = AppColor.white;
                                    mainTabsColor[1] = AppColor.orange;
                                  });
                                },
                                minWidth: 160,
                                child: Text(
                                  'Task',
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontWeight:
                                        mainTabsColor[0] == AppColor.white
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Container(
                                height: 3,
                                width: 160,
                                color: mainTabsColor[0],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTab = 'Team';
                                    mainTabsColor[0] = AppColor.orange;
                                    mainTabsColor[1] = AppColor.white;
                                  });
                                },
                                minWidth: 160,
                                child: Text(
                                  'Team',
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontWeight:
                                        mainTabsColor[1] == AppColor.white
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Container(
                                height: 3,
                                width: 160,
                                color: mainTabsColor[1],
                              ),
                            ],
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
                  ),
                  //Task Sub Tabs
                  Visibility(
                    visible: selectedTab == 'Task',
                    child: Container(
                      margin: EdgeInsets.only(top: teamControl ? 0 : 20),
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
                                leftButton = true;
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
                  ),
                  //Team Sub Tabs
                  Visibility(
                    visible: selectedTab == 'Team',
                    child: Container(
                      margin: const EdgeInsets.only(top: 0),
                      color: AppColor.black,
                      child: Row(
                        mainAxisAlignment: spaceEvenly
                            ? MainAxisAlignment.spaceEvenly
                            : MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: teamControl,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  teamTabsColor[0] = AppColor.orange;
                                  teamTabsColor[1] = AppColor.white;
                                  teamTabsColor[2] = AppColor.white;
                                });
                              },
                              child: Text(
                                'Members',
                                style: TextStyle(
                                  color: teamTabsColor[0],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: roleControl,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  teamTabsColor[0] = AppColor.white;
                                  teamTabsColor[1] = AppColor.orange;
                                  teamTabsColor[2] = AppColor.white;
                                });
                              },
                              child: Text(
                                'Roles',
                                style: TextStyle(
                                  color: teamTabsColor[1],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: viewControl,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  teamTabsColor[0] = AppColor.white;
                                  teamTabsColor[1] = AppColor.white;
                                  teamTabsColor[2] = AppColor.orange;
                                });
                              },
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: teamTabsColor[2],
                                ),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Tasks
            Visibility(
              visible: selectedTab == 'Task',
              child: TaskView(
                isOwner: true,
                workspaceCode: widget.workspaceCode,
                workspaceTaskCode: '${widget.email} ${widget.workspaceCode}',
                taskStatusValue: taskStatusValue,
                snapshot: _assignTasksData,
                color: tileColor,
                leftButton: leftButton,
                rightButton: rightButton,
              ),
            ),
            //Teams Section
            Visibility(
              visible: selectedTab == 'Team' &&
                  teamControl &&
                  teamTabsColor[0] == AppColor.orange,
              child: WorkspaceMembersHandler(
                extraEmail: widget.email,
                fromTaskAssignment: true,
                fromTaskHolder: false,
                workspaceName: widget.workspaceName,
                workspaceCode: widget.workspaceCode,
                docId: widget.docId,
                workspaceOwnerEmail: widget.workspaceOwnerEmail,
                assignTaskControl: taskControl,
                reportControl: true,
                addMember: true,
                removeMember: true,
                assignRole: true,
                deAssignRole: true,
              ),
            ),
            //Roles Section
            Visibility(
              visible: selectedTab == 'Team' &&
                  roleControl &&
                  teamTabsColor[1] == AppColor.orange,
              child: WorkspaceRolesHandler(
                fromTaskAssignment: true,
                fromTaskHolder: false,
                workspaceCode: widget.workspaceCode,
                workspaceName: widget.workspaceName,
                docId: widget.docId,
                createRole: true,
                editRole: true,
                deleteRole: true,
                controlForUser: false,
                controlForOwner: true,
              ),
            ),
            //View Section
            Visibility(
              visible: selectedTab == 'Team' &&
                  viewControl &&
                  teamTabsColor[2] == AppColor.orange,
              child: WorkspaceViewHome(
                fromTaskAssignment: true,
                fromTaskHolder: false,
                workspaceCode: widget.workspaceCode,
                workspaceName: widget.workspaceName,
                docId: widget.docId,
                createRole: true,
                editRole: true,
                deleteRole: true,
                controlForUser: false,
                controlForOwner: true,
              ),
            ),
          ],
        ),
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
          ? Visibility(
              visible: selectedTab == 'Task',
              child: AppElevatedButton(
                text: 'Assign Task',
                textColor: AppColor.white,
                backgroundColor: AppColor.orange,
                function: () {
                  taskAssignmentDialog();
                },
              ),
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
                      isAssigning
                          ? CircularProgressIndicator(
                              color: AppColor.white,
                              backgroundColor: AppColor.orange,
                            )
                          : AppElevatedButton(
                              text: 'Assign',
                              width: 100,
                              textColor: AppColor.white,
                              backgroundColor: AppColor.orange,
                              function: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isAssigning = true;
                                  });
                                  final taskJson = {
                                    'Task Title': titleController.text,
                                    'Task Description':
                                        descriptionController.text.isEmpty
                                            ? ''
                                            : descriptionController.text,
                                    'Due Date': isDateTimeChecked
                                        ? _date
                                        : 'No Due Date',
                                    'Task Status': 0,
                                    'Assigned By': currentUserEmail,
                                    'Created At': DateTime.now(),
                                  };

                                  await FireBaseApi.createCollectionAutoDoc(
                                    workspaceCode: widget.workspaceCode,
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
                                    workspaceCode: widget.workspaceCode,
                                    collection: 'Workspaces Task Log',
                                    document:
                                        '${widget.email} ${widget.workspaceCode}',
                                    jsonData: taskLogJson,
                                  );
                                  String name =
                                      await AppFunctions.getNameByEmail(
                                          email: currentUserEmail.toString());
                                  String token =
                                      await AppFunctions.getTokenByEmail(
                                          email: widget.email);
                                  MessageNotificationApi.send(
                                      token: token,
                                      title: 'Task TODO 📝',
                                      body:
                                          '$name assign you task ${isDateTimeChecked ? 'Due Date is : \"$_date\"' : 'with \"No Due Date\"'} in ${widget.workspaceName} workspace.');
                                  if (mounted) {
                                    titleController.clear();
                                    descriptionController.clear();
                                    isDateTimeChecked = false;
                                    setState(() {
                                      isAssigning = false;
                                    });
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

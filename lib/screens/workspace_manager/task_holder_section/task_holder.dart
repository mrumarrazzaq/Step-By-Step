import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/task_view.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_members/workspace_members_handler.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/workspace_roles_handler.dart';

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
  String selectedTab = 'Task';

  Color tileColor = AppChartColor.blue;
  String imageURL = '';
  String assignedRole = '';

  bool leftButton = false;
  bool rightButton = true;

  bool spaceEvenly = false;

  bool control = false;
  bool teamControl = false;
  bool taskControl = false;
  bool reportControl = false;
  bool roleControl = false;
  bool viewControl = false;

  bool addMember = false;
  bool removeMember = false;
  bool assignRole = false;
  bool deAssignRole = false;
  bool createRole = false;
  bool editRole = false;
  bool deleteRole = false;

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
    log('Task Holder init State Called');
    _assignTasksData = FirebaseFirestore.instance
        .collection('$currentUserEmail ${widget.workspaceCode}')
        .orderBy('Created At', descending: true)
        .snapshots();
    fetchData();
    getAssignRoleData();
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

  getAssignRoleData() async {
    log('Role Data is fetching');
    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Assigned Roles')
          .doc(currentUserEmail)
          .get()
          .then((ds) {
        assignedRole = ds['Assigned Role'];
      });
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Roles')
          .doc(assignedRole)
          .get()
          .then((ds) {
        control = ds['Control'];
        teamControl = ds['Team Control'];
        taskControl = ds['Task Control'];
        roleControl = ds['Role Control'];
        viewControl = ds['View Control'];
        reportControl = ds['Report Control'];
        addMember = ds['Add Member'];
        removeMember = ds['Remove Member'];
        assignRole = ds['Assign Role'];
        deAssignRole = ds['DeAssign Role'];
        roleControl = ds['Role Control'];
        createRole = ds['Create Role'];
        editRole = ds['Edit Role'];
        deleteRole = ds['Delete Role'];
      });
      if (teamControl && taskControl && roleControl ||
          teamControl && taskControl ||
          teamControl && roleControl ||
          taskControl && roleControl) {
        spaceEvenly = true;
      }

      log('$currentUserEmail : assignedRole $assignedRole');
      log('teamControl $teamControl');
      log('taskControl $taskControl');
      log('roleControl $roleControl');
      log('viewControl $viewControl');

      log('addMember $addMember');
      log('removeMember $removeMember');
      log('deAssignRole $deAssignRole');
      log('createRole $createRole');
      log('editRole $editRole');
      log('deleteRole $deleteRole');

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
              Column(
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
                                    fontSize: 18,
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
                                    fontSize: 18,
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
                isOwner: false,
                workspaceTaskCode: '$currentUserEmail ${widget.workspaceCode}',
                taskStatusValue: taskStatusValue,
                snapshot: _assignTasksData,
                color: tileColor,
                leftButton: leftButton,
                rightButton: rightButton,
              ),
            ),
            //Teams
            Visibility(
              visible: selectedTab == 'Team' &&
                  teamControl &&
                  teamTabsColor[0] == AppColor.orange,
              child: WorkspaceMembersHandler(
                fromTaskAssignment: false,
                fromTaskHolder: true,
                workspaceName: widget.workspaceName,
                workspaceCode: widget.workspaceCode,
                workspaceOwnerEmail: widget.workspaceOwnerEmail,
                docId: widget.docId,
                assignTaskControl: taskControl,
                reportControl: reportControl,
                addMember: addMember,
                removeMember: removeMember,
                assignRole: assignRole,
                deAssignRole: deAssignRole,
              ),
            ),
            //Roles
            Visibility(
              visible: selectedTab == 'Team' &&
                  roleControl &&
                  teamTabsColor[1] == AppColor.orange,
              child: WorkspaceRolesHandler(
                fromTaskAssignment: false,
                fromTaskHolder: true,
                workspaceCode: widget.workspaceCode,
                workspaceName: widget.workspaceName,
                docId: widget.docId,
                createRole: createRole,
                editRole: editRole,
                deleteRole: deleteRole,
                controlForUser: control,
                controlForOwner: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/task_view.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_members/workspace_members_handler.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/workspace_roles_handler.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_view/workspace_view_home.dart';

class WorkspaceTaskHolder extends StatefulWidget {
  final String docId;
  final String workspaceCode;
  final String workspaceName;
  final String workspaceOwnerName;
  final String workspaceOwnerEmail;
  const WorkspaceTaskHolder({
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

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  DateTime dateTime = DateTime.now();
  int taskStatusValue = 0;
  String selectedTab = 'Task';

  Color tileColor = AppChartColor.blue;
  String imageURL = '';
  String assignedRole = '';
  String upperRole = '';
  int upperLevel = 0;

  bool leftButton = false;
  bool rightButton = true;

  bool spaceEvenly = false;

  bool control = false;
  bool teamControl = false;
  bool memberControl = false;
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
  double _height = 130;
  double _fontSize = 40;
  double _radius = 40;
  double _text = 20;
  bool loading = true;
  var axis = Axis.vertical;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    log('Task Holder init State Called');
    log('workspace_home -> task_holder');
    _assignTasksData = FirebaseFirestore.instance
        .collection('$currentUserEmail ${widget.workspaceCode}')
        .orderBy('Created At', descending: true)
        .snapshots();
    fetchData();
    getAssignRoleData();
    getUpperLevelRole();
    try {
      Future.delayed(const Duration(milliseconds: 3000), () {
        setState(() {
          axis = Axis.horizontal;
          _height = 0;
          _text = 18;
          _radius = 25;
          _fontSize = 25;
        });
      });
      Future.delayed(const Duration(milliseconds: 3800), () {
        setState(() {
          isVisible = false;
        });
      });
    } catch (e) {
      log(e.toString());
    }
    listenForRolesData();
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
        memberControl = ds['Member Control'];
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

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      log(e.toString());
    }

    // var userQuery = FirebaseFirestore.instance
    //     .collection('${widget.workspaceCode} Roles')
    //     .where(assignedRole, isEqualTo: assignedRole)
    //     .limit(1);
    //
    // userQuery.snapshots().listen((data) {
    //   data.docChanges.forEach((change) {
    //     print('documentChanges ${change.doc.data}');
    //   });
    // }).onError((e) => print(e));
  }

  getUpperLevelRole() async {
    log('Upper Role Data is fetching');
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(widget.workspaceOwnerEmail)
          .collection('Workspace Roles')
          .doc(widget.workspaceCode)
          .get()
          .then((ds) {
        upperRole = ds['Role'];
        upperLevel = ds['Level'];
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void listenForRolesData() {
    log('listenForData..............');
    try {
      FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Roles')
          .snapshots()
          .listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {
          getAssignRoleData();
        });
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void _onRefresh() async {
    log('-------------------------------------');
    log('On Refresh');
    await getAssignRoleData();
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
    log('-------------------------------------');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loading
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leadingWidth: 100,
              leading: Visibility(
                visible: !isVisible,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    GestureDetector(
                      onTap: () {
                        profileViewDialog(
                          name: widget.workspaceOwnerName,
                          role: upperRole,
                          level: upperLevel,
                          imageURL: imageURL,
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColor.orange,
                        radius: 25,
                        foregroundImage:
                            imageURL.isEmpty ? null : NetworkImage(imageURL),
                        child: Center(
                          child: Text(
                            widget.workspaceOwnerName[0],
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: _fontSize,
                              color: AppColor.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Visibility(
                visible: !isVisible,
                child: GestureDetector(
                  onTap: () {
                    profileViewDialog(
                      name: widget.workspaceOwnerName,
                      role: upperRole,
                      level: upperLevel,
                      imageURL: imageURL,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.workspaceOwnerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.workspaceOwnerEmail,
                        style: TextStyle(
                          color: AppColor.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColor.orange,
              ),
            )
          : SmartRefresher(
              // enablePullUp: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //Profile
                    Column(
                      children: [
                        Visibility(
                          visible: isVisible,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            height: _height,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Flex(
                                direction: axis,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    child: CircleAvatar(
                                      backgroundColor: AppColor.orange,
                                      radius: _radius,
                                      foregroundImage: imageURL.isEmpty
                                          ? null
                                          : NetworkImage(imageURL),
                                      child: Center(
                                        child: Text(
                                          widget.workspaceOwnerName[0],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: _fontSize,
                                              color: AppColor.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3.0),
                                      child: Text(
                                        widget.workspaceOwnerName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: _text),
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    child: Text(
                                      widget.workspaceOwnerEmail,
                                      style: TextStyle(
                                          color: AppColor.grey,
                                          fontSize: _text - 2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Visibility(
                              visible: teamControl,
                              child: Container(
                                margin: const EdgeInsets.only(top: 20),
                                color: AppColor.orange,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedTab = 'Task';
                                              mainTabsColor[0] = AppColor.white;
                                              mainTabsColor[1] =
                                                  AppColor.orange;
                                            });
                                          },
                                          minWidth: 160,
                                          child: Text(
                                            'Task',
                                            style: TextStyle(
                                              color: AppColor.white,
                                              fontSize: 18,
                                              fontWeight: mainTabsColor[0] ==
                                                      AppColor.white
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
                                              mainTabsColor[0] =
                                                  AppColor.orange;
                                              mainTabsColor[1] = AppColor.white;
                                            });
                                          },
                                          minWidth: 160,
                                          child: Text(
                                            'Team',
                                            style: TextStyle(
                                              color: AppColor.white,
                                              fontSize: 18,
                                              fontWeight: mainTabsColor[1] ==
                                                      AppColor.white
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
                                margin:
                                    EdgeInsets.only(top: teamControl ? 0 : 20),
                                color: AppColor.black,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                      visible: memberControl,
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
                                          log('role');
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
                                          log('view');
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
                    //Tasks
                    Visibility(
                      visible: selectedTab == 'Task',
                      child: TaskView(
                        isOwner: false,
                        userEmail: currentUserEmail.toString(),
                        workspaceCode: widget.workspaceCode,
                        workspaceTaskCode:
                            '$currentUserEmail ${widget.workspaceCode}',
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
                          memberControl &&
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
                        control: control,
                        createRole: createRole,
                        editRole: editRole,
                        deleteRole: deleteRole,
                        controlForUser: true, //control
                        controlForOwner: false,
                      ),
                    ),
                    //View
                    Visibility(
                      visible: selectedTab == 'Team' &&
                          viewControl &&
                          teamTabsColor[2] == AppColor.orange,
                      child: WorkspaceViewHome(
                        fromTaskAssignment: false,
                        fromTaskHolder: true,
                        workspaceCode: widget.workspaceCode,
                        workspaceName: widget.workspaceName,
                        docId: widget.docId,
                        createRole: createRole,
                        editRole: editRole,
                        deleteRole: deleteRole,
                        controlForUser: true, //control
                        controlForOwner: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  profileViewDialog({
    required String name,
    required String role,
    required int level,
    required String imageURL,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        titlePadding: imageURL.isEmpty ? null : const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.all(0),
        alignment: Alignment.center,
        backgroundColor: AppColor.lightOrange,
        title: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10.0),
            topLeft: Radius.circular(10.0),
          ),
          child: CachedNetworkImage(
            imageUrl: imageURL.toString(),
            // maxWidthDiskCache: 500,
            // maxHeightDiskCache: 500,
            height: imageURL.isEmpty ? 80 : 200,
            width: imageURL.isEmpty ? 80 : double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              width: double.infinity,
              color: AppColor.white,
            ),
            errorWidget: (context, url, error) => Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColor.orange,
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.white),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'logos/user.png',
                  width: 50,
                  color: AppColor.white,
                ),
              ),
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            Text(
              'Workspace $role',
              textAlign: TextAlign.center,
              style: GoogleFonts.titilliumWeb(),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

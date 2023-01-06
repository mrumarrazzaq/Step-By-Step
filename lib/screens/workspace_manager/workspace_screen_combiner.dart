import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_members/workspace_members_handler.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/workspace_roles_handler.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_view/workspace_view_home.dart';

class WorkspaceScreenCombiner extends StatefulWidget {
  String docId;
  String workspaceCode;
  String workspaceName;
  String workspaceOwnerEmail;
  WorkspaceScreenCombiner({
    Key? key,
    required this.workspaceCode,
    required this.docId,
    required this.workspaceName,
    required this.workspaceOwnerEmail,
  }) : super(key: key);

  @override
  State<WorkspaceScreenCombiner> createState() =>
      _WorkspaceScreenCombinerState();
}

class _WorkspaceScreenCombinerState extends State<WorkspaceScreenCombiner> {
  List<Color> tabsColor = [AppColor.orange, AppColor.black, AppColor.black];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor,
      appBar: AppBar(
        title: Text(
          widget.workspaceName,
          style:
              TextStyle(color: AppColor.darkGrey, fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColor.white,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Lottie.asset(
                repeat: false, height: 30, width: 30, 'animations/info.json'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size(200, 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    tabsColor[0] = AppColor.orange;
                    tabsColor[1] = AppColor.black;
                    tabsColor[2] = AppColor.black;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Members',
                      style: TextStyle(
                        color: tabsColor[0],
                      ),
                    ),
                    Visibility(
                      visible: tabsColor[0] == AppColor.orange,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 3,
                        width: 80,
                        color: tabsColor[0],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    tabsColor[0] = AppColor.black;
                    tabsColor[1] = AppColor.orange;
                    tabsColor[2] = AppColor.black;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Roles',
                      style: TextStyle(
                        color: tabsColor[1],
                      ),
                    ),
                    Visibility(
                      visible: tabsColor[1] == AppColor.orange,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 3,
                        width: 80,
                        color: tabsColor[1],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    tabsColor[0] = AppColor.black;
                    tabsColor[1] = AppColor.black;
                    tabsColor[2] = AppColor.orange;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        color: tabsColor[2],
                      ),
                    ),
                    Visibility(
                      visible: tabsColor[2] == AppColor.orange,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 3,
                        width: 80,
                        color: tabsColor[2],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Workspace Members Handler Section
            Visibility(
              visible: tabsColor[0] == AppColor.orange,
              child: WorkspaceMembersHandler(
                workspaceCode: widget.workspaceCode,
                docId: widget.docId,
                workspaceName: widget.workspaceName,
                workspaceOwnerEmail: widget.workspaceOwnerEmail,
                fromTaskAssignment: false,
                fromTaskHolder: false,
                assignTaskControl: true,
                reportControl: true,
                addMember: true,
                removeMember: true,
                assignRole: true,
                deAssignRole: true,
              ),
            ),
            //Workspace Roles Handler Section
            Visibility(
              visible: tabsColor[1] == AppColor.orange,
              child: WorkspaceRolesHandler(
                workspaceCode: widget.workspaceCode,
                docId: widget.docId,
                workspaceName: widget.workspaceName,
                fromTaskAssignment: false,
                fromTaskHolder: false,
                createRole: true,
                editRole: true,
                deleteRole: true,
                controlForUser: false,
                controlForOwner: true,
              ),
            ),
            //Workspace View Handler Section
            Visibility(
              visible: tabsColor[2] == AppColor.orange,
              child: WorkspaceViewHome(
                workspaceCode: widget.workspaceCode,
                docId: widget.docId,
                workspaceName: widget.workspaceName,
                fromTaskAssignment: false,
                fromTaskHolder: false,
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
    );
  }
}

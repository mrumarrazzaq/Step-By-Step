import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_members_handler.dart';

class WorkspaceScreenCombiner extends StatefulWidget {
  String docId;
  String workspaceCode;
  String workspaceName;
  WorkspaceScreenCombiner(
      {Key? key,
      required this.workspaceCode,
      required this.docId,
      required this.workspaceName})
      : super(key: key);

  @override
  State<WorkspaceScreenCombiner> createState() =>
      _WorkspaceScreenCombinerState();
}

class _WorkspaceScreenCombinerState extends State<WorkspaceScreenCombiner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workspaceName,
          style:
              TextStyle(color: AppColor.darkGrey, fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColor.white,
        // bottom: TabBar(
        //   indicatorWeight: 3,
        //   indicatorColor: AppColor.orange,
        //   labelColor: AppColor.black,
        //   tabs: const [
        //     Tab(
        //       text: 'Members',
        //     ),
        //     Tab(
        //       text: 'Roles',
        //     ),
        //     Tab(
        //       text: 'View',
        //     ),
        //   ],
        // ),
      ),
      body: WorkspaceMembersHandler(
          workspaceCode: widget.workspaceCode,
          docId: widget.docId,
          workspaceName: widget.workspaceName),

      // TabBarView(
      //   children: [
      //     WorkspaceMembersHandler(
      //         workspaceCode: widget.workspaceCode,
      //         docId: widget.docId,
      //         workspaceName: widget.workspaceName),
      //     Container(),
      //     Container(),
      //   ],
      // ),
    );
  }
}

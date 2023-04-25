import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/apis/app_functions.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_view/detailed_view.dart';
import 'package:stepbystep/widgets/app_future_builder.dart';

class WorkspaceViewHome extends StatefulWidget {
  String workspaceCode;
  String docId;
  String workspaceName;
  bool fromTaskAssignment;
  bool fromTaskHolder;
  bool createRole;
  bool editRole;
  bool deleteRole;
  bool controlForUser;
  bool controlForOwner;
  WorkspaceViewHome(
      {Key? key,
      required this.workspaceName,
      required this.workspaceCode,
      required this.docId,
      required this.fromTaskHolder,
      required this.fromTaskAssignment,
      required this.controlForUser,
      required this.controlForOwner,
      required this.createRole,
      required this.deleteRole,
      required this.editRole})
      : super(key: key);

  @override
  State<WorkspaceViewHome> createState() => _WorkspaceViewHomeState();
}

class _WorkspaceViewHomeState extends State<WorkspaceViewHome> {
  late final Stream<QuerySnapshot> rolesRecords;
  double _height = 250;

  @override
  void initState() {
    rolesRecords = FirebaseFirestore.instance
        .collection('${widget.workspaceCode} Roles')
        .orderBy('Role Level', descending: false)
        .snapshots();
    try {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _height = 150;
        });
      });
    } catch (e) {
      log(e.toString());
    }
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          height: _height,
          width: double.infinity,
          curve: Curves.fastOutSlowIn,
          child: Lottie.asset(repeat: false, 'animations/hirearchy.json'),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: rolesRecords,
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
                ),
              );
            }
            if (snapshot.hasData) {
              List storedRolesData = [];

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedRolesData.add(id);
                id['id'] = document.id;
              }).toList();
              return Column(
                children: [
                  if (storedRolesData.isEmpty) ...[
                    Lottie.asset('animations/sorry.json'),
                  ],
                  for (int i = 0; i < storedRolesData.length; i++) ...[
                    ViewCard(
                      widget: FutureBuilder(
                        future: AppFunctions.getNameByEmail(
                            email: storedRolesData[i]['Assigned By']),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Text('');
                            default:
                              if (snapshot.hasError) {
                                return Container();
                              } else {
                                return Text(
                                  'Created By: ${snapshot.data}',
                                  textAlign: TextAlign.left,
                                );
                              }
                          }
                        },
                      ),
                      role: storedRolesData[i]['Role'],
                      level: storedRolesData[i]['Role Level'],
                      totals: i,
                      height: _height - 80,
                      workspaceName: widget.workspaceName,
                      workspaceCode: widget.workspaceCode,
                    ),
                  ],
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: AppColor.orange,
                strokeWidth: 2.0,
              ),
            );
          },
        ),
      ],
    );
  }
}

class ViewCard extends StatelessWidget {
  ViewCard({
    Key? key,
    required this.workspaceName,
    required this.workspaceCode,
    required this.role,
    required this.widget,
    required this.level,
    required this.height,
    required this.totals,
  }) : super(key: key);
  String workspaceName;
  String workspaceCode;
  String role;
  Widget widget;
  int level;
  double height;
  int totals;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedView(
              workspaceName: workspaceName,
              workspaceCode: workspaceCode,
              role: role,
              assignedBy: 'assignedBy',
              level: level,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level $level'),
              const Divider(),
              Center(
                child: Text(
                  role,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(),
              widget,
              // const Text(''),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/create_workspace.dart';
import 'package:stepbystep/screens/workspace_manager/task_holder_section/task_holder.dart';

import 'package:stepbystep/screens/workspace_manager/workspace_screen_combiner.dart';

class WorkspaceHome extends StatefulWidget {
  const WorkspaceHome({Key? key}) : super(key: key);

  @override
  State<WorkspaceHome> createState() => _WorkspaceHomeState();
}

class _WorkspaceHomeState extends State<WorkspaceHome> {
  bool isEmpty = false;
  List<dynamic> joinedWorkspaces = [];
  final Stream<QuerySnapshot> _workspaces = FirebaseFirestore.instance
      .collection('Workspaces')
      .orderBy('Created At', descending: true)
      .snapshots();

  getJoinedWorkspaces() async {
    final value = await FirebaseFirestore.instance
        .collection("User Data")
        .doc(currentUserEmail)
        .get();

    setState(() {
      joinedWorkspaces = value.data()!['Joined Workspaces'];
    });
    log(joinedWorkspaces.toString());
  }

  @override
  void initState() {
    getJoinedWorkspaces();
    log(currentUserEmail.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: _workspaces,
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
              final List storedWorkspaces = [];

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map id = document.data() as Map<String, dynamic>;
                storedWorkspaces.add(id);
                id['id'] = document.id;
              }).toList();
              return storedWorkspaces.isEmpty
                  ? Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          scale: 1.3,
                          image: AssetImage('assets/workspace_bg.png'),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < storedWorkspaces.length; i++) ...[
                          if (storedWorkspaces[i]['Workspace Owner Email'] ==
                              currentUserEmail) ...[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkspaceScreenCombiner(
                                        workspaceCode:
                                            "${storedWorkspaces[i]['Workspace Code']}",
                                        docId: "${storedWorkspaces[i]['id']}",
                                        workspaceName: storedWorkspaces[i]
                                            ['Workspace Name']),
                                  ),
                                );
                              },
                              child: Card(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                      storedWorkspaces[i]['Workspace Name']),
                                  subtitle: Text(
                                      storedWorkspaces[i]['Workspace Type']),
                                ),
                              ),
                            ),
                          ],
                          if (joinedWorkspaces.contains(
                              storedWorkspaces[i]['Workspace Code'])) ...[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskHolder(
                                      workspaceCode: storedWorkspaces[i]
                                          ['Workspace Code'],
                                      workspaceName: storedWorkspaces[i]
                                          ['Workspace Name'],
                                      docId: storedWorkspaces[i]['id'],
                                      workspaceOwnerName: storedWorkspaces[i]
                                          ['Workspace Owner Name'],
                                      workspaceOwnerEmail: storedWorkspaces[i]
                                          ['Workspace Owner Email'],
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                      storedWorkspaces[i]['Workspace Name']),
                                  subtitle: Text(
                                      storedWorkspaces[i]['Workspace Type']),
                                ),
                              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateWorkspace(),
            ),
          );
        },
        tooltip: 'Add Workspace',
        child: Image.asset(
          'assets/hierarchy.png',
          height: 30,
          color: AppColor.white,
        ),
      ),
    );
  }
}

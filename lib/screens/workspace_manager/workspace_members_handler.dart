import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/Task%20Assignment%20Section/task_assignment.dart';
import 'package:stepbystep/visualization/visualization.dart';
import 'package:stepbystep/widgets/app_divider.dart';
import 'package:velocity_x/velocity_x.dart';

class WorkspaceMembersHandler extends StatefulWidget {
  String docId;
  String workspaceCode;
  String workspaceName;
  WorkspaceMembersHandler(
      {Key? key,
      required this.workspaceCode,
      required this.docId,
      required this.workspaceName})
      : super(key: key);

  @override
  State<WorkspaceMembersHandler> createState() =>
      _WorkspaceMembersHandlerState();
}

class _WorkspaceMembersHandlerState extends State<WorkspaceMembersHandler> {
  String searchValue = '';
  String userName = '';
  final searchController = TextEditingController();
  List<dynamic> membersList = [];
  List<dynamic> rolesList = [];
  String selectedRoleValue = 'Assign Role';

  String assignedBy = '';
  String assignedRole = 'No Role Assign';

  int selected = -1;
  final Stream<QuerySnapshot> userRecords = FirebaseFirestore.instance
      .collection('User Data')
      // .orderBy('Created At', descending: true)
      .snapshots();
  final Stream<QuerySnapshot> workspaces = FirebaseFirestore.instance
      .collection('Workspaces')
      // .orderBy('Created At', descending: true)
      .snapshots();

  getAddedMembers() async {
    final value = await FirebaseFirestore.instance
        .collection("Workspaces")
        .doc(widget.docId)
        .get();

    setState(() {
      membersList = value.data()!['Workspace Members'];
    });
    //log(membersList.toString());
  }

  getAddedRoles() async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("Workspaces")
          .doc(widget.docId)
          .get();

      setState(() {
        rolesList = value.data()!['Workspace Roles'];
      });
      log(rolesList.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  getUserData(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("User Data")
          .doc(docId)
          .get()
          .then((ds) {
        userName = ds['User Name'];
      });
      setState(() {
        //log(userName);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  getAssignedRole(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('${widget.workspaceCode} Assigned Roles')
          .doc(email)
          .get()
          .then((ds) {
        assignedBy = ds['Assigned By'];
        assignedRole = ds['Assigned Role'];
      });
      setState(() {
        log(email);
        log(assignedRole);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    getAddedMembers();
    getAddedRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search User',
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColor.black,
                style: TextStyle(color: AppColor.black),
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide: BorderSide(color: AppColor.black, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide: BorderSide(color: AppColor.grey, width: 1.0),
                  ),
                  hintText: 'Search by email id',
                  // suffixIcon: MaterialButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       searchController.text;
                  //     });
                  //   },
                  //   textColor: AppColor.white,
                  //   color: AppColor.black,
                  //   height: 50,
                  //   child: const Icon(Icons.search, size: 30),
                  // ),
                ),
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter workspace name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: userRecords,
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
                List storedUserData = [];

                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map id = document.data() as Map<String, dynamic>;
                  storedUserData.add(id);
                  id['id'] = document.id;
                }).toList();
                return Column(
                  children: [
                    for (int i = 0; i < storedUserData.length; i++) ...[
                      if (searchValue == storedUserData[i]['User Email'] &&
                          storedUserData[i]['User Email'] !=
                              currentUserEmail) ...[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: AppColor.orange,
                              radius: 30,
                              foregroundImage:
                                  storedUserData[i]['Image URL'].isEmpty
                                      ? null
                                      : NetworkImage(
                                          storedUserData[i]['Image URL']),
                              child: Center(
                                child: Text(
                                  storedUserData[i]['User Name'][0],
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      color: AppColor.white),
                                ),
                              ),
                            ),
                            title: Text(storedUserData[i]['User Name']),
                            subtitle: Text(storedUserData[i]['User Email']),
                            trailing: MaterialButton(
                              onPressed: () {
                                if (!membersList.contains(searchValue)) {
                                  addMemberInWorkspaces(
                                      memberEmail: storedUserData[i]
                                          ['User Email']);
                                  getAddedMembers();
                                } else if (membersList.contains(searchValue)) {
                                  removeMemberFromWorkspaces(
                                      memberEmail: storedUserData[i]
                                          ['User Email']);
                                  getAddedMembers();
                                }
                              },
                              textColor: AppColor.white,
                              color: membersList.contains(searchController.text)
                                  ? AppColor.black
                                  : AppColor.orange,
                              child: membersList.contains(searchController.text)
                                  ? const Text('Added')
                                  : const Text('Add'),
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
        SingleChildScrollView(
          child: Column(
            children: [
              AppDivider(text: 'Workspace Members', color: AppColor.black),
              for (int i = 0; i < membersList.length; i++) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: ExpansionTile(
                    title: Text(
                      membersList[i],
                      style: TextStyle(color: AppColor.black),
                    ),
                    iconColor: AppColor.black,
                    onExpansionChanged: (v) async {
                      await getAssignedRole(membersList[i]);
                    },
                    // Text(
                    //   selectedRoleValue,
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    children: [
                      const Divider(
                        thickness: 2,
                        indent: 20,
                        endIndent: 20,
                      ),
                      ListTile(
                        onTap: () async {
                          await getUserData(membersList[i]);
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskTeamAssignment(
                                  name: userName,
                                  email: membersList[i],
                                  workspaceCode: widget.workspaceCode,
                                  docId: widget.docId,
                                  workspaceName: widget.workspaceName,
                                  assignedRole: assignedRole,
                                ),
                              ),
                            );
                          }
                        },
                        dense: true,
                        title: const Text('Assign Task'),
                        trailing:
                            Image.asset('assets/right-arrow3.png', height: 30),
                      ),
                      ListTile(
                        onTap: () async {
                          await getUserData(membersList[i]);
                          log(userName);
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Visualization(
                                  workspaceName: widget.workspaceName,
                                  userName: userName,
                                ),
                              ),
                            );
                          }
                        },
                        dense: true,
                        title: const Text('Check Report'),
                        trailing:
                            Image.asset('assets/bar-graph.png', height: 30),
                      ),
                      ListTile(
                        dense: true,
                        title: const Text('Assigned Role'),
                        subtitle: Text('By: $assignedBy'),
                        trailing: Text(
                          assignedRole,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Visibility(
                        visible: rolesList.isNotEmpty,
                        child: ListTile(
                          dense: true,
                          title: const Text('Assign Role'),
                          trailing: DropdownButton<dynamic>(
                            hint: const Text('Roles'),
                            isDense: true,
                            items: rolesList.map<DropdownMenuItem<dynamic>>(
                                (dynamic value) {
                              return DropdownMenuItem<dynamic>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value:
                                selectedRoleValue.isEmpty ? assignedRole : null,
                            onChanged: (value) async {
                              setState(() {
                                assignedRole = value!;
                                selectedRoleValue = value!;
                              });

                              final assignRoleJson = {
                                'Assigned Role': selectedRoleValue,
                                'Assigned By': currentUserEmail,
                                'Assigned At': DateTime.now(),
                              };
                              await FireBaseApi.saveDataIntoFireStore(
                                  collection:
                                      '${widget.workspaceCode} Assigned Roles',
                                  document: membersList[i],
                                  jsonData: assignRoleJson);
                              log('Role Assign Successfully');
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: assignedRole != 'No Role Assign',
                        child: ListTile(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection(
                                    '${widget.workspaceCode} Assigned Roles')
                                .doc(membersList[i])
                                .update({
                              'Assigned Role': 'No Role Assign',
                            });
                            log('Role De-Assign successfully');
                            setState(() {
                              assignedRole = 'No Role Assign';
                            });
                          },
                          dense: true,
                          title: const Text('De-Assign Role'),
                          trailing: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                  // ListTile(
                  //   onTap: () async {
                  //     await getUserData(membersList[i]);
                  //     if (mounted) {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => TaskAssignment(
                  //             name: userName,
                  //             email: membersList[i],
                  //             workspaceCode: widget.workspaceCode,
                  //             docId: widget.docId,
                  //             workspaceName: widget.workspaceName,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   dense: true,
                  //   title: Text(membersList[i]),
                  //   subtitle: Row(children: [
                  //     Container(
                  //       width: 50,
                  //       height: 10,
                  //       color: AppChartColor.blue,
                  //     ),
                  //     Container(
                  //       margin: const EdgeInsets.symmetric(horizontal: 10),
                  //       width: 50,
                  //       height: 10,
                  //       color: AppChartColor.yellow,
                  //     ),
                  //     Container(
                  //       width: 50,
                  //       height: 10,
                  //       color: AppChartColor.grey,
                  //     ),
                  //   ]),
                  // ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  addMemberInWorkspaces({required String memberEmail}) async {
    try {
      await FirebaseFirestore.instance
          .collection('Workspaces')
          .doc(widget.docId)
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('Member is added in Common Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection(widget.workspaceCode)
          .doc('Log')
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('Member is added in Secrete Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(memberEmail)
          .update({
        'Joined Workspaces': FieldValue.arrayUnion([widget.workspaceCode]),
      });
      log('Workspaces added in User Data');
    } catch (e) {
      log(e.toString());
    }
  }

  removeMemberFromWorkspaces({required String memberEmail}) async {
    try {
      await FirebaseFirestore.instance
          .collection('Workspaces')
          .doc(widget.docId)
          .update({
        'Workspace Members': FieldValue.arrayRemove([memberEmail]),
      });
      log('Member is removed in Common Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection(widget.workspaceCode)
          .doc('Log')
          .update({
        'Workspace Members': FieldValue.arrayRemove([memberEmail]),
      });
      log('Member is removed in Secrete Workspaces');
    } catch (e) {
      log(e.toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(memberEmail)
          .update({
        'Joined Workspaces': FieldValue.arrayRemove([widget.workspaceCode]),
      });
      log('Workspaces removed in User Data');
    } catch (e) {
      log(e.toString());
    }
  }
}

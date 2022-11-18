import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/Task%20Assignment%20Section/task_assignment.dart';
import 'package:stepbystep/widgets/app_divider.dart';

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

  @override
  void initState() {
    getAddedMembers();
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
                keyboardType: TextInputType.text,
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
                          child: ListTile(
                            dense: true,
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
                  child: ListTile(
                    onTap: () async {
                      await getUserData(membersList[i]);
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskAssignment(
                              name: userName,
                              email: membersList[i],
                              workspaceCode: widget.workspaceCode,
                              docId: widget.docId,
                              workspaceName: widget.workspaceName,
                            ),
                          ),
                        );
                      }
                    },
                    dense: true,
                    title: Text(membersList[i]),
                    subtitle: Row(children: [
                      Container(
                        width: 50,
                        height: 10,
                        color: AppChartColor.blue,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 50,
                        height: 10,
                        color: AppChartColor.yellow,
                      ),
                      Container(
                        width: 50,
                        height: 10,
                        color: AppChartColor.grey,
                      ),
                    ]),
                  ),
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

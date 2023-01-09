import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:stepbystep/apis/app_functions.dart';

import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/apis/messege_notification_api.dart';
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
  String workspaceOwnerEmail;
  bool assignTaskControl;
  bool reportControl;
  bool addMember;
  bool removeMember;
  bool assignRole;
  bool deAssignRole;
  bool fromTaskAssignment;
  bool fromTaskHolder;
  String extraEmail;
  WorkspaceMembersHandler({
    Key? key,
    required this.workspaceCode,
    required this.docId,
    required this.workspaceName,
    required this.workspaceOwnerEmail,
    required this.assignTaskControl,
    required this.reportControl,
    required this.addMember,
    required this.removeMember,
    required this.assignRole,
    required this.deAssignRole,
    required this.fromTaskAssignment,
    required this.fromTaskHolder,
    this.extraEmail = '',
  }) : super(key: key);

  @override
  State<WorkspaceMembersHandler> createState() =>
      _WorkspaceMembersHandlerState();
}

class _WorkspaceMembersHandlerState extends State<WorkspaceMembersHandler>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  String searchValue = '';
  String userName = '';
  final searchController = TextEditingController();
  List<dynamic> membersList = [];
  List<dynamic> rolesList = [];
  String selectedRoleValue = 'Assign Role';
  bool toggle = true;
  String assignedBy = '';
  String assignedRole = 'No Role Assign';
  bool tA = false, tH = false;
  int selected = -1;
  final Stream<QuerySnapshot> userRecords = FirebaseFirestore.instance
      .collection('User Data')
      // .orderBy('Created At', descending: true)
      .snapshots();
  final Stream<QuerySnapshot> workspaces = FirebaseFirestore.instance
      .collection('Workspaces')
      // .orderBy('Created At', descending: true)
      .snapshots();

  getAddedMembers({required bool tH, required bool tA}) async {
    try {
      if (widget.fromTaskHolder || tH) {
        log('From Task Holder');
        final value = await FirebaseFirestore.instance
            .collection('$currentUserEmail ${widget.workspaceCode} Team')
            .doc(widget.docId)
            .get();
        setState(() {
          membersList = value.data()!['Workspace Members'];
        });
      } else if (widget.fromTaskAssignment || tA) {
        log('From Task Assignment');
        final value = await FirebaseFirestore.instance
            .collection('${widget.extraEmail} ${widget.workspaceCode} Team')
            .doc(widget.docId)
            .get();

        setState(() {
          membersList = value.data()!['Workspace Members'];
        });
      } else {
        log('From Home Screen');
        final value = await FirebaseFirestore.instance
            .collection("Workspaces")
            .doc(widget.docId)
            .get();

        setState(() {
          membersList = value.data()!['Workspace Members'];
        });
      }

      log(membersList.toString());
    } catch (e) {
      log(e.toString());
    }
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
    setValues();
    getAddedMembers(tH: tH, tA: tA);
    getAddedRoles();
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _animationController.forward();
  }

  setValues() {
    setState(() {
      tA = widget.fromTaskAssignment;
      tH = widget.fromTaskHolder;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Search Bar
        Visibility(
          visible: !widget.fromTaskAssignment,
          child: Padding(
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
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          searchController.clear();
                          searchValue = '';
                          toggle = !toggle;
                          if (toggle) {
                            _animationController.reverse();
                          } else {
                            _animationController.forward();
                          }
                        });
                      },
                      child: Lottie.asset(
                          controller: _animationController,
                          repeat: false,
                          'animations/search.json'),
                    ),
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
                          storedUserData[i]['User Email'] != currentUserEmail &&
                          storedUserData[i]['User Email'] !=
                              widget.workspaceOwnerEmail) ...[
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
                            trailing: Visibility(
                              visible: widget.addMember,
                              child: MaterialButton(
                                onPressed: () {
                                  if (!membersList.contains(searchValue)) {
                                    addMemberInWorkspaces(
                                        memberEmail: storedUserData[i]
                                            ['User Email']);
                                    getAddedMembers(tH: tH, tA: tA);
                                  } else if (membersList
                                      .contains(searchValue)) {
                                    if (widget.removeMember) {
                                      removeMemberFromWorkspaces(
                                          memberEmail: storedUserData[i]
                                              ['User Email']);
                                      getAddedMembers(tH: tH, tA: tA);
                                    }
                                  }
                                },
                                // textColor: AppColor.white,
                                // color:
                                //     membersList.contains(searchController.text)
                                //         ? AppColor.black
                                //         : AppColor.orange,
                                child:
                                    membersList.contains(searchController.text)
                                        ? Lottie.asset(
                                            'animations/remove_member.json')
                                        // const Text('Added')
                                        : Lottie.asset(
                                            'animations/add_member.json'),
                                // const Text('Add'),
                              ),
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
        Column(
          children: [
            AppDivider(text: 'Workspace Members', color: AppColor.black),
            for (int i = 0; i < membersList.length; i++) ...[
              if (membersList[i] != currentUserEmail) ...[
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
                    subtitle: Row(
                      children: [
                        Lottie.asset(repeat: false, 'animations/blue-bar.json'),
                        Lottie.asset(
                            repeat: false, 'animations/yellow-bar.json'),
                        Lottie.asset(repeat: false, 'animations/grey-bar.json'),
                        // Container(
                        //   width: 50,
                        //   height: 10,
                        //   color: AppChartColor.blue,
                        //   child:
                        // ),
                        // Container(
                        //   margin: const EdgeInsets.symmetric(horizontal: 10),
                        //   width: 50,
                        //   height: 10,
                        //   color: AppChartColor.yellow,
                        // ),
                        // Container(
                        //   width: 50,
                        //   height: 10,
                        //   color: AppChartColor.grey,
                        // ),
                      ],
                    ),
                    onExpansionChanged: (v) async {
                      await getAssignedRole(membersList[i]);
                    },
                    children: [
                      Lottie.asset(
                          reverse: true,
                          repeat: false,
                          'animations/grey-divider.json'),
                      // const Divider(
                      //   thickness: 2,
                      //   indent: 20,
                      //   endIndent: 20,
                      // ),
                      Visibility(
                        visible: widget.assignTaskControl,
                        child: ListTile(
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
                                    workspaceOwnerEmail:
                                        widget.workspaceOwnerEmail,
                                    assignedRole: assignedRole,
                                  ),
                                ),
                              );
                            }
                          },
                          dense: true,
                          title: const Text('Assign Task'),
                          trailing: Lottie.asset(
                              repeat: false,
                              height: 40,
                              'animations/add-to-box.json'),

                          // Image.asset('assets/right-arrow3.png',
                          //     height: 30),
                        ),
                      ),
                      Visibility(
                        visible: widget.reportControl,
                        child: ListTile(
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
                          trailing: Lottie.asset(
                              repeat: false,
                              height: 35,
                              'animations/graph.json'),
                          // Image.asset('assets/bar-graph.png', height: 30),
                        ),
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
                      Lottie.asset(
                          reverse: true,
                          repeat: false,
                          'animations/grey-divider.json'),
                      // const Divider(
                      //   thickness: 2,
                      //   indent: 20,
                      //   endIndent: 20,
                      // ),
                      Visibility(
                        visible: widget.assignRole,
                        child: Visibility(
                          visible: rolesList.isNotEmpty,
                          child: ListTile(
                            dense: true,
                            title: const Text('Assign Role'),
                            subtitle: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DropdownButton<dynamic>(
                                  hint: const Text('Roles'),
                                  isDense: true,
                                  items: rolesList
                                      .map<DropdownMenuItem<dynamic>>(
                                          (dynamic value) {
                                    return DropdownMenuItem<dynamic>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: selectedRoleValue.isEmpty
                                      ? assignedRole
                                      : null,
                                  onChanged: (value) async {
                                    setState(() {
                                      assignedRole = value!;
                                      assignedBy = currentUserEmail.toString();
                                      selectedRoleValue = value!;
                                    });

                                    final assignRoleJson = {
                                      'Assigned Role': selectedRoleValue,
                                      'Assigned By': currentUserEmail,
                                      'Assigned At': DateTime.now(),
                                    };

                                    try {
                                      await FireBaseApi.saveDataIntoFireStore(
                                          workspaceCode: widget.workspaceCode,
                                          collection:
                                              '${widget.workspaceCode} Assigned Roles',
                                          document: membersList[i],
                                          jsonData: assignRoleJson);

                                      await FirebaseFirestore.instance
                                          .collection('User Data')
                                          .doc(membersList[i])
                                          .collection('Workspace Roles')
                                          .doc(widget.workspaceCode)
                                          .set({
                                        'Role': AppFunctions.getStringOnly(
                                            text: selectedRoleValue),
                                        'Level':
                                            AppFunctions.getNumberFromString(
                                                text: selectedRoleValue),
                                        'Created At': DateTime.now(),
                                      });

                                      log('Role Assign Successfully');

                                      String name =
                                          await AppFunctions.getNameByEmail(
                                              email:
                                                  widget.workspaceOwnerEmail);
                                      String token =
                                          await AppFunctions.getTokenByEmail(
                                              email: membersList[i]);
                                      MessageNotificationApi.send(
                                          token: token,
                                          title: 'Congratulations ☺',
                                          body:
                                              '$name assign you ${AppFunctions.getStringOnly(text: selectedRoleValue)} role of Level ${AppFunctions.getNumberFromString(text: selectedRoleValue)} in ${widget.workspaceName} workspace.');
                                    } catch (e) {
                                      log('Role Assign Failed');
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.deAssignRole,
                        child: Visibility(
                          visible: assignedRole != 'No Role Assign',
                          child: ListTile(
                            onTap: () async {
                              await FirebaseFirestore.instance
                                  .collection(
                                      '${widget.workspaceCode} Assigned Roles')
                                  .doc(membersList[i])
                                  .update({
                                'Assigned By': '',
                                'Assigned Role': 'No Role Assign',
                              });

                              await FirebaseFirestore.instance
                                  .collection('User Data')
                                  .doc(membersList[i])
                                  .collection('Workspace Roles')
                                  .doc(widget.workspaceCode)
                                  .delete();

                              log('Role De-Assign successfully');

                              String name = await AppFunctions.getNameByEmail(
                                  email: widget.workspaceOwnerEmail);
                              String token = await AppFunctions.getTokenByEmail(
                                  email: membersList[i]);
                              MessageNotificationApi.send(
                                  token: token,
                                  title: 'Oh No 😟',
                                  body:
                                      '$name de-assign your role from ${widget.workspaceName} workspace.');
                              setState(() {
                                assignedRole = 'No Role Assign';
                                assignedBy = '';
                              });
                            },
                            dense: true,
                            title: const Text('De-Assign Role'),
                            trailing: Lottie.asset(
                                repeat: false,
                                height: 30,
                                'animations/crossbutton.json'),
                            // const Icon(Icons.close),
                          ),
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
            ]
          ],
        ),
      ],
    );
  }

  addMemberInWorkspaces({required String memberEmail}) async {
    log('------------------------------------');
    log('Member in adding in to workspace');
    log(widget.workspaceOwnerEmail);
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
      String name =
          await AppFunctions.getNameByEmail(email: widget.workspaceOwnerEmail);
      String token = await AppFunctions.getTokenByEmail(email: memberEmail);
      MessageNotificationApi.send(
          token: token,
          title: 'Awesome ☺',
          body: '$name added you in ${widget.workspaceName} workspace.');
    } catch (e) {
      log(e.toString());
    }
    try {
      await FirebaseFirestore.instance
          .collection('$currentUserEmail ${widget.workspaceCode} Team')
          .doc(widget.workspaceCode)
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('------------------------------------');
    } catch (e) {
      log(e.toString());

      await FireBaseApi.saveDataIntoFireStore(
          workspaceCode: widget.workspaceCode,
          collection: '$currentUserEmail ${widget.workspaceCode} Team',
          document: widget.workspaceCode,
          jsonData: {
            'Workspace Members': [],
          });
      // await FirebaseFirestore.instance
      //     .collection('$currentUserEmail ${widget.workspaceCode} Team')
      //     .doc(widget.workspaceCode)
      //     .set({
      //   'Workspace Members': [],
      // });
      await FirebaseFirestore.instance
          .collection('$currentUserEmail ${widget.workspaceCode} Team')
          .doc(widget.workspaceCode)
          .update({
        'Workspace Members': FieldValue.arrayUnion([memberEmail]),
      });
      log('------------------------------------');
    }
  }

  removeMemberFromWorkspaces({required String memberEmail}) async {
    log('------------------------------------');
    log('Member in removing from workspace');
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

    try {
      await FirebaseFirestore.instance
          .collection('$currentUserEmail ${widget.workspaceCode} Team')
          .doc(widget.workspaceCode)
          .update({
        'Workspace Members': FieldValue.arrayRemove([memberEmail]),
      });
      String name =
          await AppFunctions.getNameByEmail(email: widget.workspaceOwnerEmail);
      String token = await AppFunctions.getTokenByEmail(email: memberEmail);
      MessageNotificationApi.send(
          token: token,
          title: 'Oh No 😟',
          body: '$name removed you from ${widget.workspaceName} workspace.');
      log('------------------------------------');
    } catch (e) {
      log(e.toString());
    }
  }
}

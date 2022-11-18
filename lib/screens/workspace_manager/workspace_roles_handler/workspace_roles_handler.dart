import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/workspace_roles_handler/workspace_role_card.dart';

import 'package:stepbystep/widgets/app_elevated_button.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stepbystep/widgets/app_progress_indicator.dart';

class WorkspaceRolesHandler extends StatefulWidget {
  WorkspaceRolesHandler(
      {Key? key,
      required this.workspaceCode,
      required this.docId,
      required this.workspaceName})
      : super(key: key);
  String workspaceCode;
  String docId;
  String workspaceName;

  @override
  State<WorkspaceRolesHandler> createState() => _WorkspaceRolesHandlerState();
}

class _WorkspaceRolesHandlerState extends State<WorkspaceRolesHandler> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int roleLevel = 1;

  final roleController = TextEditingController();
  final descriptionController = TextEditingController();
  late final Stream<QuerySnapshot> rolesRecords;
  bool createRoleLoading = false;
  @override
  void initState() {
    rolesRecords = FirebaseFirestore.instance
        .collection('${widget.workspaceCode} Roles')
        .orderBy('Role Level', descending: false)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
                ));
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
                    for (int i = 0; i < storedRolesData.length; i++) ...[
                      WorkspaceRoleCard(
                        id: storedRolesData[i]['id'],
                        workspaceCode: widget.workspaceCode,
                        roleName: storedRolesData[i]['Role'],
                        roleDescription: storedRolesData[i]['Role Description'],
                        roleLevel: storedRolesData[i]['Role Level'].toString(),
                        teamControl: storedRolesData[i]['Team Control'],
                        roleControl: storedRolesData[i]['Role Control'],
                        taskControl: storedRolesData[i]['Task Control'],
                        viewControl: storedRolesData[i]['View Control'],
                      ),
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
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: AppElevatedButton(
            text: 'Create Role',
            fontSize: 12,
            backgroundColor: AppColor.orange,
            foregroundColor: AppColor.orange,
            textColor: AppColor.white,
            function: () {
              createRoleDialog();
            },
          ),
        ),
      ],
    );
  }

  void createRoleDialog() {
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
                height: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColor.white),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Define Role',
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
                                  'Role Name',
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
                                    hintText: 'Chief executive officer',
                                  ),
                                  controller: roleController,
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
                                  'Role Description',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  cursorColor: AppColor.black,
                                  maxLength: 300,
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
                      const SizedBox(height: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Role Level',
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          NumberPicker(
                            value: roleLevel,
                            minValue: 1,
                            maxValue: 10,
                            axis: Axis.horizontal,
                            itemCount: 3,
                            itemWidth: 50,
                            itemHeight: 30,
                            onChanged: (value) =>
                                setState(() => roleLevel = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      createRoleLoading
                          ? AppProgressIndicator(
                              radius: 25,
                              size: 30,
                            )
                          : AppElevatedButton(
                              text: 'Create',
                              width: 100,
                              fontSize: 12,
                              textColor: AppColor.white,
                              backgroundColor: AppColor.orange,
                              function: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    createRoleLoading = true;
                                  });
                                  final roleJson = {
                                    'Role': roleController.text.trim(),
                                    'Role Description':
                                        descriptionController.text.isEmpty
                                            ? ''
                                            : descriptionController.text.trim(),
                                    'Role Level': roleLevel,
                                    'Team Control': false,
                                    'Role Control': false,
                                    'Task Control': false,
                                    'View Control': false,
                                    'Assigned By': currentUserEmail,
                                    'Created At': DateTime.now(),
                                  };

                                  // await FireBaseApi
                                  //     .saveDataIntoDoubleCollectionFireStore(
                                  //   mainCollection: 'Workspace Roles',
                                  //   mainDocument: widget.workspaceCode,
                                  //   subCollection: 'Log',
                                  //   subDocument: '${roleController.text} $roleLevel',
                                  //   jsonData: roleJson,
                                  // );

                                  await FireBaseApi.saveDataIntoFireStore(
                                      collection:
                                          '${widget.workspaceCode} Roles',
                                      document:
                                          '${roleController.text} $roleLevel',
                                      jsonData: roleJson);

                                  await addRolesInFirebase();
                                  if (mounted) {
                                    roleController.clear();
                                    descriptionController.clear();
                                    Navigator.pop(context);
                                    setState(() {
                                      createRoleLoading = false;
                                    });
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

  Future<void> addRolesInFirebase() async {
    await FirebaseFirestore.instance
        .collection('Workspaces')
        .doc(widget.workspaceCode)
        .update({
      'Workspace Roles':
          FieldValue.arrayUnion(['${roleController.text} $roleLevel']),
    });
    log('Role added in Workspaces');

    await FirebaseFirestore.instance
        .collection(widget.workspaceCode)
        .doc('Log')
        .update({
      'Workspace Roles':
          FieldValue.arrayUnion(['${roleController.text} $roleLevel']),
    });
    log('Role added in Workspaces');
  }
}

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';

class WorkspaceScreenCombiner extends StatefulWidget {
  String workspaceName;
  WorkspaceScreenCombiner({Key? key, required this.workspaceName})
      : super(key: key);

  @override
  State<WorkspaceScreenCombiner> createState() =>
      _WorkspaceScreenCombinerState();
}

class _WorkspaceScreenCombinerState extends State<WorkspaceScreenCombiner> {
  String searchValue = '';
  final Stream<QuerySnapshot> userRecords = FirebaseFirestore.instance
      .collection('User Data')
      // .orderBy('Created At', descending: true)
      .snapshots();

  saveData(String userEmail) async {
    log('Data is saving from Firestore');
    final obj = {
      'Workspace Name': widget.workspaceName,
      'Owner Email': currentUserEmail,
      'Joined At': DateTime.now(),
    };
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(userEmail)
          .update({
        'Joined Workspaces': FieldValue.arrayUnion([obj]),
      });
    } catch (e) {
      log(e.toString());
    }
  }

  removeFromWorkSpace(String userEmail) async {
    log('Data is saving from Firestore');

    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(userEmail)
          .update({
        'Joined Workspaces': FieldValue.arrayRemove([widget.workspaceName]),
      });
    } catch (e) {
      log(e.toString());
    }
  }

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
      ),
      body: Column(
        children: [
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
                    suffixIcon: MaterialButton(
                      onPressed: () {},
                      textColor: AppColor.white,
                      color: AppColor.black,
                      height: 50,
                      child: const Icon(Icons.search, size: 30),
                    ),
                  ),
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
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  return Column(
                    children: [
                      for (int i = 0; i < storedWorkspaces.length; i++) ...[
                        if (searchValue ==
                            storedWorkspaces[i]['User Email']) ...[
                          Card(
                            child: ListTile(
                              dense: true,
                              title: Text(storedWorkspaces[i]['User Name']),
                              subtitle: Text(storedWorkspaces[i]['User Email']),
                              trailing: MaterialButton(
                                onPressed: () {
                                  saveData(storedWorkspaces[i]['User Email']);
                                  //removeFromWorkSpace(
                                  //storedWorkspaces[i]['User Email']);
                                },
                                textColor: AppColor.white,
                                color: AppColor.orange,
                                child: const Text('Add'),
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
        ],
      ),
    );
  }
}

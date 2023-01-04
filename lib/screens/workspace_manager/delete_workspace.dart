import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class WorkspaceDeleteOperation extends StatelessWidget {
  String ownerEmail;
  String workspaceName;
  String workspaceCode;
  WorkspaceDeleteOperation(
      {Key? key,
      required this.ownerEmail,
      required this.workspaceName,
      required this.workspaceCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class DeleteWorkspace {
  String ownerEmail;
  String workspaceName;
  String workspaceCode;

  DeleteWorkspace(
      {required this.ownerEmail,
      required this.workspaceName,
      required this.workspaceCode}) {
    showMessage();
    getCollectionsHistory();
  }

  void showMessage() {
    log(ownerEmail);
    log(workspaceName);
    log(workspaceCode);
  }

  void getCollectionsHistory() async {
    final result = await FirebaseFirestore.instance
        .collection('Collection History $workspaceCode')
        .get();

    final List<DocumentSnapshot> documents = result.docs;
    for (var doc in documents) {
      if (doc.id == 'Workspaces') {
      } else if (doc.id == 'Workspaces Task Log') {
        try {
          final value = await FirebaseFirestore.instance
              .collection('Workspaces')
              .doc(workspaceCode)
              .get();
          List<dynamic> workspacesMembers = value.data()!['Workspace Members'];
          log(workspacesMembers.toString());

          for (var member in workspacesMembers) {
            await FirebaseFirestore.instance
                .collection('Workspaces Task Log')
                .doc('$member $workspaceCode')
                .delete();
          }
          for (var member in workspacesMembers) {
            await FirebaseFirestore.instance
                .collection('User Data')
                .doc(member)
                .update({
              'Joined Workspaces': FieldValue.arrayRemove([workspaceCode]),
              'Owned Workspaces': FieldValue.arrayRemove([workspaceCode]),
            });
          }
        } catch (e) {
          log(e.toString());
        }
      } else {
        runDeleteOperation(doc.id);
        await FirebaseFirestore.instance
            .collection('Workspaces')
            .doc(workspaceCode)
            .delete();
        deleteCollectionHistory();
      }
    }
  }

  void runDeleteOperation(String id) async {
    try {
      var collection = FirebaseFirestore.instance.collection(id);
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      log('Deleted: $id');
    } catch (e) {
      log(e.toString());
    }
  }

  void deleteCollectionHistory() async {
    try {
      var collection = FirebaseFirestore.instance
          .collection('Collection History $workspaceCode');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
//Collections
//1.User Data           -> Delete Later
//2.Workspaces          -> Delete Later
//3.workspace_code      -> Delete Later

//Workspaces Task Log

//email workspace_code
//email Chat
//email workspace_code Team
//workspace_code Assigned Roles

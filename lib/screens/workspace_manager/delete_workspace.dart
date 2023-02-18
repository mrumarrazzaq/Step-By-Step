import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/config.dart';

class DeleteWorkspace {
  BuildContext context;
  String ownerEmail;
  String workspaceName;
  String workspaceCode;

  DeleteWorkspace(
      {required this.context,
      required this.ownerEmail,
      required this.workspaceName,
      required this.workspaceCode}) {
    log('Workspace deletion is in progress .....................');
    runDeleteOperation();
  }

  Future<bool> runDeleteOperation() async {
    await deleteWorkspaceCompletely();
    return true;
  }

  Future<void> deleteWorkspaceCompletely() async {
    try {
      final List<DocumentSnapshot> documents = await getCollectionsHistory();
      for (var doc in documents) {
        if (doc.id == 'Workspaces') {
          log('++++++++++++++++++++++++++++++++');

          await FirebaseFirestore.instance
              .collection('User Data')
              .doc(ownerEmail)
              .collection('Workspace Roles')
              .doc(workspaceCode)
              .delete();
          log('User Data -> Workspace Roles(Self) -> Delete Successfully');
          await FirebaseFirestore.instance
              .collection('User Data')
              .doc(ownerEmail)
              .update({
            'Owned Workspaces': FieldValue.arrayRemove([workspaceCode]),
          });
          log('User Data -> Owned Workspaces -> Delete Successfully');
          List<dynamic> workspacesMembers = await getWorkspaceMembers();
          log(workspacesMembers.toString());
          for (var member in workspacesMembers) {
            await FirebaseFirestore.instance
                .collection('User Data')
                .doc(member)
                .collection('Workspace Roles')
                .doc(workspaceCode)
                .delete();
          }
          log('User Data -> Workspace Roles(Others) -> Delete Successfully');
          for (var member in workspacesMembers) {
            await FirebaseFirestore.instance
                .collection('User Data')
                .doc(member)
                .update({
              'Joined Workspaces': FieldValue.arrayRemove([workspaceCode]),
            });

            await FirebaseFirestore.instance
                .collection('$workspaceCode Members')
                .doc(member)
                .delete();
          }
          log('User Data -> Joined Workspaces -> Delete Successfully');
        } else {
          await deleteCollectionOneByOne(doc.id);
          await FirebaseFirestore.instance
              .collection('Workspaces')
              .doc(workspaceCode)
              .delete();
          log('Workspaces -> Delete Successfully');
          await deleteCollectionHistory();
        }
      }
    } catch (e) {
      log(e.toString());
      log('error error error in workspace deletion');
    }
  }

  Future<List<dynamic>> getWorkspaceMembers() async {
    final value = await FirebaseFirestore.instance
        .collection('Workspaces')
        .doc(workspaceCode)
        .get();

    List<dynamic> workspacesMembers = value.data()!['Workspace Members'];
    return workspacesMembers;
  }

  Future<List<DocumentSnapshot>> getCollectionsHistory() async {
    final collectionHistory = await FirebaseFirestore.instance
        .collection('Collection History $workspaceCode')
        .get();

    List<DocumentSnapshot> documents = collectionHistory.docs;
    log('Collections History Get Successfully');
    return documents;
  }

  Future<void> deleteCollectionOneByOne(String id) async {
    try {
      var collection = FirebaseFirestore.instance.collection(id);
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      log('$id -> Delete Successfully');
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> deleteCollectionHistory() async {
    try {
      var collection = FirebaseFirestore.instance
          .collection('Collection History $workspaceCode');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      log('Collection History -> Delete Successfully');
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

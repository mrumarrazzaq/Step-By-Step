import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/config.dart';

class DeleteWorkspace {
  BuildContext context;
  String ownerEmail;
  String workspaceName;
  String workspaceCode;

  DeleteWorkspace({
    required this.context,
    required this.ownerEmail,
    required this.workspaceName,
    required this.workspaceCode,
  }) {
    log('Workspace deletion is in progress .....................');
    runDeleteOperation();
  }

  Future<bool> runDeleteOperation() async {
    List<dynamic> members = await getWorkspaceMembers();
    log(members.toString());

    // await deleteMembers();
    // await deleteTeams(members);
    //
    // await deleteRoles();
    // await deleteAssignedRoles();
    //
    // await deleteTasks(members);
    // await deleteTaskLogs(members);
    //
    // await deleteReports(members);
    //
    // await removeMembersFromJoinedWorkspaces(members);
    // await removeWorkspaceRoleFromUserData(members);
    // await removeOwnerFromOwnedWorkspaces();
    //
    // await deleteWorkspaceHistory();

    await deleteCollectionHistory();

    return true;
  }

  Future<List<dynamic>> getWorkspaceMembers() async {
    final value = await FirebaseFirestore.instance
        .collection('Workspaces')
        .doc(workspaceCode)
        .get();

    List<dynamic> workspacesMembers = value.data()!['Workspace Members'];
    workspacesMembers.add(currentUserEmail.toString());
    return workspacesMembers;
  }

  Future<void> deleteMembers() async {
    try {
      await deleteCompleteCollection('$workspaceCode Members');
      log('Delete Role');
    } catch (e) {
      log('Error Delete Role');
    }
    log('**********************************');
  }

  Future<void> deleteTeams(List<dynamic> members) async {
    for (var id in members) {
      try {
        await deleteCompleteCollection('$id $workspaceCode Team');
        log('Delete Team');
      } catch (e) {
        log('Error Delete Team');
      }
    }
    log('**********************************');
  }

  Future<void> deleteRoles() async {
    try {
      await deleteCompleteCollection('$workspaceCode Roles');
      log('Delete Role');
    } catch (e) {
      log('Error Delete Role');
    }

    log('**********************************');
  }

  Future<void> deleteAssignedRoles() async {
    try {
      await deleteCompleteCollection('$workspaceCode Assigned Roles');
      log('Delete Assigned Role');
    } catch (e) {
      log('Error Delete Assigned Role');
    }

    log('**********************************');
  }

  Future<void> deleteTasks(List<dynamic> members) async {
    for (var id in members) {
      try {
        await deleteCompleteCollection('$id $workspaceCode');
        log('Delete Task');
      } catch (e) {
        log('Error Delete Task');
      }
    }
    log('**********************************');
  }

  Future<void> deleteTaskLogs(List<dynamic> members) async {
    for (var id in members) {
      try {
        await FirebaseFirestore.instance
            .collection('Workspaces Task Log')
            .doc('$id $workspaceCode')
            .delete();
        log('Delete Task Log');
      } catch (e) {
        log('Error Delete Task Log');
      }
    }
    log('**********************************');
  }

  Future<void> deleteReports(List<dynamic> members) async {
    for (var id in members) {
      try {
        await deleteCompleteCollection('Report $id $workspaceCode');
        log('Delete Report');
      } catch (e) {
        log('Error Delete Report');
      }
    }
    log('**********************************');
  }

  Future<void> removeMembersFromJoinedWorkspaces(List<dynamic> members) async {
    for (var id in members) {
      try {
        await FirebaseFirestore.instance
            .collection('User Data')
            .doc(id)
            .update({
          'Joined Workspaces': FieldValue.arrayRemove([workspaceCode]),
        });
        log('Remove Joined Workspace');
      } catch (e) {
        log('Error Remove Joined Workspace');
      }
    }
    log('**********************************');
  }

  Future<void> removeOwnerFromOwnedWorkspaces() async {
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(currentUserEmail)
          .update({
        'Owned Workspaces': FieldValue.arrayRemove([workspaceCode]),
      });
      log('Remove Owned Workspace');
    } catch (e) {
      log('Error Remove Owned Workspace');
    }

    log('**********************************');
  }

  Future<void> removeWorkspaceRoleFromUserData(List<dynamic> members) async {
    for (var id in members) {
      try {
        await FirebaseFirestore.instance
            .collection('User Data')
            .doc(id)
            .collection('Workspace Roles')
            .doc(workspaceCode)
            .delete();
        log('Remove  Workspace Role From User Data');
      } catch (e) {
        log('Error Remove  Workspace Role From User Data');
      }
    }
    log('**********************************');
  }

  Future<void> deleteWorkspaceHistory() async {
    try {
      await deleteCompleteCollection(workspaceCode);
      await FirebaseFirestore.instance
          .collection('Workspaces')
          .doc(workspaceCode)
          .delete();

      log('Delete Workspace History');
    } catch (e) {
      log('Error Delete Workspace History');
    }

    log('**********************************');
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

  Future<void> deleteCompleteCollection(String id) async {
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

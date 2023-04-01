import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppFunctions {
  static Future<String> getNameByEmail({required String email}) async {
    String name = '';
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(email)
          .get()
          .then((ds) {
        name = ds['User Name'];
      });
      return name;
    } catch (e) {
      log(e.toString());
      return name;
    }
  }

  static int getNumberFromString({required String text}) {
    String temp = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.parse(temp);
  }

  static String getStringOnly({required String text}) {
    String temp = text.replaceAll(RegExp(r'\d+$'), '');
    return temp.trimRight();
    // List<String> temp = text.split(' ');
    //
    // if (temp.length == 1) {
    //   return temp[0];
    // } else if (temp.length == 2) {
    //   return '${temp[0]} ${temp[1]}';
    // } else if (temp.length == 3) {
    //   return '${temp[0]} ${temp[1]} ${temp[2]}';
    // } else if (temp.length == 4) {
    //   return '${temp[0]} ${temp[1]} ${temp[2]} ${temp[3]}';
    // } else if (temp.length == 5) {
    //   return '${temp[0]} ${temp[1]} ${temp[2]} ${temp[3]} ${temp[4]}';
    // } else {
    //   return temp[0];
    // }
  }

  static Future<String> getTokenByEmail({required String email}) async {
    String token = '';
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(email)
          .collection('Token')
          .doc(email)
          .get()
          .then((ds) {
        token = ds['token'];
        log(token);
      });
      return token;
    } catch (e) {
      log('Failed to get token by email');
      return token;
    }
  }

  static Future<String> getRoleByEmail(
      {required String email, required String workspaceCode}) async {
    String role = '';
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(email)
          .collection('Workspace Roles')
          .doc(workspaceCode)
          .get()
          .then((ds) {
        role = ds['Role'];
        role = '$role ${ds['Level']}';
      });
      return role;
    } catch (e) {
      log('Failed to get role by email');
      return role;
    }
  }

  static Future<String> getWorkspaceNameByWorkspaceCode(
      {required String workspaceCode}) async {
    String workspaceName = '';
    try {
      await FirebaseFirestore.instance
          .collection('Workspaces')
          .doc(workspaceCode)
          .get()
          .then((ds) {
        workspaceName = ds['Workspace Name'];
      });
      return workspaceName;
    } catch (e) {
      log('Failed to get role by email');
      return workspaceName;
    }
  }

  static Future<String> getColorCodeByRole(
      {required String workspaceCode, required String role}) async {
    String colorCode = '0xffffffff';
    try {
      await FirebaseFirestore.instance
          .collection(workspaceCode)
          .doc(role)
          .get()
          .then((ds) {
        colorCode = ds['Role Color'];
      });
      return colorCode;
    } catch (e) {
      log('Failed to get role by email');
      return colorCode;
    }
  }

  static Future<String> getWorkspaceType(
      {required String workspaceCode}) async {
    String workspaceType = '';
    try {
      await FirebaseFirestore.instance
          .collection('Workspaces')
          .doc(workspaceCode)
          .get()
          .then((ds) {
        workspaceType = ds['Workspace Type'];
      });
      return workspaceType;
    } catch (e) {
      log('Failed to get workspace type');
      return workspaceType;
    }
  }
}

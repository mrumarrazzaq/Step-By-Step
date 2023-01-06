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
    List<String> temp = text.split(' ');
    return temp[0];
  }
}

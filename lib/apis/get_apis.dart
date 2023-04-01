import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stepbystep/config.dart';

class GetApi {
  static Future<bool> isPaidAccount() async {
    bool value = false;
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(currentUserEmail)
          .get()
          .then((ds) {
        value = ds['Paid Account'];
      });
    } catch (e) {
      log(e.toString());
    }
    return value;
  }
}

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stepbystep/config.dart';

class FireBaseApi {
  static Future<void> CreateCollectionAutoDoc(
      {required String collection,
      required Map<String, dynamic> jsonData}) async {
    await FirebaseFirestore.instance.collection(collection).doc().set(jsonData);
  }

  static Future<void> SaveDataIntoFireStore(
      {required String collection,
      required String document,
      required Map<String, dynamic> jsonData}) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(document)
        .set(jsonData);
  }

  static Future<void> SaveDataIntoWorSpaceFireStore(
      {required String workspaceName,
      required String document,
      required Map<String, dynamic> jsonData}) async {
    await FirebaseFirestore.instance
        .collection('WorkSpaces')
        .doc(currentUserEmail)
        .collection(workspaceName)
        .doc(document)
        .set(jsonData);
  }
}

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stepbystep/apis/collection_history.dart';
import 'package:stepbystep/config.dart';

class FireBaseApi {
  static Future<void> createCollectionAutoDoc(
      {required String workspaceCode,
      required String collection,
      required Map<String, dynamic> jsonData}) async {
    await FirebaseFirestore.instance.collection(collection).doc().set(jsonData);

    await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: workspaceCode,
        collectionName: collection,
        docName: 'AUTO');
  }

  static Future<void> saveDataIntoFireStore(
      {required String workspaceCode,
      required String collection,
      required String document,
      required Map<String, dynamic> jsonData}) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(document)
        .set(jsonData);

    await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: workspaceCode,
        collectionName: collection,
        docName: document);
  }

  static Future<void> saveDataIntoWorSpaceFireStore(
      {required String workspaceCode,
      required String workspaceName,
      required String document,
      required Map<String, dynamic> jsonData}) async {
    await FirebaseFirestore.instance
        .collection('WorkSpaces')
        .doc(currentUserEmail)
        .collection(workspaceName)
        .doc(document)
        .set(jsonData);

    await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: workspaceCode,
        collectionName: workspaceName,
        docName: document);
  }

  static Future<void> saveDataIntoDoubleCollectionFireStore(
      {required String workspaceCode,
      required String mainCollection,
      required String subCollection,
      required String mainDocument,
      required String subDocument,
      required Map<String, dynamic> jsonData}) async {
    await FirebaseFirestore.instance
        .collection(mainCollection)
        .doc(mainDocument)
        .collection(subCollection)
        .doc(subDocument)
        .set(jsonData);

    await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: workspaceCode,
        collectionName: mainCollection,
        docName: mainDocument);
  }

  static Future<String> getDocIdByField(
      {required String collectionName,
      required String fieldName,
      required String fieldValue}) async {
    String documentID = '';

    CollectionReference doc =
        FirebaseFirestore.instance.collection(collectionName);

    QuerySnapshot querySnapshot =
        await doc.where(fieldName, isEqualTo: fieldValue).get();

    if (querySnapshot.docs.isNotEmpty) {
      documentID = querySnapshot.docs.first.id;
      print('Document ID: $documentID');
      return documentID;
    } else {
      print('No matching documents found');
      return documentID;
    }
  }
}

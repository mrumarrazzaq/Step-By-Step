import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionDocHistory {
  static Future<void> saveCollectionHistory({
    required String workspaceCode,
    required String collectionName,
    required String docName,
  }) async {
    await FirebaseFirestore.instance
        .collection('Collection History $workspaceCode')
        .doc(collectionName)
        .set({
      'Collection Name': collectionName,
      'Doc Name': docName,
    });
  }
}

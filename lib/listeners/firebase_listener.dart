import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseListener {
  static void listenToFirestoreUpdates() {
    FirebaseFirestore.instance
        .collection('User Data')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          // Document added
          log('New document added: ${change.doc.id}');
        } else if (change.type == DocumentChangeType.modified) {
          // Document modified
          log('Document modified: ${change.doc.id}');
        } else if (change.type == DocumentChangeType.removed) {
          // Document removed
          log('Document removed: ${change.doc.id}');
        }
      });
    });
  }

  static bool listenToDocumentUpdates({required String email}) {
    var myFieldValue = true;
    FirebaseFirestore.instance
        .collection('User Data')
        .doc(email)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        myFieldValue = snapshot.get('Paid Account');
        log('my_field value has been updated: $myFieldValue');
      } else {
        myFieldValue = false;
        log('Document does not exist');
      }
    });
    return myFieldValue;
  }
}

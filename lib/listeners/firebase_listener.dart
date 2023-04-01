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
          print('New document added: ${change.doc.id}');
        } else if (change.type == DocumentChangeType.modified) {
          // Document modified
          print('Document modified: ${change.doc.id}');
        } else if (change.type == DocumentChangeType.removed) {
          // Document removed
          print('Document removed: ${change.doc.id}');
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
        print('my_field value has been updated: $myFieldValue');
      } else {
        myFieldValue = false;
        print('Document does not exist');
      }
    });
    return myFieldValue;
  }
}

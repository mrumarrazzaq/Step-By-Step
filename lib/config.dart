import 'package:firebase_auth/firebase_auth.dart';

final currentUserId = FirebaseAuth.instance.currentUser!.uid;
final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

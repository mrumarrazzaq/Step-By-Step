import 'package:firebase_auth/firebase_auth.dart';

var currentUser = FirebaseAuth.instance.currentUser;
var currentUserId = FirebaseAuth.instance.currentUser!.uid;
var currentUserEmail = FirebaseAuth.instance.currentUser!.email;

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/screens/user_profile_section/profile_header.dart';

class UserProfile extends StatefulWidget {
  static const String id = 'UserProfile';

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = '';
  String imageURL = '';
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user!.email)
          .get()
          .then((ds) {
        userName = ds['User Name'];
        imageURL = ds['Image URL'];
      });
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            text: '', // default text style
            children: <TextSpan>[
              TextSpan(
                  text: 'User Profile ',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileHeader(userName: userName, imageURL: imageURL),
          ],
        ),
      ),
    );
  }
}

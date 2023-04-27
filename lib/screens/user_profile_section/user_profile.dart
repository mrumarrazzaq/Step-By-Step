import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/user_profile_section/profile_header.dart';

class UserProfile extends StatefulWidget {
  static const String id = 'UserProfile';
  const UserProfile({
    Key? key,
  }) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                text: 'User Profile',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('User Data').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                log('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                log('Waiting for know user online status');
              }

              final List data = [];
              if (snapshot.hasData) {
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map id = document.data() as Map<String, dynamic>;
                  if (currentUserEmail.toString() == document.id) {
                    data.add(id);
                    id['id'] = document.id;
                  }
                }).toList();
              }
              return ProfileHeader(
                userName: snapshot.hasData ? data[0]['User Name'] : '',
                imageURL: snapshot.hasData ? data[0]['Image URL'] : '',
              );
            },
          ),
          //   ProfileHeader(
          //       userName: widget.userName, imageURL: widget.imageURL),
          // ),
        ),
      ),
    );
  }
}

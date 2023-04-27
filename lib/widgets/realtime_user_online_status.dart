import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stepbystep/colors.dart';

class RealtimeUserOnlineStatus extends StatelessWidget {
  const RealtimeUserOnlineStatus({Key? key, required this.receiverEmail})
      : super(key: key);
  final String receiverEmail;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('User Data').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          log('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          log('Waiting for know user online status');
        }

        final List status = [];
        if (snapshot.hasData) {
          snapshot.data!.docs.map((DocumentSnapshot document) {
            Map id = document.data() as Map<String, dynamic>;
            if (receiverEmail == document.id) {
              status.add(id);
              id['id'] = document.id;
            }
          }).toList();
        }
        return Text(
          snapshot.hasData ? status[0]['User Current Status'] : '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColor.white,
            fontSize: 10,
          ),
        );
      },
    );
  }
}

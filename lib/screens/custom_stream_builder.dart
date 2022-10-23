import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class CustomSteamBuilder extends StatelessWidget {
  CustomSteamBuilder(
      {Key? key,
      required this.snapshots,
      required this.widget,
      required this.condition})
      : super(key: key);
  Stream<QuerySnapshot> snapshots;
  Widget widget;
  bool condition;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            log('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: AppColor.orange,
              strokeWidth: 2.0,
            ));
          }
          if (snapshot.hasData) {
            final List storedData = [];

            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map id = document.data() as Map<String, dynamic>;
              storedData.add(id);
              id['id'] = document.id;
            }).toList();
            return storedData.isEmpty
                ? Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        scale: 1.3,
                        image: AssetImage('assets/workspace_bg.png'),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < storedData.length; i++) ...[
                        if (condition) ...[
                          widget,
                        ]
                      ],
                    ],
                  );
          }
          return Center(
              child: CircularProgressIndicator(
            color: AppColor.orange,
            strokeWidth: 2.0,
          ));
        });
  }
}

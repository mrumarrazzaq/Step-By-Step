import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/colors.dart';

class AppSteamBuilder extends StatelessWidget {
  AppSteamBuilder(
      {Key? key,
      required this.snapshots,
      required this.emptyDataWidget,
      required this.widget,
      required this.condition})
      : super(key: key);
  Stream<QuerySnapshot> snapshots;
  Widget emptyDataWidget;
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
                ? emptyDataWidget
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

import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/visualization/doughnut_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int offline = 0;
  int online = 0;
  getUserStatusData() async {
    try {
      online = 0;
      offline = 0;
      CollectionReference users =
          FirebaseFirestore.instance.collection('User Data');

      QuerySnapshot querySnapshot = await users.get();

      if (querySnapshot.docs.isNotEmpty) {
        List<DocumentSnapshot> documentList = querySnapshot.docs;
        for (DocumentSnapshot documentSnapshot in documentList) {
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;
          log(documentSnapshot.id);
          if (data!['User Current Status'] == 'Offline') {
            offline++;
          } else {
            online++;
          }
          setState(() {});
        }
      }
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  void userStatusListener() {
    log('Listen For Doughnut Chart User Data Status..............');
    try {
      FirebaseFirestore.instance
          .collection('User Data')
          .snapshots()
          .listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {});
        getUserStatusData();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    userStatusListener();
    getUserStatusData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DoughnutChart(
        title: 'User Status',
        chartData: [
          ChartData(
            label: 'Online Users',
            value: online,
            color: AppChartColor.yellow,
          ),
          ChartData(
            label: 'Offline Users',
            value: offline,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/visualization/dataset.dart';

import 'package:stepbystep/black_box.dart';

class LineChart extends StatefulWidget {
  const LineChart(
      {Key? key,
      required this.workspaceCode,
      required this.userEmail,
      required this.mainFilterValue,
      required this.subFilterValue})
      : super(key: key);
  final String workspaceCode;
  final String userEmail;
  final String mainFilterValue;
  final String subFilterValue;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  int day = DateTime.now().day - 1;
  int week = BlackBox.getWeekNumber() - 1;
  int weekDay = DateTime.now().weekday - 1;
  int month = DateTime.now().month - 1;

  double todo = 0.0;
  double completed = 0.0;
  double expired = 0.0;

  List<double> _dailyAssignedTaskProgressData = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];
  List<double> _dailyCompletedTaskProgressData = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];
  List<double> _dailyExpiredTaskProgressData = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];
  final List<double> _weeklyAssignedTaskProgressData = [0.0, 0.0, 0.0, 0.0];
  final List<double> _weeklyCompletedTaskProgressData = [0.0, 0.0, 0.0, 0.0];
  final List<double> _weeklyExpiredTaskProgressData = [0.0, 0.0, 0.0, 0.0];

  List<double> _monthlyAssignedTaskProgressData = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];
  List<double> _monthlyCompletedTaskProgressData = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];
  List<double> _monthlyExpiredTaskProgressData = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];
  @override
  void initState() {
    dailyLineChartProcess();
    weeklyLineChartProcess();
    monthlyLineChartProcess();
    reportDataListener();
    super.initState();
  }

  dailyLineChartProcess() async {
    for (int i = 0; i < 7; i++) {
      _dailyAssignedTaskProgressData[i] = 0.0;
      _dailyCompletedTaskProgressData[i] = 0.0;
      _dailyExpiredTaskProgressData[i] = 0.0;
    }

    CollectionReference report = FirebaseFirestore.instance
        .collection('Report ${widget.userEmail} ${widget.workspaceCode}');

    QuerySnapshot querySnapshot = await report.get();

    if (querySnapshot.docs.isNotEmpty) {
      List<DocumentSnapshot> documentList = querySnapshot.docs;
      for (DocumentSnapshot documentSnapshot in documentList) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        List<String> list = documentSnapshot.id.split(' ');
        String getYear = list[1];
        String getMonth = list[3];
        String getWeek = list[5];
        String getWeekDay = list[7];
        String getDay = list[9];
        if (DateTime.now().year.toString() == getYear &&
            getWeek == BlackBox.getWeekNumber().toString()) {
          _dailyAssignedTaskProgressData[7 - int.parse(getWeekDay)] +=
              data!['TODO'] + data['DOING'] + data['REVIEW'];
          _dailyCompletedTaskProgressData[7 - int.parse(getWeekDay)] +=
              data['COMPLETED'];
          _dailyExpiredTaskProgressData[7 - int.parse(getWeekDay)] +=
              data['EXPIRED'];
        }
        if (mounted) {
          setState(() {});
        }
        log('-----------------------------------');
      }
    } else {
      log('No documents found');
    }
    log('Daily Assigned Task $_dailyAssignedTaskProgressData');
    log('Daily Completed Task $_dailyCompletedTaskProgressData');
    log('Daily Expired Task $_dailyExpiredTaskProgressData');
    _dailyAssignedTaskProgressData =
        shiftArrayToRight(_dailyAssignedTaskProgressData, weekDay);
    _dailyCompletedTaskProgressData =
        shiftArrayToRight(_dailyCompletedTaskProgressData, weekDay);
    _dailyExpiredTaskProgressData =
        shiftArrayToRight(_dailyExpiredTaskProgressData, weekDay);
    log('Daily Assigned Task $_dailyAssignedTaskProgressData');
    log('Daily Completed Task $_dailyCompletedTaskProgressData');
    log('Daily Expired Task $_dailyExpiredTaskProgressData');
  }

  weeklyLineChartProcess() async {
    for (int i = 0; i < 4; i++) {
      _weeklyAssignedTaskProgressData[i] = 0.0;
      _weeklyCompletedTaskProgressData[i] = 0.0;
      _weeklyExpiredTaskProgressData[i] = 0.0;
    }
    CollectionReference users = FirebaseFirestore.instance
        .collection('Report ${widget.userEmail} ${widget.workspaceCode}');

    QuerySnapshot querySnapshot = await users.get();

    if (querySnapshot.docs.isNotEmpty) {
      List<DocumentSnapshot> documentList = querySnapshot.docs;
      for (DocumentSnapshot documentSnapshot in documentList) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        List<String> list = documentSnapshot.id.split(' ');
        String getYear = list[1];
        String getMonth = list[3];
        String getWeek = list[5];
        String getWeekDay = list[7];
        String getDay = list[9];

        if (DateTime.now().year.toString() == getYear &&
            DateTime.now().month.toString() == getMonth) {
          if (int.parse(getWeek) == 4) {
            _weeklyAssignedTaskProgressData[3] +=
                data!['TODO'] + data['DOING'] + data['REVIEW'];
            _weeklyCompletedTaskProgressData[3] += data['COMPLETED'];
            _weeklyExpiredTaskProgressData[3] += data['EXPIRED'];
          } else {
            _weeklyAssignedTaskProgressData[4 - int.parse(getWeek)] +=
                data!['TODO'] + data['DOING'] + data['REVIEW'];
            _weeklyCompletedTaskProgressData[4 - int.parse(getWeek)] +=
                data['COMPLETED'];
            _weeklyExpiredTaskProgressData[4 - int.parse(getWeek)] +=
                data['EXPIRED'];
          }
        }
        if (mounted) {
          setState(() {});
        }
        log('-----------------------------------');
      }
    } else {
      log('No documents found');
    }

    log('Weekly Assigned Task $_weeklyAssignedTaskProgressData');
    log('Weekly Completed Task $_weeklyCompletedTaskProgressData');
    log('Weekly Expired Task $_weeklyExpiredTaskProgressData');
    // _weeklyAssignedTaskProgressData =
    //     shiftArrayToRight(_weeklyAssignedTaskProgressData, -1);
    // _weeklyCompletedTaskProgressData =
    //     shiftArrayToRight(_weeklyCompletedTaskProgressData, -1);
    // _weeklyExpiredTaskProgressData =
    //     shiftArrayToRight(_weeklyExpiredTaskProgressData, -1);
    // log('Weekly Assigned Task $_weeklyAssignedTaskProgressData');
    // log('Weekly Completed Task $_weeklyCompletedTaskProgressData');
    // log('Weekly Expired Task $_weeklyExpiredTaskProgressData');
  }

  monthlyLineChartProcess() async {
    for (int i = 0; i < 12; i++) {
      _monthlyAssignedTaskProgressData[i] = 0.0;
      _monthlyCompletedTaskProgressData[i] = 0.0;
      _monthlyExpiredTaskProgressData[i] = 0.0;
    }
    CollectionReference users = FirebaseFirestore.instance
        .collection('Report ${widget.userEmail} ${widget.workspaceCode}');

    QuerySnapshot querySnapshot = await users.get();

    if (querySnapshot.docs.isNotEmpty) {
      List<DocumentSnapshot> documentList = querySnapshot.docs;
      for (DocumentSnapshot documentSnapshot in documentList) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        List<String> list = documentSnapshot.id.split(' ');
        String getYear = list[1];
        String getMonth = list[3];
        String getWeek = list[5];
        String getWeekDay = list[7];
        String getDay = list[9];
        if (DateTime.now().year.toString() == getYear) {
          _monthlyAssignedTaskProgressData[12 - int.parse(getMonth)] +=
              data!['TODO'] + data['DOING'] + data['REVIEW'];
          _monthlyCompletedTaskProgressData[12 - int.parse(getMonth)] +=
              data['COMPLETED'];
          _monthlyExpiredTaskProgressData[12 - int.parse(getMonth)] +=
              data['EXPIRED'];
        }
        if (mounted) {
          setState(() {});
        }
        log('-----------------------------------');
      }
    } else {
      log('No documents found');
    }

    log('Monthly Assigned Task $_monthlyAssignedTaskProgressData');
    log('Monthly Completed Task $_monthlyCompletedTaskProgressData');
    log('Monthly Expired Task $_monthlyExpiredTaskProgressData');
    _monthlyAssignedTaskProgressData =
        shiftArrayToRight(_monthlyAssignedTaskProgressData, month);
    _monthlyCompletedTaskProgressData =
        shiftArrayToRight(_monthlyCompletedTaskProgressData, month);
    _monthlyExpiredTaskProgressData =
        shiftArrayToRight(_monthlyExpiredTaskProgressData, month);
    log('Monthly Assigned Task $_monthlyAssignedTaskProgressData');
    log('Monthly Completed Task $_monthlyCompletedTaskProgressData');
    log('Monthly Expired Task $_monthlyExpiredTaskProgressData');
  }

  List<double> shiftArrayToRight(List arr, int numShifts) {
    // Determine the number of shifts required based on array length
    int actualShifts = numShifts % arr.length;
    // Shift the array to the right using sub lists and concatenation
    List<double> shiftedArr = [
      ...arr.getRange(arr.length - actualShifts, arr.length),
      ...arr.getRange(0, arr.length - actualShifts)
    ];

    return shiftedArr;
  }

  void reportDataListener() {
    log('Listen For Line Chart Data..............');
    try {
      FirebaseFirestore.instance
          .collection('Report ${widget.userEmail} ${widget.workspaceCode}')
          .snapshots()
          .listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {});
        dailyLineChartProcess();
        weeklyLineChartProcess();
        monthlyLineChartProcess();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColor.black,
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: AppColor.black,
        header: widget.subFilterValue,
      ),
      enableAxisAnimation: true,
      series: <LineSeries<EmotionData, String>>[
        LineSeries<EmotionData, String>(
            color: widget.subFilterValue == 'Assigned Task'
                ? AppChartColor.blue
                : widget.subFilterValue == 'Completed Task'
                    ? AppChartColor.green
                    : AppChartColor.red,
            enableTooltip: true,
            isVisibleInLegend: true,
            width: 2.5,
            xAxisName: 'Day',
            yAxisName: 'Value',
            markerSettings: MarkerSettings(
              isVisible: true,
              color: widget.subFilterValue == 'Assigned Task'
                  ? AppChartColor.blue
                  : widget.subFilterValue == 'Completed Task'
                      ? AppChartColor.green
                      : AppChartColor.red,
              borderColor: widget.subFilterValue == 'Assigned Task'
                  ? AppChartColor.blue
                  : widget.subFilterValue == 'Completed Task'
                      ? AppChartColor.green
                      : AppChartColor.red,
            ),
            dataSource: <EmotionData>[
              if (widget.mainFilterValue == 'week' &&
                  widget.subFilterValue == 'Assigned Task') ...[
                for (int i = 0; i < 7; i++) ...[
                  EmotionData(
                    text: weekDays[weekDay][i],
                    value: _dailyAssignedTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'month' &&
                  widget.subFilterValue == 'Assigned Task') ...[
                for (int i = 0; i < 4; i++) ...[
                  EmotionData(
                    text: weeksOfMonth[week][i],
                    value: _weeklyAssignedTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'year' &&
                  widget.subFilterValue == 'Assigned Task') ...[
                for (int i = 0; i < 12; i++) ...[
                  EmotionData(
                    text: monthsOfYear[month][i],
                    value: _monthlyAssignedTaskProgressData[i],
                  ),
                ],
              ],
              if (widget.mainFilterValue == 'week' &&
                  widget.subFilterValue == 'Completed Task') ...[
                for (int i = 0; i < 7; i++) ...[
                  EmotionData(
                    text: weekDays[weekDay][i],
                    value: _dailyCompletedTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'month' &&
                  widget.subFilterValue == 'Completed Task') ...[
                for (int i = 0; i < 4; i++) ...[
                  EmotionData(
                    text: weeksOfMonth[week][i],
                    value: _weeklyCompletedTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'year' &&
                  widget.subFilterValue == 'Completed Task') ...[
                for (int i = 0; i < 12; i++) ...[
                  EmotionData(
                    text: monthsOfYear[month][i],
                    value: _monthlyCompletedTaskProgressData[i],
                  ),
                ],
              ],
              if (widget.mainFilterValue == 'week' &&
                  widget.subFilterValue == 'Expired Task') ...[
                for (int i = 0; i < 7; i++) ...[
                  EmotionData(
                    text: weekDays[weekDay][i],
                    value: _dailyExpiredTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'month' &&
                  widget.subFilterValue == 'Expired Task') ...[
                for (int i = 0; i < 4; i++) ...[
                  EmotionData(
                    text: weeksOfMonth[week][i],
                    value: _weeklyExpiredTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'year' &&
                  widget.subFilterValue == 'Expired Task') ...[
                for (int i = 0; i < 12; i++) ...[
                  EmotionData(
                    text: monthsOfYear[month][i],
                    value: _monthlyExpiredTaskProgressData[i],
                  ),
                ],
              ],
            ],
            xValueMapper: (EmotionData data, _) => data.text,
            yValueMapper: (EmotionData data, _) => data.value),
      ],
    );
  }
}

class EmotionData {
  EmotionData({required this.text, required this.value});
  final String text;
  final double value;
}

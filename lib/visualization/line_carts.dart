import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/visualization/chart_processor.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/visualization/dataset.dart';

class LineChart extends StatefulWidget {
  LineChart(
      {Key? key,
      required this.workspaceCode,
      required this.userEmail,
      required this.mainFilterValue,
      required this.subFilterValue})
      : super(key: key);
  String workspaceCode;
  String userEmail;
  String mainFilterValue;
  String subFilterValue;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  int day = DateTime.now().day - 1;
  int week = 0;
  int weekDay = DateTime.now().weekday - 1;
  int month = DateTime.now().month - 1;

  double todo = 0.0;
  double completed = 0.0;
  double expired = 0.0;
  @override
  void initState() {
    // print(widget.userEmail);
    // print(widget.workspaceCode);
    // getData();
    super.initState();
  }

  getData() async {
    CollectionReference users = FirebaseFirestore.instance
        .collection('Report ${widget.userEmail} ${widget.workspaceCode}');

    QuerySnapshot querySnapshot = await users.get();

    if (querySnapshot.docs.isNotEmpty) {
      List<DocumentSnapshot> documentList = querySnapshot.docs;
      for (DocumentSnapshot documentSnapshot in documentList) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        print('Document ID: ${documentSnapshot.id}');

        List<String> list = documentSnapshot.id.split(' ');
        String getYear = list[1];
        String getMonth = list[3];
        String getWeek = list[5];
        String getWeekDay = list[7];
        String getDay = list[9];
        print('$getYear $getMonth $getWeek $getWeekDay $getDay');
        // print(documentSnapshot.id.split(' '));
        if (DateTime.now().year.toString() == getYear &&
            DateTime.now().month.toString() == getMonth) {
          // print('TODO: ${data!['TODO']}');
          todo += data!['TODO'];
          // completed += data['COMPLETED'];
          // expired += data['EXPIRED'];
        }
        setState(() {
          print('---------------');
          print(weekDay);
          print(day);
          calculateDailyTaskProgress('Assigned Task');
          dailyTaskProgressData[weekDay + int.parse(getWeekDay) - 1] = todo;
        });
      }
    } else {
      print('No documents found');
    }

    // await FirebaseFirestore.instance
    //     .collection('Report zain@gmail.com umar@gmail.com Software')
    //     .doc()
    //     .get()
    //     .then((ds) {
    //   print(ds['TODO']);
    // });
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
                    value: dailyTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'month' &&
                  widget.subFilterValue == 'Assigned Task') ...[
                for (int i = 0; i < 4; i++) ...[
                  EmotionData(
                    text: weeksOfMonth[week][i],
                    value: weeklyTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'year' &&
                  widget.subFilterValue == 'Assigned Task') ...[
                for (int i = 0; i < 12; i++) ...[
                  EmotionData(
                    text: monthsOfYear[month][i],
                    value: monthlyTaskProgressData[i],
                  ),
                ],
              ],
              if (widget.mainFilterValue == 'week' &&
                  widget.subFilterValue == 'Completed Task') ...[
                for (int i = 0; i < 7; i++) ...[
                  EmotionData(
                    text: weekDays[weekDay][i],
                    value: dailyTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'month' &&
                  widget.subFilterValue == 'Completed Task') ...[
                for (int i = 0; i < 4; i++) ...[
                  EmotionData(
                    text: weeksOfMonth[week][i],
                    value: weeklyTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'year' &&
                  widget.subFilterValue == 'Completed Task') ...[
                for (int i = 0; i < 12; i++) ...[
                  EmotionData(
                    text: monthsOfYear[month][i],
                    value: monthlyTaskProgressData[i],
                  ),
                ],
              ],
              if (widget.mainFilterValue == 'week' &&
                  widget.subFilterValue == 'Expired Task') ...[
                for (int i = 0; i < 7; i++) ...[
                  EmotionData(
                    text: weekDays[weekDay][i],
                    value: dailyTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'month' &&
                  widget.subFilterValue == 'Expired Task') ...[
                for (int i = 0; i < 4; i++) ...[
                  EmotionData(
                    text: weeksOfMonth[week][i],
                    value: weeklyTaskProgressData[i],
                  ),
                ],
              ] else if (widget.mainFilterValue == 'year' &&
                  widget.subFilterValue == 'Expired Task') ...[
                for (int i = 0; i < 12; i++) ...[
                  EmotionData(
                    text: monthsOfYear[month][i],
                    value: monthlyTaskProgressData[i],
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

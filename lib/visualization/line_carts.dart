import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/visualization/dataset.dart';

class LineChart extends StatefulWidget {
  LineChart(
      {Key? key, required this.mainFilterValue, required this.subFilterValue})
      : super(key: key);
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

  @override
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

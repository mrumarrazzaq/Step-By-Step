import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:stepbystep/colors.dart';

class DoughnutChart extends StatelessWidget {
  final List<ChartData> chartData;
  final String title;

  const DoughnutChart({
    Key? key,
    required this.chartData,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColor.black,
                  fontFamily: 'SegoeUIBold',
                ),
              ),
            ),
            Container(
              height: size.height * 0.45,
              alignment: Alignment.center,
              child: SfCircularChart(
                annotations: const [],
                series: [
                  DoughnutSeries<ChartData, String>(
                    dataSource: chartData,
                    dataLabelMapper: (ChartData data, _) =>
                        data.value.toString(),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(fontSize: 12, color: AppColor.black),
                    ),
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.label,
                    yValueMapper: (ChartData data, _) => data.value,
                    radius: "${size.height * 0.16}",
                  ),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          direction: Axis.horizontal,
          children: chartData.map(
            (e) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      color: e.color,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: Text(e.label),
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}

class ChartData {
  ChartData({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;
}

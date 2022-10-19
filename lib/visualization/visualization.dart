import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'chart_processor.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/visualization/doughnut_chart.dart';
import 'package:stepbystep/visualization/line_carts.dart';

class Visualization extends StatefulWidget {
  const Visualization({Key? key}) : super(key: key);

  @override
  State<Visualization> createState() => _VisualizationState();
}

class _VisualizationState extends State<Visualization> {
  List<Color> mainFilterColorList = [
    AppColor.orange,
    AppColor.black,
    AppColor.black
  ];
  List<Color> subFilterColorList = [
    AppColor.orange,
    AppColor.black,
    AppColor.black
  ];
  List<String> mainFilter = ['week', 'month', 'year'];
  List<String> subFilter = ['Assigned Task', 'Completed Task', 'Expired Task'];
  String mainFilterValue = 'week';
  String subFilterValue = 'Assigned Task';

  @override
  void initState() {
    for (int i = 0; i < 3; i++) {
      calculateDailyTaskProgress(subFilter[i]);
      calculateWeeklyTaskProgress(subFilter[i]);
      calculateMonthlyTaskProgress(subFilter[i]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'WorkSpace Name',
            style: TextStyle(
                color: AppColor.darkGrey,
                fontFamily: 'SegoeUIBold',
                fontSize: 25,
                fontWeight: FontWeight.w900),
          ),
          bottom: PreferredSize(
            preferredSize: const Size(60.0, 100.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  color: AppColor.black,
                  child: Center(
                    child: Text(
                      'Person Name',
                      style: GoogleFonts.kanit(
                        color: AppColor.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                TabBar(
                  // indicatorColor: AppColor.black,
                  labelColor: AppColor.orange,
                  unselectedLabelColor: AppColor.black,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 5.0, color: AppColor.orange),
                    insets: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  tabs: const [
                    Tab(text: 'Doughnut Chart'),
                    Tab(text: 'Line Chart'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: DoughnutChart(
                title: 'Task Chart',
                chartData: [
                  ChartData(
                      label: 'Assigned Task',
                      value: 13,
                      color: AppChartColor.blue),
                  ChartData(
                      label: 'Doing Task',
                      value: 2,
                      color: AppChartColor.yellow),
                  ChartData(
                      label: 'Review Task',
                      value: 3,
                      color: AppChartColor.grey),
                  ChartData(
                      label: 'Completed Task',
                      value: 5,
                      color: AppChartColor.green),
                  ChartData(
                      label: 'Expired Task',
                      value: 3,
                      color: AppChartColor.red),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            mainFilterValue = mainFilter[0];
                            mainFilterColorList[0] = AppColor.orange;
                            mainFilterColorList[1] = AppColor.black;
                            mainFilterColorList[2] = AppColor.black;
                            calculateDailyTaskProgress(subFilterValue);
                          });
                        },
                        child: Text(
                          'Daily',
                          style: TextStyle(
                            color: mainFilterColorList[0],
                            fontSize: 20,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            mainFilterValue = mainFilter[1];
                            mainFilterColorList[0] = AppColor.black;
                            mainFilterColorList[1] = AppColor.orange;
                            mainFilterColorList[2] = AppColor.black;
                            calculateWeeklyTaskProgress(subFilterValue);
                          });
                        },
                        child: Text(
                          'Weekly',
                          style: TextStyle(
                            color: mainFilterColorList[1],
                            fontSize: 20,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            mainFilterValue = mainFilter[2];
                            mainFilterColorList[0] = AppColor.black;
                            mainFilterColorList[1] = AppColor.black;
                            mainFilterColorList[2] = AppColor.orange;
                            calculateMonthlyTaskProgress(subFilterValue);
                          });
                        },
                        child: Text(
                          'Monthly',
                          style: TextStyle(
                            color: mainFilterColorList[2],
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            subFilterValue = subFilter[0];
                            subFilterColorList[0] = AppColor.orange;
                            subFilterColorList[1] = AppColor.black;
                            subFilterColorList[2] = AppColor.black;
                            calculateDailyTaskProgress(subFilter[0]);
                            calculateWeeklyTaskProgress(subFilter[0]);
                            calculateMonthlyTaskProgress(subFilter[0]);
                          });
                        },
                        child: Text(
                          'Assigned Task',
                          style: TextStyle(
                            color: subFilterColorList[0],
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            subFilterValue = subFilter[1];

                            subFilterColorList[0] = AppColor.black;
                            subFilterColorList[1] = AppColor.orange;
                            subFilterColorList[2] = AppColor.black;

                            calculateDailyTaskProgress(subFilter[1]);
                            calculateWeeklyTaskProgress(subFilter[1]);
                            calculateMonthlyTaskProgress(subFilter[1]);
                          });
                        },
                        child: Text(
                          'Completed Task',
                          style: TextStyle(
                            color: subFilterColorList[1],
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            subFilterValue = subFilter[2];

                            subFilterColorList[0] = AppColor.black;
                            subFilterColorList[1] = AppColor.black;
                            subFilterColorList[2] = AppColor.orange;

                            calculateDailyTaskProgress(subFilter[2]);
                            calculateWeeklyTaskProgress(subFilter[2]);
                            calculateMonthlyTaskProgress(subFilter[2]);
                          });
                        },
                        child: Text(
                          'Expired Task',
                          style: TextStyle(
                            color: subFilterColorList[2],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  LineChart(
                    mainFilterValue: mainFilterValue,
                    subFilterValue: subFilterValue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

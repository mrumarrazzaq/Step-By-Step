import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chart_processor.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/visualization/line_carts.dart';
import 'package:stepbystep/visualization/doughnut_chart.dart';

class Visualization extends StatefulWidget {
  const Visualization({
    Key? key,
    required this.workspaceCode,
    required this.workspaceName,
    required this.userEmail,
    required this.userName,
  }) : super(key: key);
  final String workspaceCode;
  final String workspaceName;
  final String userEmail;
  final String userName;
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
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  int selectedMonth = DateTime.now().month;
  double todo = 0.0;
  double doing = 0.0;
  double review = 0.0;
  double completed = 0.0;
  double expired = 0.0;

  @override
  void initState() {
    reportDataListener();
    processDoughnutChartData();
    super.initState();
  }

  processDoughnutChartData() async {
    log('Report Data is Fetching ${widget.userEmail}');
    log('Selected Month : $selectedMonth');
    todo = 0;
    doing = 0;
    review = 0;
    completed = 0;
    expired = 0;
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
            DateTime.now().month.toString() == selectedMonth.toString()) {
          todo += data!['TODO'];
          doing += data['DOING'];
          review += data['REVIEW'];
          completed += data['COMPLETED'];
          expired += data['EXPIRED'];
        }
        setState(() {});
        log('-----------------------------------');
      }
    } else {
      log('No documents found');
    }
    log('$todo $doing $review $completed $expired');
  }

  void reportDataListener() {
    log('Listen For Doughnut Chart Data..............');
    try {
      FirebaseFirestore.instance
          .collection('Report ${widget.userEmail} ${widget.workspaceCode}')
          .snapshots()
          .listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {});
        processDoughnutChartData();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            widget.workspaceName,
            style: TextStyle(
              color: AppColor.darkGrey,
              fontFamily: 'SegoeUIBold',
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size(60.0, 100.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    color: AppColor.black,
                    child: Center(
                      child: Text(
                        widget.userName,
                        style: GoogleFonts.kanit(
                          color: AppColor.white,
                          fontSize: 22,
                        ),
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
              child: Column(
                children: [
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        'Showing data of',
                        style: GoogleFonts.aBeeZee(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                          'Year ${DateTime.now().year}, Month ${months[selectedMonth - 1]}'),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            isScrollControlled: true,
                            isDismissible: true,
                            elevation: 1,
                            builder: (BuildContext context) {
                              return DraggableScrollableSheet(
                                  // initialChildSize: 0.83,
                                  // maxChildSize: 0.83,
                                  // minChildSize: 0.83,
                                  expand: true,
                                  builder: (context, scrollController) {
                                    return Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 5,
                                              width: 100,
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              decoration: BoxDecoration(
                                                color: AppColor.darkGrey,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            const Card(
                                              elevation: 0.2,
                                              child: ListTile(
                                                title: Text(
                                                  'Select Month',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: months.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    onTap: () {
                                                      selectedMonth = index + 1;
                                                      setState(() {});
                                                      processDoughnutChartData();
                                                      Navigator.pop(context);
                                                    },
                                                    dense: true,
                                                    focusColor: Colors.grey,
                                                    selected:
                                                        selectedMonth - 1 ==
                                                                index
                                                            ? true
                                                            : false,
                                                    selectedColor:
                                                        AppColor.lightOrange,
                                                    title: Text(
                                                      months[index].toString(),
                                                      style:
                                                          GoogleFonts.aBeeZee(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            selectedMonth - 1 ==
                                                                    index
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            });
                      },
                    ),
                  ),
                  DoughnutChart(
                    title: 'Tasks',
                    chartData: [
                      ChartData(
                        label: 'Assigned Task',
                        value: todo.toInt(),
                        color: AppChartColor.blue,
                      ),
                      ChartData(
                          label: 'Doing Task',
                          value: doing.toInt(),
                          color: AppChartColor.yellow),
                      ChartData(
                          label: 'Review Task',
                          value: review.toInt(),
                          color: AppChartColor.grey),
                      ChartData(
                          label: 'Completed Task',
                          value: completed.toInt(),
                          color: AppChartColor.green),
                      ChartData(
                          label: 'Expired Task',
                          value: expired.toInt(),
                          color: AppChartColor.red),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  //MAIN Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //DAILY
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
                      //WEEKLY
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
                      //MONTHLY
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
                  //SUB Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Assigned Task
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
                      //Completed Task
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
                      //Expired Task
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
                    workspaceCode: widget.workspaceCode,
                    userEmail: widget.userEmail,
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

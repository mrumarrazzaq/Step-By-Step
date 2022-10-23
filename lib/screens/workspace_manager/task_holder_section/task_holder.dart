import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stepbystep/apis/firebase_api.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/config.dart';
import 'package:stepbystep/screens/workspace_manager/task_view.dart';
import 'package:stepbystep/widgets/app_elevated_button.dart';

class TaskHolder extends StatefulWidget {
  String docId;
  String workspaceCode;
  String workspaceName;
  String workspaceOwnerName;
  String workspaceOwnerEmail;
  TaskHolder({
    Key? key,
    required this.workspaceCode,
    required this.docId,
    required this.workspaceName,
    required this.workspaceOwnerName,
    required this.workspaceOwnerEmail,
  }) : super(key: key);
  @override
  _TaskHolderState createState() => _TaskHolderState();
}

class _TaskHolderState extends State<TaskHolder>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Stream<QuerySnapshot> _assignTasksData;
  DateTime dateTime = DateTime.now();

  String _date = '';
  bool isDateTimeChecked = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  int currentIndex = 0;
  late TabController tabController;

  final List<Tab> taskTabs = const [
    Tab(
      child: Text('TODO'),
    ),
    Tab(
      child: Text('Doing'),
    ),
    Tab(
      child: Text('Review'),
    ),
    Tab(
      child: Text('Completed'),
    ),
    Tab(
      child: Text('Expired'),
    ),
  ];
  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: taskTabs.length);
    // _assignTasksData = FirebaseFirestore.instance
    //     .collection('$currentUserEmail ${widget.workspaceCode}')
    //     .orderBy('Created At', descending: true)
    //     .snapshots();
    // _date = '${formatDate(dateTime, [
    //       dd,
    //       '-',
    //       mm,
    //       '-',
    //       yyyy
    //     ])} ${formatDate(dateTime, [hh, ':', nn, ' ', am])}';
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: currentIndex,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size(30, 180),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.orange,
                      foregroundImage: const AssetImage('assets/dummy.jpg'),
                      radius: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Text(
                        widget.workspaceOwnerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                    ),
                    Text(
                      widget.workspaceOwnerEmail,
                      style: TextStyle(color: AppColor.grey, fontSize: 18),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  color: AppColor.black,
                  child: TabBar(
                    controller: tabController,
                    onTap: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    indicatorColor: Colors.transparent,
                    unselectedLabelColor: AppColor.white,
                    labelColor: AppColor.orange,
                    tabs: taskTabs,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            // TaskView(
            //   snapshot: _assignTasksData,
            //   color: AppChartColor.blue,
            //   function: () {},
            // ),
            // SingleChildScrollView(
            //   child: StreamBuilder<QuerySnapshot>(
            //       stream: _assignTasksData,
            //       builder: (BuildContext context,
            //           AsyncSnapshot<QuerySnapshot> snapshot) {
            //         if (snapshot.hasError) {
            //           log('Something went wrong');
            //         }
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return Center(
            //               child: CircularProgressIndicator(
            //             color: AppColor.orange,
            //             strokeWidth: 2.0,
            //           ));
            //         }
            //         if (snapshot.hasData) {
            //           final List storedTaskData = [];
            //
            //           snapshot.data!.docs.map((DocumentSnapshot document) {
            //             Map id = document.data() as Map<String, dynamic>;
            //             storedTaskData.add(id);
            //             id['id'] = document.id;
            //           }).toList();
            //           return Column(
            //             children: [
            //               for (int i = 0; i < storedTaskData.length; i++) ...[
            //                 TaskTile(
            //                   title: storedTaskData[i]['Task Title'],
            //                   date: storedTaskData[i]['Due Date'],
            //                   email: storedTaskData[i]['Assigned By'],
            //                   color: AppChartColor.blue,
            //                   function: () {
            //                     setState(() {
            //                       if (tabController.index < 2) {
            //                         tabController
            //                             .animateTo((tabController.index + 1));
            //                       }
            //                     });
            //                   },
            //                 ),
            //               ],
            //             ],
            //           );
            //         }
            //         return Center(
            //             child: CircularProgressIndicator(
            //           color: AppColor.orange,
            //           strokeWidth: 2.0,
            //         ));
            //       }),
            // ),
            Container(),
            Container(
                color: Colors.green, child: Text(currentIndex.toString())),
            Container(color: Colors.red, child: Text(currentIndex.toString())),
            Container(
                color: Colors.yellow, child: Text(currentIndex.toString())),
            Container(
                color: Colors.orange, child: Text(currentIndex.toString())),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  String title;
  String email;
  String date;
  Color color;
  Function() function;
  TaskTile({
    Key? key,
    required this.title,
    required this.email,
    required this.date,
    required this.color,
    required this.function,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: AppColor.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColor.grey,
              ),
            ),
            Text(
              date,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColor.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: function,
          icon: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}

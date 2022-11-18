// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:date_format/date_format.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:provider/provider.dart';
import 'package:stepbystep/colors.dart';
import 'package:stepbystep/providers/date_comparison.dart';
import 'package:stepbystep/providers/taskCollection.dart';
import 'package:stepbystep/screens/self_task_manager/add_task.dart';
import 'package:stepbystep/screens/self_task_manager/update_task.dart';
import 'package:stepbystep/sql_database/sql_helper.dart';

class SelfSpaceHome extends StatefulWidget {
  const SelfSpaceHome({Key? key}) : super(key: key);

  @override
  State<SelfSpaceHome> createState() => _SelfSpaceHomeState();
}

class _SelfSpaceHomeState extends State<SelfSpaceHome> {
  bool _isLoading = false;
  IconData taskStatusIcon = Icons.check_box_outline_blank_rounded;
  String dateFilter = '';
  DateTime initialSelectedDate = DateTime.now();
  @override
  void initState() {
    context.read<TaskCollection>().refreshData();
    super.initState();
  }

  void _deleteTask(int id) async {
    await SQLHelper.deleteTask(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task Deleted Successfully'),
    ));
    context.read<TaskCollection>().refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: context.watch<TaskCollection>().getTask.isEmpty
            ? const BoxDecoration(
                image: DecorationImage(
                  scale: 1.3,
                  image: AssetImage('assets/selfspace_bg.png'),
                ),
              )
            : const BoxDecoration(),
        child: Center(
          child: Column(
            children: [
              ListTile(
                title: const Text('See Previous Date Task'),
                textColor: AppColor.black,
                trailing: IconButton(
                  onPressed: () {
                    _pickDate();
                  },
                  icon: Icon(Icons.date_range_sharp, color: AppColor.black),
                ),
              ),
              DatePicker(
                initialSelectedDate,
                initialSelectedDate: initialSelectedDate,
                selectionColor: Colors.black,
                selectedTextColor: Colors.white,
                width: 60,
                onDateChange: (dateTime) {
                  setState(() {
                    dateFilter = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                    log(dateFilter);
                  });
                },
              ),
              // FlutterDatePickerTimeline(
              //   initialSelectedDate: DateTime.now(),
              //   startDate: DateTime.now(),
              //   endDate: DateTime(3000, 01, 30),
              //   calendarMode: CalendarMode.gregorian,
              //   onSelectedDateChange: (dateTime) {
              //     dateFilter = formatDate(dateTime!, [yyyy, '-', mm, '-', dd]);
              //     context.read<DateCompare>().setDateFilter(dateFilter);
              //     log(dateFilter);
              //   },
              // ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Color(0xffF3520C),
                        ),
                      )
                    : context.watch<TaskCollection>().getTask.isEmpty
                        ? Container()
                        : ListView.builder(
                            itemCount:
                                context.watch<TaskCollection>().getTask.length,
                            itemBuilder: (context, index) {
                              final task = Provider.of<TaskCollection>(context,
                                      listen: false)
                                  .getTask[index];

                              return SwipeActionCell(
                                key: ObjectKey(task['id']),
                                trailingActions: [
                                  SwipeAction(
                                    title: "Delete",
                                    style: TextStyle(
                                        fontSize: 12, color: AppColor.white),
                                    color: Colors.red,
                                    icon: Icon(Icons.delete,
                                        color: AppColor.white),
                                    onTap: (CompletionHandler handler) async {
                                      openDeleteDialog(task['id']);
                                      setState(() {});
                                    },
                                  ),
                                ],
                                child:
                                    // task['dateFilter'] == dateFilter ?
                                    TaskTile(
                                  task: task,
                                  dateFilter: dateFilter,
                                ),
                                // : Container(),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Task(),
            ),
          );
        },
        tooltip: 'Add',
        child: Image.asset(
          'assets/to-do-list.png',
          height: 30,
          color: AppColor.white,
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 01, 01),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.orange,
              onPrimary: AppColor.white,
              onSurface: AppColor.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: AppColor.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickDate != null) {
      setState(() {
        initialSelectedDate = pickDate;
        log(initialSelectedDate.toString());
        //dateFilter = formatDate(pickDate, [dd, ' ', MM, ' ', yyyy]);
      });
    }
  }

  openDeleteDialog(int id) => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            var width = MediaQuery.of(context).size.width;
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              title: const Center(child: Text('Delete Task')),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: width,
                  height: 40.0,
                  child: Center(
                      child: Column(
                    children: const [
                      Text('Do you want to delete task'),
                      Text('Deleted task cannot be recovered',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                              color: Colors.red)),
                    ],
                  )),
                ),
              ),
              actions: [
                //CANCEL Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                //CREATE Button
                TextButton(
                  onPressed: () async {
                    _deleteTask(id);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class TaskTile extends StatelessWidget {
  final task;
  String dateFilter;
  TaskTile({Key? key, this.task, required this.dateFilter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
        //context.watch<DateCompare>().dateFilter
        dateFilter == task['dateFilter']
            ? ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateTask(
                        id: task['id'],
                        title: task['taskTitle'],
                        description: task['taskDescription'],
                        taskStatus: task['taskStatus'],
                      ),
                    ),
                  );
                },
                leading: IconButton(
                  onPressed: () {
                    String taskStatus = task['taskStatus'];

                    if (taskStatus == 'TODO') {
                      taskStatus = 'COMPLETED';
                    } else {
                      taskStatus = 'TODO';
                    }
                    _updateTaskStatus(
                        id: task['id'],
                        title: task['taskTitle'],
                        description: task['taskDescription'],
                        taskDate: task['taskDate'],
                        taskTime: task['taskTime'],
                        dateFilter: task['dateFilter'],
                        notification: task['notification'],
                        taskStatus: taskStatus,
                        context: context);
                  },
                  splashRadius: 25,
                  color: task['taskStatus'] == 'TODO'
                      ? AppColor.black
                      : AppColor.grey,
                  icon: Icon(task['taskStatus'] == 'TODO'
                      ? Icons.check_box_outline_blank_rounded
                      : Icons.check_box_outlined),
                ),
                title: Text(
                  task['taskTitle'],
                  style: TextStyle(
                      color: task['taskStatus'] == 'TODO'
                          ? AppColor.black
                          : AppColor.grey,
                      decoration: task['taskStatus'] == 'TODO'
                          ? TextDecoration.none
                          : TextDecoration.lineThrough),
                ),
                subtitle: Text(
                  task['taskTime'], //taskDescription
                  style: TextStyle(
                      decoration: task['taskStatus'] == 'TODO'
                          ? TextDecoration.none
                          : TextDecoration.lineThrough),
                ),
              )
            : Container();
  }

  Future<void> _updateTaskStatus(
      {required int id,
      required String title,
      required String description,
      required String taskDate,
      required String taskTime,
      required String dateFilter,
      required String notification,
      required String taskStatus,
      required BuildContext context}) async {
    await SQLHelper.updateTask(
      id: id,
      title: title,
      description: description,
      taskDate: taskDate,
      taskTime: taskTime,
      dateFilter: dateFilter,
      notification: notification,
      taskStatus: taskStatus,
    );
    context.read<TaskCollection>().refreshData();
  }
}

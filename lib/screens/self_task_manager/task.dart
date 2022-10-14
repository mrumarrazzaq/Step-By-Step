import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:date_format/date_format.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:stepbystep/apis/notification_api.dart';

import 'package:stepbystep/colors.dart';
import 'package:stepbystep/providers/taskCollection.dart';
import 'package:stepbystep/sql_database/sql_helper.dart';
import 'package:stepbystep/widgets/app_input_field.dart';

class Task extends StatefulWidget {
  const Task({Key? key}) : super(key: key);

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();

  final DateTime _selectedDateTime = DateTime.now();

  String _showTime = 'Select Time';
  String _showDate = 'Select Date';
  String dateTimeString = '';
  String _date = '';
  String _time = '';

  @override
  void initState() {
    _showDate = formatDate(_selectedDateTime, [dd, ' ', MM, ' ', yyyy]);
    _showTime = formatDate(_selectedDateTime, [hh, ': ', nn, ' ', am]);

    _date = formatDate(_selectedDateTime, [yyyy, '-', mm, '-', dd]);
    _time = '${_selectedDateTime.hour}:${_selectedDateTime.minute}';
    dateTimeString = '$_date $_time';
    print('init : $dateTimeString');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        actions: [
          Image.asset('assets/design.png'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            AppInputField(
              textInputType: TextInputType.text,
              hint: 'I want to ...',
              label: 'What do you want ?',
              controller: _taskTitleController,
            ),
            AppInputField(
              textInputType: TextInputType.text,
              hint: 'Enter Task Description [Optional]',
              label: 'Task Description',
              controller: _taskDescriptionController,
              maxLines: 3,
            ),
            ListTile(
              onTap: () {
                _pickDate();
              },
              leading: const Icon(Icons.calendar_month),
              title: Text(_showDate),
            ),
            ListTile(
              onTap: () {
                _pickTime();
              },
              leading: const Icon(Icons.access_time),
              title: Text(_showTime),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColor.black),
              ),
              onPressed: () async {
                if (_taskTitleController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Enter Task Title",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  dateTimeString = '$_date $_time';

                  await SQLHelper.createTask(
                    title: _taskTitleController.text,
                    description: _taskDescriptionController.text.isEmpty
                        ? ''
                        : _taskDescriptionController.text,
                    taskDate: _showDate,
                    taskTime: _showTime,
                    dateFilter: _date,
                    notification: dateTimeString,
                    taskStatus: 'TODO',
                  );
                  try {
                    NotificationAPI.showScheduledNotification(
                      id: _selectedDateTime.minute + _selectedDateTime.second,
                      title: 'Don\'t Forget  to complete task',
                      body: _taskTitleController.text,
                      payload: _taskDescriptionController.text,
                      scheduledDate: DateTime.parse(dateTimeString).add(
                        const Duration(microseconds: 10),
                      ),
                    );
                  } catch (e) {
                    log(e.toString());
                  }
                  Fluttertoast.showToast(
                    msg: "Task create successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: AppColor.orange,
                  );
                  context.read<TaskCollection>().refreshData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
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
        _date = formatDate(pickDate, [yyyy, '-', mm, '-', dd]);
        _showDate = formatDate(pickDate, [dd, ' ', MM, ' ', yyyy]);
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: TimeOfDay(
        hour: _selectedDateTime.hour,
        minute: _selectedDateTime.minute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.orange, // header background color
              onPrimary: AppColor.white, // header text color
              onSurface: AppColor.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: AppColor.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickTime != null) {
      setState(() {
        _showTime = pickTime.format(context);
        _time = '${pickTime.hour}:${pickTime.minute}';
      });
    }
  }
}

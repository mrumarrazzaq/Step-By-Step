import 'package:flutter/material.dart';
import 'package:stepbystep/sql_database/sql_helper.dart';

class TaskCollection extends ChangeNotifier {
  List<Map<String, dynamic>> _taskCollection = [];

  List<Map<String, dynamic>> get getTask => _taskCollection;

  void refreshData() async {
    final data = await SQLHelper.getTasks();
    _taskCollection = data;
    notifyListeners();
  }
}

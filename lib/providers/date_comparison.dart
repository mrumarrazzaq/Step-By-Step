import 'package:flutter/material.dart';
import 'package:stepbystep/sql_database/sql_helper.dart';

class DateCompare extends ChangeNotifier {
  String dateFilter = '';
  String get getDateFilter => dateFilter;
  void setDateFilter(String date) async {
    dateFilter = date;
    notifyListeners();
  }
}

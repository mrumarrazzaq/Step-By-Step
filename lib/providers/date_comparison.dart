import 'package:flutter/material.dart';

class DateCompare extends ChangeNotifier {
  String dateFilter = '';
  String get getDateFilter => dateFilter;
  void setDateFilter(String date) async {
    dateFilter = date;
    notifyListeners();
  }
}

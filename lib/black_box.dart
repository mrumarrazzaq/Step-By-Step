import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stepbystep/apis/collection_history.dart';

class BlackBox {
  static void createReportTemplate(
      {required String workspaceCode,
      required String collectionName,
      required String taskDocId}) async {
    int week = getWeekNumber();
    final json = {
      'TODO': 1,
      'DOING': 0,
      'REVIEW': 0,
      'COMPLETED': 0,
      'EXPIRED': 0,
    };
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc('Year ${DateTime.now().year.toString()}')
        .collection('Months')
        .doc('Month ${DateTime.now().month.toString()}')
        .collection('Weeks')
        .doc('Week $week')
        .collection('Day ${DateTime.now().day.toString()}')
        .doc(taskDocId)
        .set(json);
    await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: workspaceCode,
        collectionName: collectionName,
        docName: 'AUTO');
  }

  static void createReport(
      {required String workspaceCode,
      required String collectionName,
      required String taskDocId}) async {
    int week = getWeekNumber();
    final json = {
      'Task Id': taskDocId,
      'TODO': 1,
      'DOING': 0,
      'REVIEW': 0,
      'COMPLETED': 0,
      'EXPIRED': 0,
    };
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(
            'Year ${DateTime.now().year.toString()} Month ${DateTime.now().month.toString()} Week $week WeekDay ${DateTime.now().weekday.toString()} Day ${DateTime.now().day.toString()} $taskDocId')
        .set(json);
    await CollectionDocHistory.saveCollectionHistory(
        workspaceCode: workspaceCode,
        collectionName: collectionName,
        docName: 'AUTO');
  }

  static int getWeekNumber() {
    DateTime date = DateTime.now();
    int month = date.month;
    int year = date.year;
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int daysOffset = (DateTime.monday - firstDayOfMonth.weekday) % 7;
    DateTime firstMondayOfMonth =
        firstDayOfMonth.add(Duration(days: daysOffset));
    int weekNumber =
        ((date.difference(firstMondayOfMonth).inDays) / 7).floor() + 1;
    log('Week number: $weekNumber');

    return weekNumber;
  }
}

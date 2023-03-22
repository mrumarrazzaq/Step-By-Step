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
    String date = DateTime.now().toString();

    // This will generate the time and date for first day of month
    String firstDay = '${date.substring(0, 8)}01${date.substring(10)}';

    // week day for the first day of the month
    int weekDay = DateTime.parse(firstDay).weekday;

    DateTime testDate = DateTime.now();

    int weekOfMonth;

//  If your calender starts from Monday
    weekDay--;
    weekOfMonth = ((testDate.day + weekDay) / 7).ceil();
    print('Week of the month: $weekOfMonth');
    weekDay++;

    // If your calender starts from sunday
    if (weekDay == 7) {
      weekDay = 0;
    }
    weekOfMonth = ((testDate.day + weekDay) / 7).ceil();
    return weekOfMonth;
  }
}

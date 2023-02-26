import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stepbystep/visualization/dataset.dart';

class Calc extends StatefulWidget {
  const Calc({Key? key}) : super(key: key);

  @override
  State<Calc> createState() => _CalcState();
}

class _CalcState extends State<Calc> {
  num todo = 0;

  void listenForData(String year, String month, String week) {
    print('listenForData..............');
    FirebaseFirestore.instance
        .collection('Workspace Code Report')
        .doc('Year $year')
        .collection('Months')
        .doc('Month $month')
        .collection('Weeks')
        .doc('Week $week')
        .collection('Days')
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        todo += change.doc.get('TODO');
        print('TODO: ${change.doc.get('TODO')}');
        // print('DOING: ${change.doc.get('DOING')}');
        // print('REVIEW: ${change.doc.get('REVIEW')}');
        // print('COMPLETED: ${change.doc.get('COMPLETED')}');
        // print('EXPIRED: ${change.doc.get('EXPIRED')}');
      });
    });
  }

  void getValue() {
    print('______________');
    print(todo);
  }

  int getWeekNumber() {
    String date = DateTime.now().toString();

    // This will generate the time and date for first day of month
    String firstDay = date.substring(0, 8) + '01' + date.substring(10);

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

  @override
  void initState() {
    listenForData('2023', '2', '4');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CALC'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextButton(
                onPressed: () async {
                  print('Data is saving.........');
                  int week = getWeekNumber();
                  final json = {
                    'TODO': 0,
                    'DOING': 0,
                    'REVIEW': 0,
                    'COMPLETED': 0,
                    'EXPIRED': 0,
                  };
                  await FirebaseFirestore.instance
                      .collection('Workspace Code Report')
                      .doc('Year ${DateTime.now().year.toString()}')
                      .collection('Months')
                      .doc('Month ${DateTime.now().month.toString()}')
                      .collection('Weeks')
                      .doc('Week $week')
                      .collection('Days')
                      .doc(DateTime.now().toString())
                      .set(json);

                  await FirebaseFirestore.instance
                      .collection('Report Report')
                      .doc(
                          'idno ${DateTime.now().year.toString()} ${DateTime.now().month.toString()} $week ${DateTime.now().day.toString()}')
                      .set(json);
                },
                child: Text('Press to save data')),
            TextButton(
                onPressed: () {
                  listenForData('2023', '2', '4');
                },
                child: Text('Press for function call')),
            TextButton(
                onPressed: () {
                  getValue();
                },
                child: Text('Press to get value')),
            TextButton(
                onPressed: () {
                  getWeekNumber();
                },
                child: Text('Press')),
          ],
        ),
      ),
    );
  }
}

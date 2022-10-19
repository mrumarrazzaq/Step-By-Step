import 'package:flutter/material.dart';

const List<List<String>> weekDays = [
  ['So', 'Sa', 'Fr', 'Th', 'We', 'Tu', 'Mo'],
  ['Mo', 'So', 'Sa', 'Fr', 'Th', 'We', 'Tu'],
  ['Tu', 'Mo', 'So', 'Sa', 'Fr', 'Th', 'We'],
  ['We', 'Tu', 'Mo', 'So', 'Sa', 'Fr', 'Th'],
  ['Th', 'We', 'Tu', 'Mo', 'So', 'Sa', 'Fr'],
  ['Fr', 'Th', 'We', 'Tu', 'Mo', 'So', 'Sa'],
  ['Sa', 'Fr', 'Th', 'We', 'Tu', 'Mo', 'So']
];

const List<List<String>> weeksOfMonth = [
  ['Week 4', 'Week 3', 'Week 2', 'Week 1'],
  ['Week 1', 'Week 4', 'Week 3', 'Week 2'],
  ['Week 2', 'Week 1', 'Week 4', 'Week 3'],
  ['Week 3', 'Week 2', 'Week 1', 'Week 4']
];
const List<List<String>> monthsOfYear = [
  [
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan'
  ],
  [
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb'
  ],
  [
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar'
  ],
  [
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr'
  ],
  [
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai'
  ],
  [
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun'
  ],
  [
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul'
  ],
  [
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep',
    'Aug'
  ],
  [
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct',
    'Sep'
  ],
  [
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov',
    'Oct'
  ],
  [
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dec',
    'Nov'
  ],
  [
    'Nov',
    'Oct',
    'Sep',
    'Aug',
    'Jul',
    'Jun',
    'Mai',
    'Apr',
    'Mar',
    'Feb',
    'Jan',
    'Dez'
  ]
];

List<double> dailyTaskProgressData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
List<double> weeklyTaskProgressData = [0.0, 0.0, 0.0, 0.0];
List<double> monthlyTaskProgressData = [
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0
];

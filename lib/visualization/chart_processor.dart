import 'dataset.dart';

void calculateDailyTaskProgress(String subFilterValue) {
  if (subFilterValue == 'Assigned Task') {
    dailyTaskProgressData = [2.0, 4.0, 5.0, 9.0, 3.0, 0.0, 1.0];
    // dailyTaskProgressData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  }
  if (subFilterValue == 'Completed Task') {
    // dailyTaskProgressData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    dailyTaskProgressData = [2.0, 3.0, 2.0, 5.0, 1.0, 0.0, 1.0];
  }
  if (subFilterValue == 'Expired Task') {
    // dailyTaskProgressData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    dailyTaskProgressData = [0.0, 1.0, 3.0, 4.0, 2.0, 0.0, 0.0];
  }
}

void calculateWeeklyTaskProgress(String subFilterValue) {
  if (subFilterValue == 'Assigned Task') {
    // weeklyTaskProgressData = [0.0, 0.0, 0.0, 0.0];
    weeklyTaskProgressData = [6.0, 8.0, 5.0, 9.0];
  }
  if (subFilterValue == 'Completed Task') {
    // weeklyTaskProgressData = [0.0, 0.0, 0.0, 0.0];
    weeklyTaskProgressData = [2.0, 3.0, 2.0, 5.0];
  }
  if (subFilterValue == 'Expired Task') {
    // weeklyTaskProgressData = [0.0, 0.0, 0.0, 0.0];
    weeklyTaskProgressData = [4.0, 5.0, 3.0, 4.0];
  }
}

void calculateMonthlyTaskProgress(String subFilterValue) {
  if (subFilterValue == 'Assigned Task') {
    monthlyTaskProgressData = [
      12.0,
      14.0,
      34.0,
      9.0,
      13.0,
      10.0,
      1.0,
      34.0,
      9.0,
      13.0,
      10.0,
      1.0
    ];
  }
  if (subFilterValue == 'Completed Task') {
    monthlyTaskProgressData = [
      10.0,
      4.0,
      14.0,
      5.0,
      10.0,
      10.0,
      1.0,
      14.0,
      5.0,
      10.0,
      10.0,
      1.0
    ];
  }
  if (subFilterValue == 'Expired Task') {
    monthlyTaskProgressData = [
      2.0,
      10.0,
      20.0,
      4.0,
      3.0,
      0.0,
      0.0,
      20.0,
      4.0,
      3.0,
      0.0,
      0.0
    ];
  }
}

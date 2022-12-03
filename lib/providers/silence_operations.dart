import 'package:flutter/material.dart';

class SilenceOperation extends ChangeNotifier {
  bool isSelected = false;
  bool isType = false;
  bool tureOnce1 = true;
  bool tureOnce2 = true;

  bool get getTureOnce1 => tureOnce1;
  bool get getTureOnce2 => tureOnce2;
  bool get getIsSelected => isSelected;
  bool get getIsType => isType;

  void setTureOnce1(bool value) {
    tureOnce1 = value;
    notifyListeners();
  }

  void setTureOnce2(bool value) {
    tureOnce2 = value;
    notifyListeners();
  }

  void setIsSelected(bool value) {
    isSelected = value;
    notifyListeners();
  }

  void setIsType(bool value) {
    isType = value;
    notifyListeners();
  }
}

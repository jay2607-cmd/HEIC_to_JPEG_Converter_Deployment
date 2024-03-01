import 'package:flutter/material.dart';

class HeicToJpgProvider with ChangeNotifier{
  String selectedFormat = "jpeg";

  List<String> formatList = ["jpeg", "png", "webp"];

  setFormat(value) {
    selectedFormat = value;
    notifyListeners();
  }

}
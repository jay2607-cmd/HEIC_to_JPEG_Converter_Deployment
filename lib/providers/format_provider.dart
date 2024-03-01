import 'package:flutter/material.dart';

List<String> selectedFormatList = ["jpeg", "png", "webp"];

class FormatProvider extends ChangeNotifier {

  String _selectedFormat = selectedFormatList[0]; // Default value



}

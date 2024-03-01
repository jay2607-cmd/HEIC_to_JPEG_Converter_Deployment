import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heic_converter/screens/history_screen.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constant.dart';

class MultiHEICConverter extends StatefulWidget {
  const MultiHEICConverter({super.key});

  @override
  State<MultiHEICConverter> createState() => _MultiHEICConverterState();
}

class _MultiHEICConverterState extends State<MultiHEICConverter> {
  String? selectedFormat;
  bool isButtonEnabled = true;

  _MultiHEICConverterState() {
    selectedFormat = selectedFormatList[0];
  }

  TextEditingController qualityController = TextEditingController(text: "100");
  TextEditingController angleController = TextEditingController(text: "0");

  List<String> selectedFormatList = [
    "HEIC TO JPEG",
    "HEIC TO PNG",
    "HEIC TO WEBP"
  ];

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
              "Are you sure you want to Select File From Local Storage?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                getMultipleHEICFile();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  getMultipleHEICFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['heic', 'heif']);

    if (result != null) {
      List<File?> file = result.paths.map((path) => File(path!)).toList();
      files = file;
      setState(() {});
      print("files.length ${files.length}");
    } else {
      Fluttertoast.showToast(
          msg: "Please Select at least One File",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red);
    }
  }

  String convertedFilePath = "";

  convertToJPG(String filePath, String targetFormat) async {
    // you may also add another conditional to check, that is the platform iOS or macOS
    if (filePath.contains('heic') || filePath.contains('heif')) {
      final tmpDir = (await getTemporaryDirectory()).path;
      final target =
          '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.$targetFormat';

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        target,
        format: targetFormat == "jpeg"
            ? CompressFormat.jpeg
            : targetFormat == "webp"
                ? CompressFormat.webp // Set to CompressFormat.jpeg for webp
                : CompressFormat.png,
        quality: int.parse(qualityController.text) >= 0 &&
                int.parse(qualityController.text) <= 100
            ? int.parse(qualityController.text)
            : 100,
        rotate: int.parse(angleController.text) >= 0 &&
                int.parse(angleController.text) <= 360
            ? int.parse(angleController.text)
            : 0,
      );

      if (result == null) {
        Fluttertoast.showToast(
            msg: "Invalid Input",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.red);
        convertedFilePath = "";
      } else {
        convertedFilePath = result.path;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Converting..."),
          duration: Duration(milliseconds: 250),
          backgroundColor: Colors.blue,
        ));
      }
      print("result!.path ${result!.path}");
      setState(() {});
    }
  }

  // Variable for showing multiple files
  List<File?> files = [];
  @override
  Widget build(BuildContext context) {
    String? newSelectedFormat = selectedFormat;

    print(files);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 85,
          automaticallyImplyLeading: false,
          leadingWidth: 65,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Transform.scale(
              scale: 1.25,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Image.asset(
                  'assets/images/2/back.png',
                ),
              ),
            ),
          ),
          title: Text(
            "Multiple Converter",
            style: kAppbarStyle,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: files.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.70,
                      ),
                      itemCount: files.length,
                      itemBuilder: (BuildContext context, int index) {
                        final filePath = files[index]!.path;
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Container(
                                  width: 100,
                                  child: FutureBuilder<void>(
                                    future: precacheImage(
                                        FileImage(File(filePath)), context),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Image.asset(
                                          width: 50,
                                          'assets/images/save.png', // Replace with your placeholder image asset path
                                          fit: BoxFit.cover,
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return Image.file(File(filePath));
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                filePath.isNotEmpty
                                    ? filePath.split("/").last
                                    : "Loading...", // Display "Loading..." while waiting for the file path
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Center(child: Text("No file chosen")),
            ),
            files.isNotEmpty
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Color(
                                    0xff06B4D0), // Set the dropdown background color
                              ),
                              child: buildFormatDropdownButtonFormField(
                                selectedValue: newSelectedFormat.toString(),
                                onValueChanged: (val) {
                                  setState(() {
                                    newSelectedFormat = val;
                                    selectedFormat = newSelectedFormat;
                                    print(newSelectedFormat);
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              margin: EdgeInsets.only(left: 26, right: 28),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        // color: Color(0xff141414),
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,

                                          colors: [
                                            Color(0xff222222),
                                            Color(0xff171717)
                                          ], // Add your colors here
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.2), // Shadow color
                                            spreadRadius: 1, // Spread radius
                                            blurRadius: 5, // Blur radius
                                            offset: Offset(0,
                                                7), // Offset of the shadow (0, 3) adds shadow at the bottom
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 14.0),
                                        child: Center(
                                          child: TextField(
                                            controller: qualityController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              prefix: Text(
                                                "Quality : ",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              border: InputBorder.none,
                                              hintText: "Quality",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        // color: Color(0xff141414),
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,

                                          colors: [
                                            Color(0xff222222),
                                            Color(0xff171717)
                                          ], // Add your colors here
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.2), // Shadow color
                                            spreadRadius: 1, // Spread radius
                                            blurRadius: 5, // Blur radius
                                            offset: Offset(0,
                                                7), // Offset of the shadow (0, 3) adds shadow at the bottom
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 18.0),
                                        child: TextField(
                                          controller: angleController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            prefix: Text(
                                              "Rotate : ",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            hintText: "Angle",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: isButtonEnabled
                              ? () async {
                                  setState(() {
                                    isButtonEnabled =
                                        false; // Disable the button
                                  });

                                  int length = files.length;

                                  for (int i = 0; i < length; i++) {
                                    await convertToJPG(files[i]!.path,
                                        selectedFormat
                                            .toString()
                                            .toLowerCase()
                                            .split(" ")
                                            .last);
                                  }

                                  // Show the success toast message
                                  await Fluttertoast.showToast(
                                      msg: "Image Converted Successfully",
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.green);

                                  // Delay re-enabling the button for a short time (e.g., 1 second)
                                  await Future.delayed(Duration(seconds: 2));

                                  setState(() {
                                    isButtonEnabled =
                                        true; // Re-enable the button
                                  });

                                  // Navigate to the next screen
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HistoryScreen(isFromHEICTOJPG: true,)));
                                }
                              : null, // Disable the button if isButtonEnabled is false,
                          child: Image.asset(
                            "assets/images/2/convert_image_btn.png",
                            height: 90,
                          )),
                    ],
                  )
                : SizedBox.shrink()
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // showFormatDialog(context);
            _showConfirmationDialog(context);
          },
          child: Image.asset("assets/images/2/add.png"),
          backgroundColor: Color(0xff10B981),
        ));
  }

  // Padding buildFormatDropdownButtonFormField({
  //   required String selectedValue,
  //   required Function(String) onValueChanged,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         isExpanded: true,
  //         value: selectedValue,
  //         items: selectedFormatList
  //             .map((e) => DropdownMenuItem<String>(
  //                   value: e,
  //                   child: Text(e),
  //                 ))
  //             .toList(),
  //         onChanged: (val) {
  //           onValueChanged(val!);
  //         },
  //       ),
  //     ),
  //   );
  // }

  Padding buildFormatDropdownButtonFormField({
    required String selectedValue,
    required Function(String) onValueChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          // dropdownColor: Color(0xff06B4D0), // Set the dropdown background color
          iconSize: 40,
          icon: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Image.asset(
              "assets/images/2/down-arrow.png",
              height: 17,
            ),
          ),
          iconEnabledColor: Colors.white,
          value: selectedValue,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color
          ),
          items: selectedFormatList
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            onValueChanged(val!);
          },
        ),
      ),
    );
  }
}

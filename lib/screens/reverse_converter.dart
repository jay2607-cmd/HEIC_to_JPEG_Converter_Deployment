import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constant.dart';
import '../utils/google_ads.dart';
import 'history_screen.dart';

class ReverseConverter extends StatefulWidget {
  const ReverseConverter({super.key});

  @override
  State<ReverseConverter> createState() => _ReverseConverterState();
}

class _ReverseConverterState extends State<ReverseConverter> {
  String filePath = "";
  String convertedFilePath = "";

  late BannerAd bannerAd;
  bool isLoaded = false;
  var adUnit = adBannerUnit;

  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnit,
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          isLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
        print(error);
      }),
      request: AdRequest(),
    );

    bannerAd.load();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBannerAd();
  }

  void getImage() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg' 'png', 'webp']);

    if (resultFile != null) {
      PlatformFile file = resultFile.files.first;
      print(file.path);
      setState(() {
        filePath = file.path!;

        print("filepath $filePath");
        // convertToHEIC();
      });
    } else {
      filePath = "";
      print("no file selected");
    }
  }

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
                getImage();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  convertToHEIC() async {
    if (filePath.toLowerCase().contains('jpg') ||
        filePath.toLowerCase().contains('jpeg') ||
        filePath.toLowerCase().contains('png') ||
        filePath.toLowerCase().contains('webp')) {
      final tmpDir = (await getTemporaryDirectory()).path;
      final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.heic';
      print("Target: $target");
      print("Source File: $filePath");

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        target,
        format: CompressFormat.heic,
        quality: 100,
        rotate: 0,
      );

      if (result == null) {
        Fluttertoast.showToast(
          msg: "Invalid Input",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
        );
        convertedFilePath = "";
      } else {
        convertedFilePath = result.path;
        Fluttertoast.showToast(
          msg: "Image Converted Successfully",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
        );
        print("Converted File Path: ${result.path}");
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            "Reverse Converter",
            style: kAppbarStyle,
          ),
        ),
        body: Column(
          children: [
            filePath.isNotEmpty && convertedFilePath.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                            width: 325, child: Image.file(File(filePath))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(child: Text(filePath.split("/").last)),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          convertToHEIC();
                        },
                        child: Image.asset(
                          "assets/images/2/convert_image_btn.png",
                          height: 90,
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            convertedFilePath != ""
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                            width: 325,
                            child: Image.file(File(convertedFilePath))),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoryScreen(
                                        isFromHEICTOJPG: true,
                                      )));
                        },
                        child: Image.asset(
                          "assets/images/3/view_all.png",
                          height: 90,
                        ),
                      ),
                    ],
                  )
                : Center(child: Text("No Converted Images")),
            Center(child: Text(convertedFilePath.split("/").last)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showConfirmationDialog(context);
          },
          child: Image.asset("assets/images/2/add.png"),
          backgroundColor: Color(0xff10B981),
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.all(5),
          child: isLoaded
              ? SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: bannerAd),
                )
              : SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                ),
        ),
      ),
    );
  }
}

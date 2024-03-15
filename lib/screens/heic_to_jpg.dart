import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:heic_converter/screens/history_screen.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constant.dart';
import '../utils/google_ads.dart';

class HeicToJpg extends StatefulWidget {
  const HeicToJpg({super.key});

  @override
  State<HeicToJpg> createState() => _HeicToJpgState();
}

class _HeicToJpgState extends State<HeicToJpg> {
  String filePath = "";
  String convertedFilePath = "";
  bool isFromHEICTOJPG = true;
  TextEditingController qualityController = TextEditingController(text: "100");
  TextEditingController angleController = TextEditingController(text: "0");

  String? selectedFormat;

  _HeicToJpgState() {
    selectedFormat = selectedFormatList[0];
  }

  List<String> selectedFormatList = [
    "HEIC TO JPEG",
    "HEIC TO PNG",
    "HEIC TO WEBP"
  ];

  void getHeic() async {
    FilePickerResult? resultFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['heic', 'heif']);

    if (resultFile != null) {
      PlatformFile file = resultFile.files.first;
      print(file.path);
      setState(() {
        filePath = file.path!;

        print("filepath $filePath");
        // convertToJPG(selectedFormat.toString());
      });
    } else {
      filePath = "";
      print("no file selected");
    }
  }

  convertToJPG(String targetFormat) async {
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
        Fluttertoast.showToast(
            msg: "Image Converted Successfully",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.green);
      }
      print("result!.path ${result!.path}");
      setState(() {});
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
                getHeic();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFile(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();

        print('$filePath deleted successfully');
      }
    } catch (e) {
      print('Error while deleting file: $e');
    }
  }

  // for banner ad
  late BannerAd bannerAd;
  var adUnit = adBannerUnit;
  bool isLoaded = false;

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

  late InterstitialAd interstitialAd;
  bool isInterstitaleLoaded = false;

  // interstitle app id
  var adInterstitaleUnit = adIntUnit;

  initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adInterstitaleUnit,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
        interstitialAd = ad;
        setState(() {
          isInterstitaleLoaded = true;
        });
        interstitialAd.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
          ad.dispose();

          setState(() {
            isInterstitaleLoaded = false;
          });

          // do your task for close activity
          Navigator.pop(context);
        }, onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();

          setState(() {
            isInterstitaleLoaded = false;
          });
        });
      }, onAdFailedToLoad: (error) {
        interstitialAd.dispose();
      }),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBannerAd();
    initInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    String? newSelectedFormat = selectedFormat;

    return WillPopScope(
      onWillPop: () async {
        if (isInterstitaleLoaded) {
          interstitialAd.show();
          return false; // Prevent the default back navigation
        } else {
          return true; // Allow the default back navigation
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 85,
            automaticallyImplyLeading: false,
            leadingWidth: 65,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                if (isInterstitaleLoaded) {
                  interstitialAd.show();
                } else {
                  Navigator.pop(context);
                }
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
              "Converter",
              style: kAppbarStyle,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                filePath.isNotEmpty && convertedFilePath.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                width: 260,
                                child: Image.file(File(filePath)),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(filePath.split("/").last),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Color(
                                          0xff06B4D0), // Set the dropdown background color
                                    ),
                                    child: buildFormatDropdownButtonFormField(
                                      selectedValue:
                                          newSelectedFormat.toString(),
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
                                    margin:
                                        EdgeInsets.only(left: 26, right: 28),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              // color: Color(0xff141414),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                  color: Colors.black
                                                      .withOpacity(
                                                          0.2), // Shadow color
                                                  spreadRadius:
                                                      1, // Spread radius
                                                  blurRadius: 5, // Blur radius
                                                  offset: Offset(0,
                                                      7), // Offset of the shadow (0, 3) adds shadow at the bottom
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 14.0),
                                              child: Center(
                                                child: TextField(
                                                  controller: qualityController,
                                                  keyboardType:
                                                      TextInputType.number,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                  color: Colors.black
                                                      .withOpacity(
                                                          0.2), // Shadow color
                                                  spreadRadius:
                                                      1, // Spread radius
                                                  blurRadius: 5, // Blur radius
                                                  offset: Offset(0,
                                                      7), // Offset of the shadow (0, 3) adds shadow at the bottom
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 18.0),
                                              child: TextField(
                                                controller: angleController,
                                                keyboardType:
                                                    TextInputType.number,
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
                                  GestureDetector(
                                      onTap: () {
                                        convertToJPG(selectedFormat
                                            .toString()
                                            .toLowerCase()
                                            .split(" ")
                                            .last);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Converting..."),
                                          duration:
                                              Duration(milliseconds: 1000),
                                          backgroundColor: Colors.blue,
                                        ));
                                      },
                                      child: Image.asset(
                                        "assets/images/2/convert_image_btn.png",
                                        height: 90,
                                      )),
                                  SizedBox(height: 16),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                convertedFilePath.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                width: 400,
                                child: Image.file(File(convertedFilePath)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HistoryScreen(
                                              isFromHEICTOJPG: isFromHEICTOJPG,
                                            )));
                              },
                              child: Image.asset(
                                "assets/images/3/view_all.png",
                                height: 90,
                              ))
                        ],
                      )
                    : Center(child: Text("No Converted Images")),
                Text(convertedFilePath.split("/").last),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // showFormatDialog(context);
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
      ),
    );
  }

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

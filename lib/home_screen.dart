import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:heic_converter/screens/bookmarked_images.dart';
import 'package:heic_converter/screens/heic_to_jpg.dart';
import 'package:heic_converter/screens/history_screen.dart';
import 'package:heic_converter/screens/multi_heic_converter.dart';
import 'package:heic_converter/screens/reverse_converter.dart';
import 'package:heic_converter/utils/google_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import 'info.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;

  NativeAd? nativePopUpAd;
  bool isNativePopUpAdLoaded = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    loadNativeAd();
    loadNativePopUpAd();
  }

  void loadNativePopUpAd() {
    nativePopUpAd = NativeAd(
      adUnitId: adNativeUnit,
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          isNativePopUpAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        nativePopUpAd!.dispose();
      }),
      request: const AdRequest(),
    );
    nativePopUpAd!.load();
  }

  void loadNativeAd() {
    nativeAd = NativeAd(
      adUnitId: adNativeUnit,
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          isNativeAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        nativeAd!.dispose();
      }),
      request: const AdRequest(),
    );
    nativeAd!.load();
  }

  var toLaunch;

  @override
  Widget build(BuildContext context) {
    toLaunch = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.expressway.noisedetector.sm&pli=1');

    return WillPopScope(
      onWillPop: () {
        return showExitPopup();
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand, // Make the stack take up the entire screen
            children: [
              // Background Image
              Image.asset(
                'assets/images/1/bg1.png', // Replace with your image file's path
                fit: BoxFit.cover, // Adjust the fit as needed
              ),

              // Buttons and content

              Container(
                color: Colors.transparent, // Make the container transparent
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16, top: 30, bottom: 12),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: [
                          IconButton(
                            iconSize: 40,
                            onPressed: () {},
                            icon: Image.asset("assets/images/1/ad.png"),
                          ),
                          Expanded(
                            child: IconButton(
                              iconSize: 85,
                              onPressed: () {},
                              icon: Image.asset("assets/images/1/title.png"),
                            ),
                          ),
                          IconButton(
                            iconSize: 40,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Info()));
                            },
                            icon: Image.asset("assets/images/1/info.png"),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HeicToJpg()),
                              );
                            },
                            child: Image.asset(
                              "assets/images/1/heic-to-jpeg.png",
                              width: MediaQuery.of(context).size.width * 0.620,
                              height: MediaQuery.of(context).size.height *
                                  0.17, // Original height
                              // Use transform to scale vertically
                              // Adjust the 1.5 value as needed
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.089,
                      ),
                      child: GridView.count(
                        childAspectRatio: 4 / 3,
                        shrinkWrap: true,
                        // primary: false,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 8,
                        crossAxisCount: 2,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReverseConverter()),
                              );
                            },
                            child: Image.asset(
                              "assets/images/1/reverse.png",
                              // Use transform to scale vertically
                              // Adjust the 1.5 value as needed
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiHEICConverter()),
                              );
                            },
                            child: Image.asset(
                              "assets/images/1/multiple.png",
                              // Use transform to scale vertically
                              // Adjust the 1.5 value as needed
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookmarkedImages()),
                              );
                            },
                            child: Image.asset(
                              "assets/images/1/bookmark.png",
                              // Use transform to scale vertically
                              // Adjust the 1.5 value as needed
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HistoryScreen(
                                          isFromHEICTOJPG: false,
                                        )),
                              );
                            },
                            child: Image.asset(
                              "assets/images/1/saved.png",
                              // Use transform to scale vertically
                              // Adjust the 1.5 value as needed
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isNativeAdLoaded
              ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: 265,
                  child: AdWidget(
                    ad: nativeAd!,
                  ),
                )
              : SizedBox(),
        ),
      ),
    );
  }

  bool isShowAds = true;
  Future<void>? _launched;

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit an App?'),
            actions: [
              Column(
                children: [
                  isNativePopUpAdLoaded
                      ? Visibility(
                          visible: isShowAds,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            height: 265,
                            width: 300,
                            child: AdWidget(
                              ad: nativePopUpAd!,
                            ),
                          ),
                        )
                      : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _launched = _launchInBrowser(toLaunch);
                        }),

                        //return false when click on "NO"
                        child: Text('Rate US'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        //return false when click on "NO"
                        child: Text('No'),
                      ),
                      ElevatedButton(
                        onPressed: () => SystemNavigator.pop(),
                        //return true when click on "Yes"
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ) ??
        Future.value(
            false); //if showDialouge had returned null, then return false
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home_screen.dart';
import '../utils/constant.dart';
import '../utils/google_ads.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isInterstitaleLoaded = false;
  var adInterstitaleUnit = adIntUnit;

  late InterstitialAd interstitialAd;

  initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adInterstitaleUnit,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
        interstitialAd = ad;
        isInterstitaleLoaded = true;
        setState(() {});
        interstitialAd.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
          ad.dispose();

          setState(() {
            isInterstitaleLoaded = false;
          });

          // do your task for close activity
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        title: 'HEIC Converter',
                      )));
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

  late SharedPreferences preferences;
  loadIsPersonalised() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadIsPersonalised();
    initInterstitialAd();

    Timer(const Duration(milliseconds: 2500), () {
      if (isInterstitaleLoaded) {
        if (preferences.getBool("isPersonalised") == true) {
          interstitialAd.show();
        } else {
          showExitPopup();
        }
      } else {
        if (preferences.getBool("isPersonalised") == true) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MyHomePage(title: "HEIF TO JPG CONVERTER")));
        } else {
          // show pop
          showExitPopup();
        }
      }
    });
  }

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
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: Row(
              children: [
                Image.asset(
                  "assets/images/splash_icn.png",
                  height: 40,
                  width: 40,
                ),
                SizedBox(
                  width: 20,
                ),
                Text('HEIC Converter'),
              ],
            ),
            content: Text(
              'We care about your privacy & data security. We keep this app free by showing ads.\n\nWith your permission at launch time we are showing tailor ads to you.\n\nIf you want to change setting of your consent, please click below \'Deactivate\' button.',
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyHomePage(title: "HEIF Converter")));

                      preferences.setBool("isPersonalised", true);
                      print("preferences.getBool('isPersonalised')");
                      print(preferences.getBool("isPersonalised"));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff724BE5), // Set background color
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Add border radius
                      ),
                    ),
                    child: Text('Yes, Continue'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff724BE5),
                      padding: EdgeInsets.symmetric(
                          vertical: 16), // Add vertical padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Add border radius
                      ),
                    ),
                    child: Text('Exit'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _launched =
                              _launchInBrowser(Uri.parse(kPrivacyPolicy));
                        });
                      },
                      child: Text("Privacy & Policy")),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _launched =
                              _launchInBrowser(Uri.parse(kPrivacyPolicy));
                        });
                      },
                      child: Text("How App & Our Partners uses your data!")),
                ],
              ),
            ],
          ),
        ) ??
        Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand, // Make the stack take up the entire screen

          children: [
            Image.asset(
              'assets/images/splash_bg.png', // Replace with your image file's path
              fit: BoxFit.cover,
            ),
            const Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 14),
                  child: Image(
                    image: AssetImage(
                      "assets/images/splash_icn.png",
                    ),
                    height: 210,
                    width: 210,
                  ),
                ),
                Image(
                  image: AssetImage(
                    "assets/images/splash_title.png",
                  ),
                  height: 165,
                  width: 165,
                ),
                SizedBox(
                  height: 150,
                ),
                Text(
                  "Loading...",
                  style: TextStyle(fontSize: 36, fontFamily: "Candlescript"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

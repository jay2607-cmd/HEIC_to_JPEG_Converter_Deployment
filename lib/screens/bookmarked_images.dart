import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:heic_converter/screens/gallery_photo_viewer.dart';
import 'package:hive/hive.dart';

import '../database/bookmark.dart';
import '../utils/constant.dart';
import '../utils/google_ads.dart';

class BookmarkedImages extends StatefulWidget {
  const BookmarkedImages({super.key});

  @override
  State<BookmarkedImages> createState() => _BookmarkedImagesState();
}

class _BookmarkedImagesState extends State<BookmarkedImages> {
  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>("bookmark");

  var adUnit = adBannerUnit;
  late BannerAd bannerAd;
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

  bool isInterstitaleLoaded = false;
  var adInterstitaleUnit = adIntUnit;

  late InterstitialAd interstitialAd;

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
    List<Bookmark> bookmarkedImages = bookmarkBox.values.toList();
    List<File> imageFiles = [];

    return WillPopScope(
      onWillPop: () async {
        if (isInterstitaleLoaded) {
          interstitialAd.show();
          return false; // Prevent the default back navigation
        } else {
          return true; // Allow the default back navigation
        }
      },
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: 85,
            automaticallyImplyLeading: false,
            leadingWidth: 65,
            backgroundColor: Colors.black,
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
              "Gallery",
              style: kAppbarStyle,
            )),
        body: bookmarkedImages.isEmpty
            ? Center(
                child: Text('No Bookmarked Images'),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1 / 1.30,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: bookmarkBox.length,
                        itemBuilder: (BuildContext context, index) {
                          String filePath = bookmarkedImages[index].path;

                          bool isBookmarked = bookmarkBox.values
                              .any((bookmark) => bookmark.path == filePath);

                          imageFiles.add(File(filePath));

                          return filePath.split("/").last.contains(".jpeg") ||
                                  filePath.split("/").last.contains(".png") ||
                                  filePath.split("/").last.contains(".webp")
                              ? GestureDetector(
                                  onTap: () {
                                    print("${index}");

                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GalleryPhotoViewWrapper.path(
                                                  imageFiles: imageFiles,
                                                  initialIndex: index,
                                                  path: 'path',
                                                )));
                                  },
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              child: Container(
                                                child:
                                                    Image.file(File(filePath)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Stack(
                                          children: [
                                            // ClipRect to only show the circular avatar over the image
                                            Positioned(
                                              right: -69,
                                              top: -69,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 52,
                                                      color: Colors.black),
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                            ),
                                            // Bookmark icon
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                onPressed: () {
                                                  if (isBookmarked) {
                                                    bookmarkBox.deleteAt(
                                                        bookmarkBox
                                                            .values
                                                            .toList()
                                                            .indexWhere(
                                                                (bookmark) =>
                                                                    bookmark
                                                                        .path ==
                                                                    filePath));
                                                  } else {
                                                    bookmarkBox.add(Bookmark(
                                                        path: filePath));
                                                  }
                                                  setState(() {});
                                                },
                                                icon: isBookmarked
                                                    ? Transform.scale(
                                                        scale: 0.76,
                                                        child: Image.asset(
                                                          "assets/images/4/bookmark_h.png",
                                                        ),
                                                      )
                                                    : Transform.scale(
                                                        scale: 0.76,
                                                        child: Image.asset(
                                                          "assets/images/4/bookmark.png",
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              filePath.split('/').last,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
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

import 'dart:io';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:heic_converter/screens/gallery_photo_viewer.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../database/bookmark.dart';
import '../utils/constant.dart';
import '../utils/google_ads.dart';

class HistoryScreen extends StatefulWidget {
  bool isFromHEICTOJPG;
  HistoryScreen({super.key, required this.isFromHEICTOJPG});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<File> imageFiles = [];
  late File file;
  List<File> heicFiles = [];

  Future<void> loadImagesWithJPEGExtensions(
    List<String> extensions,
  ) async {
    final directory = await getTemporaryDirectory();
    final files = directory.listSync(recursive: true);
    final imageFiles = files.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      return extensions.contains(extension);
    }).toList();
    setState(() {
      this.imageFiles = imageFiles;
    });
  }

  Future<void> loadImagesWithHEICExtensions(List<String> extensions) async {
    final directory = await getTemporaryDirectory();
    final files = directory.listSync(recursive: true);
    final imageFiles = files.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      final pathSegments = file.path.split('/');
      // Exclude files inside the "file_picker" folder
      if (pathSegments.contains('file_picker')) {
        return false;
      }
      return extensions.contains(extension);
    }).toList();
    setState(() {
      this.heicFiles = imageFiles;
    });
  }

  Future<void> deleteAllFilesInFolder(String path) async {
    String folderPath = path;
    Directory folder = Directory(folderPath);
    if (await folder.exists()) {
      List<FileSystemEntity> entities = folder.listSync();
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          await entity.delete();

          bool isBookmarked =
              bookmarkBox.values.any((bookmark) => bookmark.path == file.path);

          if (isBookmarked) {
            bookmarkBox.deleteAt(bookmarkBox.values
                .toList()
                .indexWhere((bookmark) => bookmark.path == file.path));
          }

          print('Deleted file: ${entity.path}');
        }
      }
      setState(() {
        imageFiles.removeRange(0, imageFiles.length);

        heicFiles.removeRange(
            0, heicFiles.length); // Clear the file list after deletion
      });
      print('All files in folder deleted successfully');
    } else {
      print('Folder does not exist');
    }
  }

  @override
  void initState() {
    super.initState();
    initInterstitialAd();
    loadImagesWithJPEGExtensions(['jpeg', 'png', 'webp']);
    loadImagesWithHEICExtensions(['heic', 'heif']);
  }

  initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: widget.isFromHEICTOJPG ? adInterstitaleUnit : "",
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



  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');

  void sortFilesByLastModified(List<File> files, String document) {
    files.sort((a, b) {
      var aModified = a.lastModifiedSync();
      var bModified = b.lastModifiedSync();
      return bModified.compareTo(aModified);
    });
  }

  late InterstitialAd interstitialAd;
  bool isInterstitaleLoaded = false;

  // interstitle app id
  var adInterstitaleUnit = adIntUnit;

  @override
  Widget build(BuildContext context) {
    sortFilesByLastModified(imageFiles, "images");
    return WillPopScope(
      onWillPop: () async {
        if (isInterstitaleLoaded) {
          interstitialAd.show();
          return false; // Prevent the default back navigation
        } else {
          return true; // Allow the default back navigation
        }
      },
      child: DefaultTabController(
        length: 2,
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
              "History",
              style: kAppbarStyle,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 12),
                child: IconButton(
                    onPressed: () {
                      deleteAllFilesInFolder(
                          "/data/user/0/com.example.heic_converter/cache/");
                      deleteAllFilesInFolder(
                          "/data/user/0/com.example.heic_converter/cache/file_picker/");
                    },
                    icon: Transform.scale(
                        scale: 2.2,
                        child: Image.asset(
                          "assets/images/4/delete.png",
                        ))),
              )
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: backgroundUI,
                      borderRadius: BorderRadius.circular(10)),
                  child: TabBar(
                    unselectedLabelColor: Color(0xff6E6E6E),
                    indicator: BoxDecoration(color: Colors.transparent),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(
                        height: 40,
                        child: Text(
                          "HEIC Converter",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Text(
                          "Reverse Converter",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            child: TabBarView(
              children: [
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.30,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: imageFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    File file = imageFiles[index];
                    bool isBookmarked = bookmarkBox.values
                        .any((bookmark) => bookmark.path == file.path);

                    return GestureDetector(
                      onTap: () {
                        print("$index");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryPhotoViewWrapper(
                              imageFiles: imageFiles,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Container(
                                      child: Image.file(file),
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
                                            width: 52, color: Colors.black),
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
                                          bookmarkBox.deleteAt(bookmarkBox.values
                                              .toList()
                                              .indexWhere((bookmark) =>
                                                  bookmark.path == file.path));
                                        } else {
                                          bookmarkBox
                                              .add(Bookmark(path: file.path));
                                        }
                                        setState(
                                            () {}); // Update the UI by calling setState
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
                                margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    file.path.split('/').last,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                      ),
                    ));
                  },
                ),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.30,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: heicFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    File file = heicFiles[index];
                    bool isBookmarked = bookmarkBox.values
                        .any((bookmark) => bookmark.path == file.path);

                    return GestureDetector(
                      onTap: () {
                        print("$index");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryPhotoViewWrapper(
                              imageFiles: heicFiles,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Container(
                                      child: Image.file(file),
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
                                            width: 52, color: Colors.black),
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
                                          bookmarkBox.deleteAt(bookmarkBox.values
                                              .toList()
                                              .indexWhere((bookmark) =>
                                                  bookmark.path == file.path));
                                        } else {
                                          bookmarkBox
                                              .add(Bookmark(path: file.path));
                                        }
                                        setState(
                                            () {}); // Update the UI by calling setState
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
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    file.path.split('/').last,
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
                      ),
                    );
                  },
                )
// ,              GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   childAspectRatio: 1.5 / 3,
//                   crossAxisSpacing: 20.0,
//                   mainAxisSpacing: 30.0,
//                 ),
//                 itemCount: heicFiles.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   file = heicFiles[index];
//                   return GestureDetector(
//                     onTap: () {
//                       print("${index}");
//                       Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   //     ScreenshotPreview(
//                                   //   filePath: imageFiles[index].path,
//                                   //   file: imageFiles[index],
//                                   //   imageFiles: imageFiles,
//                                   //   index: index,
//                                   // )
//                                   GalleryPhotoViewWrapper(
//                                       imageFiles: heicFiles,
//                                       initialIndex: index)));
//                     },
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: Image.file(file),
//                         ),
//                         Text(file.path.split("/").last),
//                       ],
//                     ),
//                   );
//                 },
//               ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyTabIndicator extends Decoration {
  final Color overlayColor;

  const MyTabIndicator({required this.overlayColor});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MyTabIndicatorPainter(overlayColor: overlayColor);
  }
}

class _MyTabIndicatorPainter extends BoxPainter {
  final Color overlayColor;

  _MyTabIndicatorPainter({required this.overlayColor});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(10)),
      paint,
    );
  }
}

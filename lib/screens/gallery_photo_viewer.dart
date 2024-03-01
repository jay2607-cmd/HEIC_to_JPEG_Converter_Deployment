import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heic_converter/screens/bookmarked_images.dart';
import 'package:hive/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../database/bookmark.dart';
import '../utils/constant.dart';
import 'history_screen.dart';
import 'image_details.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  final List<File> imageFiles;
  final int initialIndex;

  String path = "";

  GalleryPhotoViewWrapper({
    Key? key,
    required this.imageFiles,
    required this.initialIndex,
  }) : super(key: key);

  GalleryPhotoViewWrapper.path(
      {Key? key,
      required this.imageFiles,
      required this.initialIndex,
      required this.path})
      : super(key: key);

  @override
  _GalleryPhotoViewWrapperState createState() =>
      _GalleryPhotoViewWrapperState();
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late PageController pageController;
  int currentIndex = 0; // Track the currently displayed image index

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex; // Initialize currentIndex
  }

  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');

  Future<void> deleteFile(int index) async {
    try {
      File file = widget.imageFiles[index];
      if (await file.exists()) {
        await file.delete();

        bool isBookmarked =
            bookmarkBox.values.any((bookmark) => bookmark.path == file.path);

        if (isBookmarked) {
          bookmarkBox.deleteAt(bookmarkBox.values
              .toList()
              .indexWhere((bookmark) => bookmark.path == file.path));
        }

        setState(() {
          widget.imageFiles.removeAt(index);
          // Update currentIndex if necessary
          if (index <= currentIndex) {
            currentIndex = currentIndex - 1;
          }
        });
        print('${file.path} deleted successfully');
      }
    } catch (e) {
      print('Error while deleting file: $e');
    }
  }

  Future<void> shareFile(int index) async {
    try {
      await Share.shareFiles([widget.imageFiles[index].path],
          text: widget.imageFiles[index].path.split("/").last);
    } catch (e) {
      print('Error while sharing file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopScope,
        child: Scaffold(
          backgroundColor: Colors.black,
            appBar: AppBar(
                toolbarHeight: 85,
                automaticallyImplyLeading: false,
                leadingWidth: 65,
                backgroundColor: Colors.black,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () {
                    _willPopScope();
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
            body: Column(children: [
              Text(
                widget.imageFiles[currentIndex].path.split("/").last,
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),

              ),
              Expanded(
                child: PhotoViewGallery.builder(
                  itemCount: widget.imageFiles.length,
                  pageController: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index; // Update currentIndex when swiping
                    });
                  },
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(widget.imageFiles[index]),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      heroAttributes: PhotoViewHeroAttributes(tag: index),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 80,
                      onPressed: () {
                        deleteFile(currentIndex); // Use currentIndex
                      },
                      icon: Image.asset("assets/images/8/delete_icn.png"),
                    ),
                    IconButton(
                      iconSize: 80,
                      onPressed: () {
                        shareFile(currentIndex); // Use currentIndex
                      },
                      icon: Image.asset("assets/images/8/share_icn.png"),
                    ),
                    IconButton(
                      iconSize: 80,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImageDetails(
                                      file: widget.imageFiles[currentIndex],
                                    )));
                      },
                      icon: Image.asset("assets/images/8/info_icn.png"),
                    ),
                  ],
                ),
              ),
            ])));
  }

  Future<bool> _willPopScope() {
    if (widget.path.isNotEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BookmarkedImages()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HistoryScreen(isFromHEICTOJPG: false,)));
    }

    return Future.value(true);
  }
}

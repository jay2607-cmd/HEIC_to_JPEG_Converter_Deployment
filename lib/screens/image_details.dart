import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../utils/constant.dart';

class ImageDetails extends StatefulWidget {
  final File file;
  const ImageDetails({super.key, required this.file});

  @override
  State<ImageDetails> createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {
  @override
  Widget build(BuildContext context) {
    // get file size
    int fileSize = widget.file.lengthSync();
    double fileSizeInMB = fileSize / (1024 * 1024); // 1 MB = 1024 * 1024 bytes

    // get last modified date
    DateTime lastModified = widget.file.lastModifiedSync();

    // Get the file format (extension) from the file path
    String fileExtension = path.extension(widget.file.path);

    return SafeArea(
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
            "Details",
            style: kAppbarStyle,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xff262626),
            ),
            child: SingleChildScrollView(
              // Wrap the content in a SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "FilePath: ",
                            style: kPrefixStyle,
                          ),
                          TextSpan(
                            text: "${widget.file.path}\n",
                            style: kSuffixStyle,
                          ),
                          WidgetSpan(
                            child: SizedBox(height: 30), // Add vertical spacing
                          ),
                          TextSpan(
                            text: "File size: ",
                            style: kPrefixStyle,
                          ),
                          TextSpan(
                            text: "$fileSizeInMB MB\n",
                            style: kSuffixStyle,
                          ),
                          WidgetSpan(
                            child: SizedBox(height: 30), // Add vertical spacing
                          ),
                          TextSpan(
                            text: "Last modified: ",
                            style: kPrefixStyle,
                          ),
                          TextSpan(
                            text: "$lastModified\n",
                            style: kSuffixStyle,
                          ),
                          WidgetSpan(
                            child: SizedBox(height: 30), // Add vertical spacing
                          ),
                          TextSpan(
                            text: "File Extension: ",
                            style: kPrefixStyle,
                          ),
                          TextSpan(
                            text: "$fileExtension",
                            style: kSuffixStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

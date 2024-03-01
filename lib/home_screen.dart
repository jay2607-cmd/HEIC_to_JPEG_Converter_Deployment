import 'package:flutter/material.dart';
import 'package:heic_converter/screens/bookmarked_images.dart';
import 'package:heic_converter/screens/heic_to_jpg.dart';
import 'package:heic_converter/screens/history_screen.dart';
import 'package:heic_converter/screens/multi_heic_converter.dart';
import 'package:heic_converter/screens/reverse_converter.dart';

import 'info.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                                  builder: (context) => HistoryScreen(isFromHEICTOJPG: false,)),
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
      ),
    );
  }
}

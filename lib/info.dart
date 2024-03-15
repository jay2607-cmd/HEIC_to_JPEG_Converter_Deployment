import 'package:flutter/material.dart';
import 'package:heic_converter/user_consent.dart';
import 'package:heic_converter/utils/constant.dart';
import 'package:heic_converter/webview.dart';
import 'package:share_plus/share_plus.dart';

import 'package:url_launcher/url_launcher.dart';

import 'license_credit.dart';


class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  var toLaunch;

  _launchURLInApp(BuildContext context) {
    const url = kPrivacyPolicy;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    toLaunch = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.expressway.noisedetector.sm&pli=1');

    Future<void>? _launched;
    Future<void> _launchInBrowser(Uri url) async {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ListTile(
              title: Text("Version Name"),
              subtitle: Text("1.0"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserConsent()));
              },
              child: ListTile(
                title: Text(
                  "User Consent",
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserConsent()));
                  },
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Share.share(
                    "https://play.google.com/store/apps/details?id=com.example.heic_converter.sm&pli=1");
              },
              child: ListTile(
                title: Text("Share App"),
                trailing: IconButton(
                  onPressed: () {
                    Share.share(
                        "https://play.google.com/store/apps/details?id=com.example.heic_converter.sm&pli=1");
                  },
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _launched = _launchInBrowser(toLaunch);
                });
              },
              child: ListTile(
                title: Text("Rate Us"),
                trailing: IconButton(
                  onPressed: () => (setState(() {
                    _launched = _launchInBrowser(toLaunch);
                  })),
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _launchURLInApp(context);

              },
              child: ListTile(
                title: Text(
                  "Privacy & Policy",
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LicenseAndCredit()));
              },
              child: ListTile(
                title: Text("License and Credit"),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LicenseAndCredit()));
                  },
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
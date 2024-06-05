import 'package:flutter/material.dart';
import 'package:heic_converter/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserConsent extends StatelessWidget {
  const UserConsent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
                "We care about your privacy & data security. We keep this app free by showing ads."),
            SizedBox(
              height: 20,
            ),
            Text(
                "With your permission at launch time we are showing tailor ads to you."),
            SizedBox(
              height: 20,
            ),
            Text(
                "If you want to change setting of your consent, please click below 'Deactivate' button"),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff724BE5), // Set background color
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Add border radius
                  ),
                ),
                onPressed: () async {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Splash()));

                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setBool("isPersonalised", false);
                },
                child: Text("Deactive"))
          ],
        ),
      ),
    ));
  }
}

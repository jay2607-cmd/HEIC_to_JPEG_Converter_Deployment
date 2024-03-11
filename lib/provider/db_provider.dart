import 'package:shared_preferences/shared_preferences.dart';

class DbProvider {
  final Future<SharedPreferences> _showAds =
      SharedPreferences.getInstance();

  // for authentication setting
  void saveShowAdsState(bool status) async {
    final instance = await _showAds;

    instance.setBool("status", status);
  }

  // for authentication setting
  Future<bool> getShowAdsState() async {
    final instance = await _showAds;
    if (instance.containsKey("status")) {
      final value = instance.getBool("status");

      return value!;
    } else {
      return true;
    }
  }


}

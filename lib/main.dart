import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:heic_converter/providers/heic_to_jpg_provider.dart';
import 'package:heic_converter/screens/splash.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/bookmark.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.initFlutter();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  if(preferences.getBool("isPersonalised") == null) {
    preferences.setBool("isPersonalised", false);
  }

  await MobileAds.instance.initialize();

  Hive.registerAdapter(BookmarkAdapter());

  await Hive.openBox<Bookmark>("bookmark");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget with WidgetsBindingObserver{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HeicToJpgProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        title: 'HEIF Converter',
        home: const Splash(),
      ),
    );
  }
}

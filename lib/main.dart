import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tzoker_generator/helpers/utils.dart';
import 'package:tzoker_generator/screens/all_time_stats.dart';
import 'package:tzoker_generator/screens/generate_numbers.dart';
import 'package:tzoker_generator/screens/landing_page.dart';
import 'package:tzoker_generator/screens/number_stats.dart';
import 'package:tzoker_generator/screens/search.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  Utils.version = packageInfo.version;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.white),
    );
    return GetMaterialApp(
      title: 'Tzoker Generator',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const LandingPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/generate',
          page: () => const GenerateNumbersScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/stats',
          page: () => const AllTimeStats(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/numberStats',
          page: () => const NumberStatsScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/search',
          page: () => const SearchScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}

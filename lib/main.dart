import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tzoker_generator/screens/landing_page.dart';
import 'package:tzoker_generator/screens/statistics.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tzoker Generator',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const LandingPage(),
        ),
        GetPage(
          name: '/stats',
          page: () => const StatsScreen(),
        ),
      ],
    );
  }
}

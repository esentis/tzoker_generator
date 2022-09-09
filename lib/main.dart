import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tzoker_generator/screens/all_time_stats.dart';
import 'package:tzoker_generator/screens/generate_numbers.dart';
import 'package:tzoker_generator/screens/landing_page.dart';
import 'package:tzoker_generator/screens/number_stats.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();
  await Supabase.initialize(
    url: 'https://qvliopsxcffejpcxxmfb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2bGlvcHN4Y2ZmZWpwY3h4bWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjAzMjk3MzksImV4cCI6MTk3NTkwNTczOX0.OshaOvSwzZ2Fgtj9kAqL_COmgTfBlnGHmV43EAyDja4',
    // authCallbackUrlHostname: 'login-callback', // optional
    debug: true // optional
    ,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
    );
  }
}

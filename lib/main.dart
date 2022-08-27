import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tzoker_generator/screens/landing_page.dart';
import 'package:tzoker_generator/screens/statistics.dart';

Future<void> main() async {
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

import 'package:flutter/material.dart';
import 'package:tzoker_generator/landing_page.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tzoker Generator',
      home: LandingPage(title: 'Flutter Demo Home Page'),
    );
  }
}

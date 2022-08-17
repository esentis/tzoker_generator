import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Hero(
          tag: 'logo',
          child: Image.asset(
            'assets/tzoker_generator.png',
          ),
        ),
      ),
    );
  }
}

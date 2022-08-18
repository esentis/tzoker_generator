import 'package:flutter/material.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';

class GenerateTzokerScreen extends StatefulWidget {
  const GenerateTzokerScreen({Key? key}) : super(key: key);

  @override
  State<GenerateTzokerScreen> createState() => _GenerateTzokerScreenState();
}

class _GenerateTzokerScreenState extends State<GenerateTzokerScreen> {
  Statistics? stats;

  @override
  void initState() {
    super.initState();
    getStats();
  }

  Future<void> getStats() async {
    stats = await Tzoker.instance.getStatistics();
    kLog.wtf(stats?.toJson());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

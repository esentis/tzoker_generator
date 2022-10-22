import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/helpers/assets.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_stats.dart';

class AllTimeStats extends StatefulWidget {
  const AllTimeStats({super.key});

  @override
  State<AllTimeStats> createState() => _AllTimeStatsState();
}

class _AllTimeStatsState extends State<AllTimeStats> {
  Statistics? stats;
  bool isLoading = true;

  Future<void> _getStats() async {
    setState(() {
      isLoading = true;
    });
    stats = await Tzoker.instance.getStatistics();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Get.currentRoute != '/'
            ? IconButton(
                color: Colors.black,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 45,
                ),
                onPressed: () => Get.offAllNamed('/'),
              )
            : null,
        flexibleSpace: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Get.offAllNamed('/'),
            child: Hero(
              tag: 'logo',
              child: Image.asset(
                Assets.logo,
              ),
            ),
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset(
                Assets.loading,
              ),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15.0,
                        right: 5,
                      ),
                      child: TzokerStats(
                        numbers: stats!.numbers,
                        drawCount: stats!.header.drawCount,
                        title: 'Numbers',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 15.0,
                        left: 5,
                      ),
                      child: TzokerStats(
                        numbers: stats!.bonusNumbers,
                        drawCount: stats!.header.drawCount,
                        title: 'Tzokers',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

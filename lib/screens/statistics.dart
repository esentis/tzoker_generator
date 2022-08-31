import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/generated_numbers.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';
import 'package:tzoker_generator/widgets/tzoker_stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenScreenState();
}

class _StatsScreenScreenState extends State<StatsScreen> {
  Statistics? stats;
  bool loading = true;

  Iterable<Number>? highDelayedNumbers;

  Iterable<Number>? mediumDelayedNumbers;

  Iterable<Number>? smallDelayedNumbers;

  Iterable<Number>? almostNotDelayedNumbers;

  Iterable<Number>? highDelayedTzokers;

  Iterable<Number>? mediumDelayedTzokers;

  Iterable<Number>? smallDelayedTzokers;

  Iterable<Number>? almostNotDelayedTzokers;

  GeneratedNumbers? generatedNumbers;

  @override
  void initState() {
    super.initState();
    getStats();
  }

  Future<void> getStats() async {
    if (loading == false) {
      setState(() {
        loading = true;
      });
    }
    stats = await Tzoker.instance.getStatistics();

    await Tzoker.instance.updateStats(stats!.header.drawCount, stats!.toJson());

    highDelayedNumbers = stats?.numbers.where(((n) => n.delays > 20));

    mediumDelayedNumbers =
        stats?.numbers.where(((n) => (n.delays <= 20) && (n.delays > 10)));

    smallDelayedNumbers =
        stats?.numbers.where(((n) => (n.delays <= 10) && (n.delays > 4)));

    almostNotDelayedNumbers =
        stats?.numbers.where(((n) => (n.delays <= 4) && (n.delays > 0)));

    highDelayedTzokers = stats?.bonusNumbers.where(((n) => n.delays >= 10));

    mediumDelayedTzokers =
        stats?.bonusNumbers.where(((n) => (n.delays <= 20) && (n.delays > 10)));

    smallDelayedTzokers =
        stats?.bonusNumbers.where(((n) => (n.delays <= 10) && (n.delays > 4)));

    almostNotDelayedTzokers =
        stats?.bonusNumbers.where(((n) => (n.delays <= 4) && (n.delays > 0)));

    setState(() {
      loading = false;
    });
  }

  void _generatedNumbers() {
    List<Number> numbers = [];

    int randomHighDelay = 0;
    int randomMediumDelay = 0;
    int randomSmallDelay = 0;
    int randomNoDelay = 0;

    while (numbers.length < 5) {
      randomHighDelay = Random().nextInt(highDelayedNumbers!.length);
      randomMediumDelay = Random().nextInt(mediumDelayedNumbers!.length);
      randomSmallDelay = Random().nextInt(smallDelayedNumbers!.length);
      randomNoDelay = Random().nextInt(almostNotDelayedNumbers!.length);

      if (!numbers.contains(highDelayedNumbers!.toList()[randomHighDelay])) {
        numbers.add(highDelayedNumbers!.toList()[randomHighDelay]);
        if (numbers.length == 5) break;
      }

      if (!numbers
          .contains(mediumDelayedNumbers!.toList()[randomMediumDelay])) {
        numbers.add(mediumDelayedNumbers!.toList()[randomMediumDelay]);
        if (numbers.length == 5) break;
      }

      if (!numbers.contains(smallDelayedNumbers!.toList()[randomSmallDelay])) {
        numbers.add(smallDelayedNumbers!.toList()[randomSmallDelay]);
        if (numbers.length == 5) break;
      }

      if (!numbers.contains(almostNotDelayedNumbers!.toList()[randomNoDelay])) {
        numbers.add(almostNotDelayedNumbers!.toList()[randomNoDelay]);
        if (numbers.length == 5) break;
      }
    }

    generatedNumbers = GeneratedNumbers(
      numbers: numbers,
      tzoker: highDelayedTzokers!
          .toList()[Random().nextInt(highDelayedTzokers!.length)],
    );

    kLog.wtf(generatedNumbers?.toJson());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: const SizedBox(),
        backgroundColor: Colors.white,
        toolbarHeight: 0,
      ),
      body: loading
          ? Center(
              child: Lottie.asset(
                'assets/tzoker.json',
              ),
            )
          : ListView(
              children: [
                const SizedBox(
                  height: 10,
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Get.offAllNamed('/'),
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/tzoker_generator.png',
                        height: 100,
                      ),
                    ),
                  ),
                ),
                if (!loading) ...[
                  SizedBox(
                    height: 100,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Total draws ${stats?.header.drawCount}',
                          style: kStyleDefault,
                        ),
                        Text(
                          '${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(stats!.header.dateFrom * 1000))} - ${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(stats!.header.dateTo * 1000))}',
                          style: kStyleDefault,
                        ),
                      ],
                    ),
                  )
                ],
                SizedBox(
                  height: 80,
                  child: Center(
                    child: Wrap(
                      children: [
                        if (generatedNumbers != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 6.0,
                              top: 12,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xfff8b828),
                              ),
                              child: TzokerBall(
                                color: Tzoker.instance
                                    .getColor(generatedNumbers!.tzoker.number),
                                number: generatedNumbers!.tzoker.number,
                                isLoading: false,
                              ),
                            ),
                          ),
                          ...generatedNumbers!.numbers.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(
                                right: 6.0,
                                top: 12,
                              ),
                              child: TzokerBall(
                                height: 60,
                                width: 60,
                                color: Tzoker.instance.getColor(e.number),
                                number: e.number,
                                isLoading: false,
                              ),
                            ),
                          ),
                        ] else
                          SizedBox(
                            height: 70,
                            child: Text(
                              'Generate numbers & tzoker based on highest delays',
                              textAlign: TextAlign.center,
                              style: kStyleDefault.copyWith(
                                fontSize: 20,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        _generatedNumbers();
                      },
                      child: Text(
                        'Generate',
                        style: kStyleDefault,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 350,
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
              ],
            ),
    );
  }
}

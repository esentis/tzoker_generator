import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/helpers/assets.dart';
import 'package:tzoker_generator/models/generated_numbers.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/numbers_shortcut.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class GenerateNumbersScreen extends StatefulWidget {
  const GenerateNumbersScreen({super.key});

  @override
  State<GenerateNumbersScreen> createState() => _StatsScreenScreenState();
}

class _StatsScreenScreenState extends State<GenerateNumbersScreen> {
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
    setState(() {
      loading = false;
    });

    highDelayedNumbers = stats?.numbers.where((n) => n.delays > 20);

    mediumDelayedNumbers =
        stats?.numbers.where((n) => (n.delays <= 20) && (n.delays > 10));

    almostNotDelayedNumbers =
        stats?.numbers.where((n) => (n.delays <= 4) && (n.delays > 0));

    highDelayedTzokers = stats?.bonusNumbers.where((n) => n.delays >= 10);

    mediumDelayedTzokers =
        stats?.bonusNumbers.where((n) => (n.delays <= 20) && (n.delays > 10));

    smallDelayedTzokers =
        stats?.bonusNumbers.where((n) => (n.delays <= 10) && (n.delays > 5));

    almostNotDelayedTzokers =
        stats?.bonusNumbers.where((n) => (n.delays <= 5) && (n.delays > 0));
  }

  void _generateNumbers() {
    final List<Number> numbers = [];

    int randomHighDelay = 0;
    int randomMediumDelay = 0;

    int randomNoDelay = 0;

    while (numbers.length < 5) {
      randomHighDelay = Random().nextInt(highDelayedNumbers!.length);

      randomMediumDelay = Random().nextInt(mediumDelayedNumbers!.length);

      randomNoDelay = Random().nextInt(almostNotDelayedNumbers!.length);

      if (!numbers.contains(almostNotDelayedNumbers!.toList()[randomNoDelay])) {
        if (!numbers
            .contains(almostNotDelayedNumbers!.toList()[randomNoDelay])) {
          numbers.add(almostNotDelayedNumbers!.toList()[randomNoDelay]);
        }
        if (numbers.length == 5) break;
      }

      if (almostNotDelayedNumbers?.isNotEmpty ?? false) {
        if (!numbers
            .contains(almostNotDelayedNumbers!.toList()[randomNoDelay])) {
          numbers.add(almostNotDelayedNumbers!.toList()[randomNoDelay]);
          if (numbers.length == 5) break;
        }
      }
      if (highDelayedNumbers?.isNotEmpty ?? false) {
        if (!numbers.contains(highDelayedNumbers!.toList()[randomHighDelay])) {
          numbers.add(highDelayedNumbers!.toList()[randomHighDelay]);
          if (numbers.length == 5) break;
        }
      }

      if (mediumDelayedNumbers?.isNotEmpty ?? false) {
        if (!numbers
            .contains(mediumDelayedNumbers!.toList()[randomMediumDelay])) {
          numbers.add(mediumDelayedNumbers!.toList()[randomMediumDelay]);
          if (numbers.length == 5) break;
        }
      }
    }

    generatedNumbers = GeneratedNumbers(
      numbers: numbers,
      tzoker: highDelayedTzokers!
          .toList()[Random().nextInt(highDelayedTzokers!.length)],
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NumbersShortcut(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: loading
              ? Center(
                  child: Lottie.asset(
                    Assets.loading,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    if (!loading) ...[
                      SliverAppBar(
                        leading: Get.currentRoute != '/'
                            ? IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: Get.back,
                                color: Colors.black,
                              )
                            : null,
                        flexibleSpace: Center(
                          child: MouseRegion(
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
                        ),
                        toolbarHeight: 100,
                        backgroundColor: Colors.white,
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
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
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: SizedBox(
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
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xfff8b828),
                                    ),
                                    child: TzokerBall(
                                      color: Tzoker.instance.getColor(
                                        generatedNumbers!.tzoker.number,
                                      ),
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
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.only(top: 50),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 50,
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              _generateNumbers();
                            },
                            child: Text(
                              'Generate',
                              style: kStyleDefault.copyWith(
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

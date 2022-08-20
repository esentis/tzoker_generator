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

    highDelayedNumbers = stats?.numbers.where(((n) => n.delays > 20));

    mediumDelayedNumbers =
        stats?.numbers.where(((n) => (n.delays <= 20) && (n.delays > 10)));

    smallDelayedNumbers =
        stats?.numbers.where(((n) => (n.delays <= 10) && (n.delays > 4)));

    almostNotDelayedNumbers =
        stats?.numbers.where(((n) => (n.delays <= 4) && (n.delays > 0)));

    highDelayedTzokers = stats?.bonusNumbers.where(((n) => n.delays > 20));

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
        flexibleSpace: Column(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Get.offAllNamed('/'),
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/tzoker_generator.png',
                  ),
                ),
              ),
            ),
            if (!loading) ...[
              const SizedBox(
                height: 15,
              ),
              Text(
                'Total draws ${stats?.header.drawCount}',
                style: kStyleDefault,
              ),
              Text(
                '${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(stats!.header.dateFrom * 1000))} - ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
                style: kStyleDefault,
              )
            ],
          ],
        ),
        toolbarHeight: loading ? 150 : 250,
        backgroundColor: Colors.white,
      ),
      body: loading
          ? Center(
              child: Lottie.asset(
                'assets/tzoker.json',
              ),
            )
          : Column(
              children: [
                Container(
                  height: 170,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Wrap(
                          children: [
                            if (generatedNumbers != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 30.0,
                                  top: 12,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    color: const Color(0xfff8b828),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TzokerBall(
                                    color: Tzoker.instance.getColor(
                                        generatedNumbers!.tzoker.number),
                                    number: generatedNumbers!.tzoker.number,
                                  ),
                                ),
                              ),
                              ...generatedNumbers!.numbers.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(
                                    right: 6.0,
                                    top: 12,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TzokerBall(
                                      color: Tzoker.instance.getColor(e.number),
                                      number: e.number,
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              SizedBox(
                                height: 70,
                                child: Text(
                                  'Generate numbers & tzoker based on highest delays',
                                  style: kStyleDefault.copyWith(
                                    fontSize: 25,
                                    fontFamily: 'Arial',
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            _generatedNumbers();
                          },
                          child: Text(
                            'Generate',
                            style: kStyleDefault,
                          )),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          controller: ScrollController(),
                          slivers: [
                            SliverAppBar(
                              leading: const SizedBox(),
                              backgroundColor: const Color(0xff3c5c8f),
                              title: Text(
                                'Numbers',
                                style: kStyleDefault,
                              ),
                              centerTitle: true,
                              pinned: true,
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => DecoratedBox(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: ListTile(
                                    tileColor: Tzoker.instance
                                        .getColorOccurence(
                                            stats!.numbers[i].delays),
                                    leading: TzokerBall(
                                      color: Tzoker.instance.getColor(i + 1),
                                      number: i + 1,
                                    ),
                                    title: Text(
                                      'Delays ${stats?.numbers[i].delays}',
                                      style: kStyleDefault,
                                    ),
                                    subtitle: Text(
                                      'Occurences ${stats?.numbers[i].occurrences}\nPercentage ${((stats!.numbers[i].occurrences * 100) / stats!.header.drawCount).toStringAsFixed(2)}%',
                                      style: kStyleDefault,
                                    ),
                                  ),
                                ),
                                childCount: stats?.numbers.length,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                            controller: ScrollController(),
                            slivers: [
                              SliverAppBar(
                                leading: const SizedBox(),
                                backgroundColor: const Color(0xff3c5c8f),
                                title: Text(
                                  'Tzokers',
                                  style: kStyleDefault,
                                ),
                                centerTitle: true,
                                pinned: true,
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) => DecoratedBox(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: ListTile(
                                      tileColor: Tzoker.instance
                                          .getColorOccurence(
                                              stats!.bonusNumbers[i].delays),
                                      leading: TzokerBall(
                                        color: Tzoker.instance.getColor(i + 1),
                                        number: i + 1,
                                      ),
                                      title: Text(
                                        'Delays ${stats?.bonusNumbers[i].delays}',
                                        style: kStyleDefault,
                                      ),
                                      subtitle: Text(
                                        'Occurences ${stats?.bonusNumbers[i].occurrences}\nPercentage ${((stats!.bonusNumbers[i].occurrences * 100) / stats!.header.drawCount).toStringAsFixed(2)}%',
                                        style: kStyleDefault,
                                      ),
                                    ),
                                  ),
                                  childCount: stats?.bonusNumbers.length,
                                ),
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

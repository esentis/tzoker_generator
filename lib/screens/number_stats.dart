import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class NumberDelayStat {
  final DateTime from;
  final DateTime to;
  final int fromDrawCount;
  final int toDrawCount;
  final int delay;

  NumberDelayStat({
    required this.from,
    required this.to,
    required this.fromDrawCount,
    required this.toDrawCount,
    required this.delay,
  });
}

class NumberStatsScreen extends StatefulWidget {
  const NumberStatsScreen({Key? key}) : super(key: key);

  @override
  State<NumberStatsScreen> createState() => _NumberStatsScreenState();
}

class _NumberStatsScreenState extends State<NumberStatsScreen> {
  /// The current number that we are looking for its stats.
  late int checkingNumber;
  List<DrawResult> drawsAsNumberResponse = [];
  List<DrawResult> drawsAsTzokerResponse = [];

  bool loading = true;

  int leastCommonNumberCountAsNumber = 0;
  int mostCommonNumberCountAsNumber = 0;
  int leastCommonNumberAsNumber = 0;
  int mostCommonNumberAsNumber = 0;

  int leastCommonNumberCountAsTzoker = 0;
  int mostCommonNumberCountAsTzoker = 0;
  int leastCommonNumberAsTzoker = 0;
  int mostCommonNumberAsTzoker = 0;

  Statistics? stats;

  Map<int, int> allNumberOccurencesAsNumber = {};
  Map<int, int> allNumberOccurencesAsTzoker = {};

// TODO: Finished delay stats to get longest and shortest occurences
  void getLongestAndShortestDelays(List<DrawResult> draws) {
    List<NumberDelayStat> drawDelays = [];

    for (int i = 0; i < draws.length - 1; i++) {
      drawDelays.add(
        NumberDelayStat(
          from: draws[i].date,
          to: draws[i + 1].date,
          fromDrawCount: draws[i].drawCount,
          toDrawCount: draws[i + 1].drawCount,
          delay: draws[i + 1].drawCount - draws[i].drawCount,
        ),
      );
    }

    /// Least delays
    kLog.wtf(drawDelays.fold(drawDelays.first.delay, (previousValue, element) {
      if ((previousValue as int? ?? 0) < element.delay) {
        return previousValue;
      } else {
        return element.delay;
      }
    }));

    /// Max delays
    kLog.wtf(drawDelays.fold(drawDelays.first.delay, (previousValue, element) {
      if ((previousValue as int? ?? 0) > element.delay) {
        return previousValue;
      } else {
        return element.delay;
      }
    }));
  }

  Future<void> getNumberStats() async {
    allNumberOccurencesAsNumber = {};
    allNumberOccurencesAsTzoker = {};

    final res = await Future.wait([
      Tzoker.instance.getDrawsOfSpecificSequence(nums: [checkingNumber]),
      Tzoker.instance.getStatistics(),
      if (checkingNumber <= 20)
        Tzoker.instance.getDrawsOfSpecificSequence(tzoker: checkingNumber),
    ]);

    drawsAsNumberResponse = res[0] as List<DrawResult>;

    stats = res[1] as Statistics;

//  Generating stats for number when it appears as a number ----------------------------------------
    List<int> allDrawNumbersAsNumber = [];
    getLongestAndShortestDelays(drawsAsNumberResponse);
    for (final DrawResult draw in drawsAsNumberResponse) {
      allDrawNumbersAsNumber
          .addAll(draw.winningNumbers.where((n) => n != checkingNumber));
    }

    for (final int num in allDrawNumbersAsNumber) {
      if (allNumberOccurencesAsNumber[num] == null) {
        allNumberOccurencesAsNumber[num] = 1;
      } else {
        allNumberOccurencesAsNumber[num] =
            allNumberOccurencesAsNumber[num]! + 1;
      }
    }
    // Biggest occurence
    mostCommonNumberCountAsNumber = 0;

    allNumberOccurencesAsNumber.values.fold<int>(0, (previousValue, element) {
      if (mostCommonNumberCountAsNumber <= element) {
        mostCommonNumberCountAsNumber = element;
      }
      return mostCommonNumberCountAsNumber;
    });

    // Smallest occurence
    leastCommonNumberCountAsNumber = mostCommonNumberCountAsNumber;

    allNumberOccurencesAsNumber.values.fold<int>(0, (previousValue, element) {
      if (leastCommonNumberCountAsNumber >= element) {
        leastCommonNumberCountAsNumber = element;
      }
      return leastCommonNumberCountAsNumber;
    });
    mostCommonNumberAsNumber = allNumberOccurencesAsNumber
        .whereValue((v) => v == mostCommonNumberCountAsNumber)
        .keys
        .first;

    leastCommonNumberAsNumber = allNumberOccurencesAsNumber
        .whereValue((v) => v == leastCommonNumberCountAsNumber)
        .keys
        .first;
// -------------------------------------------------------------------------------------------------
    if (checkingNumber <= 20) {
      drawsAsTzokerResponse = res[2] as List<DrawResult>;
    }

    List<int> allDrawNumbersAsTzoker = [];

    if (drawsAsTzokerResponse.isNotEmpty) {
      for (final DrawResult draw in drawsAsTzokerResponse) {
        allDrawNumbersAsTzoker.addAll(draw.winningNumbers);
      }

      for (final int num in allDrawNumbersAsTzoker) {
        if (allNumberOccurencesAsTzoker[num] == null) {
          allNumberOccurencesAsTzoker[num] = 1;
        } else {
          allNumberOccurencesAsTzoker[num] =
              allNumberOccurencesAsTzoker[num]! + 1;
        }
      }
      // Biggest occurence
      mostCommonNumberCountAsTzoker = 0;

      allNumberOccurencesAsTzoker.values.fold<int>(0, (previousValue, element) {
        if (mostCommonNumberCountAsTzoker <= element) {
          mostCommonNumberCountAsTzoker = element;
        }
        return mostCommonNumberCountAsTzoker;
      });

      // Smallest occurence
      leastCommonNumberCountAsTzoker = mostCommonNumberCountAsTzoker;

      allNumberOccurencesAsTzoker.values.fold<int>(0, (previousValue, element) {
        if (leastCommonNumberCountAsTzoker >= element) {
          leastCommonNumberCountAsTzoker = element;
        }
        return leastCommonNumberCountAsTzoker;
      });
      mostCommonNumberAsTzoker = allNumberOccurencesAsTzoker
          .whereValue((v) => v == mostCommonNumberCountAsTzoker)
          .keys
          .first;

      leastCommonNumberAsTzoker = allNumberOccurencesAsTzoker
          .whereValue((v) => v == leastCommonNumberCountAsTzoker)
          .keys
          .first;
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkingNumber = int.parse(Get.parameters['number'] ?? '0');
    getNumberStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          ),
          SliverAppBar(
            leading: const SizedBox(),
            flexibleSpace: GestureDetector(
              onTap: () => Get.offAllNamed('/'),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/tzoker_generator.png',
                  ),
                ),
              ),
            ),
            toolbarHeight: 100,
            backgroundColor: Colors.white,
            primary: true,
          ),
          if (!loading)
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TzokerBall(
                    color: Tzoker.instance.getColor(checkingNumber),
                    height: 100,
                    width: 100,
                    number: checkingNumber,
                    isLoading: false,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (checkingNumber <= 20)
                        Text(
                          stats?.bonusNumbers
                                      .firstWhere(
                                          (n) => n.number == checkingNumber)
                                      .delays ==
                                  0
                              ? 'Appeared on last draw as Tzoker'
                              : 'As a Tzoker has ${stats?.bonusNumbers.firstWhere((n) => n.number == checkingNumber).delays} delays',
                          style: kStyleDefault,
                        ),
                      if (checkingNumber <= 20)
                        Text(
                          'Total appearence percentage ${((stats!.bonusNumbers.firstWhere((n) => n.number == checkingNumber).occurrences * 100) / (stats!.header.drawCount - 1)).toStringAsFixed(2)}% ',
                          style: kStyleDefault.copyWith(
                            fontSize: 16,
                            color: const Color(0xff8d0d46).withOpacity(0.6),
                          ),
                        ),
                      if (checkingNumber <= 20) ...[
                        Text(
                            'Appeared in ${drawsAsTzokerResponse.length} draws'),
                        Text(
                            'Most common number found together is $mostCommonNumberAsTzoker found in $mostCommonNumberCountAsTzoker  draws'),
                        Text(
                            'Least common number found together is $leastCommonNumberAsTzoker  found in $leastCommonNumberCountAsTzoker  draws'),
                        const SizedBox(
                          width: 350,
                          child: Divider(
                            color: Color(0xfff8b828),
                          ),
                        ),
                      ],
                      Text(
                        stats?.numbers
                                    .firstWhere(
                                        (n) => n.number == checkingNumber)
                                    .delays ==
                                0
                            ? 'Appeared on last draw as number'
                            : 'As a Number has ${stats?.numbers.firstWhere((n) => n.number == checkingNumber).delays} delays',
                        style: kStyleDefault,
                      ),
                      Text(
                        'Total appearence percentage ${((stats!.numbers.firstWhere((n) => n.number == checkingNumber).occurrences * 100) / (stats!.header.drawCount - 1)).toStringAsFixed(2)}% ',
                        style: kStyleDefault.copyWith(
                          fontSize: 16,
                          color: const Color(0xff8d0d46).withOpacity(0.6),
                        ),
                      ),
                      Text('Appeared in ${drawsAsNumberResponse.length} draws'),
                      Text(
                          'Most common number found together is $mostCommonNumberAsNumber found in $mostCommonNumberCountAsNumber draws'),
                      Text(
                          'Least common number found together is $leastCommonNumberAsNumber found in $leastCommonNumberCountAsNumber draws'),
                    ],
                  ),
                ],
              ),
            )
          else
            SliverFillRemaining(
              child: Lottie.asset(
                'assets/tzoker.json',
              ),
            )
        ],
      ),
    );
  }
}

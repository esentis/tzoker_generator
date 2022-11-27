import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/helpers/assets.dart';
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/stats_divider.dart';
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
  const NumberStatsScreen({super.key});

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

  List<NumberDelayStat> drawDelaysAsNumber = [];
  List<NumberDelayStat> drawDelaysAsTzoker = [];

  void getLongestAndShortestDelays({
    required List<DrawResult> drawsAsNumber,
    required List<DrawResult> drawsAsTzoker,
  }) {
    drawDelaysAsNumber = [];
    drawDelaysAsTzoker = [];

    final List<DrawResult> sortedDrawsAsNumber = drawsAsNumber
      ..sort(
        (a, b) => a.drawCount.compareTo(b.drawCount),
      );

    for (int i = 0; i < sortedDrawsAsNumber.length - 1; i++) {
      drawDelaysAsNumber.add(
        NumberDelayStat(
          from: sortedDrawsAsNumber[i].date,
          to: sortedDrawsAsNumber[i + 1].date,
          fromDrawCount: sortedDrawsAsNumber[i].drawCount,
          toDrawCount: sortedDrawsAsNumber[i + 1].drawCount,
          delay: sortedDrawsAsNumber[i + 1].drawCount -
              sortedDrawsAsNumber[i].drawCount,
        ),
      );
    }

    drawDelaysAsNumber.sort(
      (a, b) => a.delay.compareTo(b.delay),
    );

    kLog.wtf(drawDelaysAsNumber.map((e) => '${e.from}-${e.to}'));
    kLog.wtf(drawDelaysAsNumber.first.delay);
    kLog.wtf(drawDelaysAsNumber.last.delay);

    if (drawsAsTzoker.isNotEmpty) {
      final List<DrawResult> sortedDrawsAsTzoker = drawsAsTzoker
        ..sort(
          (a, b) => a.drawCount.compareTo(b.drawCount),
        );

      for (int i = 0; i < sortedDrawsAsTzoker.length - 1; i++) {
        drawDelaysAsTzoker.add(
          NumberDelayStat(
            from: sortedDrawsAsTzoker[i].date,
            to: sortedDrawsAsTzoker[i + 1].date,
            fromDrawCount: sortedDrawsAsTzoker[i].drawCount,
            toDrawCount: sortedDrawsAsTzoker[i + 1].drawCount,
            delay: sortedDrawsAsTzoker[i + 1].drawCount -
                sortedDrawsAsTzoker[i].drawCount,
          ),
        );
      }

      drawDelaysAsTzoker.sort(
        (a, b) => a.delay.compareTo(b.delay),
      );

      kLog.wtf(drawDelaysAsTzoker.map((e) => '${e.from}-${e.to}'));
      kLog.wtf(drawDelaysAsTzoker.first.delay);
      kLog.wtf(drawDelaysAsTzoker.last.delay);
    }
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
    final List<int> allDrawNumbersAsNumber = [];

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

    getLongestAndShortestDelays(
      drawsAsNumber: drawsAsNumberResponse,
      drawsAsTzoker: drawsAsTzokerResponse,
    );

    final List<int> allDrawNumbersAsTzoker = [];

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
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
              flexibleSpace: GestureDetector(
                onTap: () => Get.offAllNamed('/'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
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
            ),
            if (!loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
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
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StatsDivider(),
                            if (checkingNumber <= 20)
                              Text(
                                stats?.bonusNumbers
                                            .firstWhere(
                                              (n) => n.number == checkingNumber,
                                            )
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
                                  color: Colors.red,
                                ),
                              ),
                            if (checkingNumber <= 20) ...[
                              // Total appearances
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Appeared in ',
                                        style: kStyleDefault.copyWith(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${drawsAsTzokerResponse.length}',
                                        style: kStyleDefault.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' draws out of total ',
                                        style: kStyleDefault.copyWith(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${stats!.header.drawCount}',
                                        style: kStyleDefault.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const StatsDivider(),
                              // Total consecutive draws
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Total consecutive draws ',
                                        style: kStyleDefault.copyWith(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${drawDelaysAsTzoker.where((d) => d.delay == 1).length}',
                                        style: kStyleDefault.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              ...drawDelaysAsTzoker
                                  .where((d) => d.delay == 1)
                                  .map(
                                    (e) => Text(
                                      '${DateFormat("dd-MM-yyyy").format(e.from)} - ${DateFormat("dd-MM-yyyy").format(e.to)}',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                              const StatsDivider(),
                              // Longest delay
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Longest delay was for ',
                                        style: kStyleDefault.copyWith(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${drawDelaysAsTzoker.last.delay}',
                                        style: kStyleDefault.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' draws',
                                        style: kStyleDefault.copyWith(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ...drawDelaysAsTzoker
                                  .where(
                                    (d) =>
                                        d.delay ==
                                        drawDelaysAsTzoker.last.delay,
                                  )
                                  .map(
                                    (e) => Text(
                                      '${DateFormat("dd-MM-yyyy").format(e.from)} - ${DateFormat("dd-MM-yyyy").format(e.to)}',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),

                              const StatsDivider(),
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          'Most common number found together is ',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$mostCommonNumberAsTzoker',
                                      style: kStyleDefault.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' found in ',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$mostCommonNumberCountAsTzoker',
                                      style: kStyleDefault.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' draws',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          'Least common number found together is ',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$leastCommonNumberAsTzoker',
                                      style: kStyleDefault.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' found in ',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$leastCommonNumberCountAsTzoker',
                                      style: kStyleDefault.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' draws',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const StatsDivider(),
                            ],
                            Text(
                              stats?.numbers
                                          .firstWhere(
                                            (n) => n.number == checkingNumber,
                                          )
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
                                color: Colors.red,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Appeared in ',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${drawsAsNumberResponse.length}',
                                      style: kStyleDefault.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' draws out of total ',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${stats!.header.drawCount}',
                                      style: kStyleDefault.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const StatsDivider(),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        'Most common number found together is ',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$mostCommonNumberAsNumber',
                                    style: kStyleDefault.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' found in ',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$mostCommonNumberCountAsNumber',
                                    style: kStyleDefault.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' draws',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                            ),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        'Least common number found together is ',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$leastCommonNumberAsNumber',
                                    style: kStyleDefault.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' found in ',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$leastCommonNumberCountAsNumber',
                                    style: kStyleDefault.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' draws',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const StatsDivider(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverFillRemaining(
                child: Lottie.asset(
                  Assets.loading,
                ),
              )
          ],
        ),
      ),
    );
  }
}

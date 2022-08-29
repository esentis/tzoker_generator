import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/models/tzoker_response.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

Map<String, dynamic> tempStats = {
  "header": {"dateFrom": 946742400, "dateTo": 946742400, "drawCount": 0},
  "numbers": [
    {"occurrences": 0, "delays": 0, "number": 1},
    {"occurrences": 0, "delays": 0, "number": 2},
    {"occurrences": 0, "delays": 0, "number": 3},
    {"occurrences": 0, "delays": 0, "number": 4},
    {"occurrences": 0, "delays": 0, "number": 5},
    {"occurrences": 0, "delays": 0, "number": 6},
    {"occurrences": 0, "delays": 0, "number": 7},
    {"occurrences": 0, "delays": 0, "number": 8},
    {"occurrences": 0, "delays": 0, "number": 9},
    {"occurrences": 0, "delays": 0, "number": 10},
    {"occurrences": 0, "delays": 0, "number": 11},
    {"occurrences": 0, "delays": 0, "number": 12},
    {"occurrences": 0, "delays": 0, "number": 13},
    {"occurrences": 0, "delays": 0, "number": 14},
    {"occurrences": 0, "delays": 0, "number": 15},
    {"occurrences": 0, "delays": 0, "number": 16},
    {"occurrences": 0, "delays": 0, "number": 17},
    {"occurrences": 0, "delays": 0, "number": 18},
    {"occurrences": 0, "delays": 0, "number": 19},
    {"occurrences": 0, "delays": 0, "number": 20},
    {"occurrences": 0, "delays": 0, "number": 21},
    {"occurrences": 0, "delays": 0, "number": 22},
    {"occurrences": 0, "delays": 0, "number": 23},
    {"occurrences": 0, "delays": 0, "number": 24},
    {"occurrences": 0, "delays": 0, "number": 25},
    {"occurrences": 0, "delays": 0, "number": 26},
    {"occurrences": 0, "delays": 0, "number": 27},
    {"occurrences": 0, "delays": 0, "number": 28},
    {"occurrences": 0, "delays": 0, "number": 29},
    {"occurrences": 0, "delays": 0, "number": 30},
    {"occurrences": 0, "delays": 0, "number": 31},
    {"occurrences": 0, "delays": 0, "number": 32},
    {"occurrences": 0, "delays": 0, "number": 33},
    {"occurrences": 0, "delays": 0, "number": 34},
    {"occurrences": 0, "delays": 0, "number": 35},
    {"occurrences": 0, "delays": 0, "number": 36},
    {"occurrences": 0, "delays": 0, "number": 37},
    {"occurrences": 0, "delays": 0, "number": 38},
    {"occurrences": 0, "delays": 0, "number": 39},
    {"occurrences": 0, "delays": 0, "number": 40},
    {"occurrences": 0, "delays": 0, "number": 41},
    {"occurrences": 0, "delays": 0, "number": 42},
    {"occurrences": 0, "delays": 0, "number": 43},
    {"occurrences": 0, "delays": 0, "number": 44},
    {"occurrences": 0, "delays": 0, "number": 45}
  ],
  "bonusNumbers": [
    {"occurrences": 0, "delays": 0, "number": 1},
    {"occurrences": 0, "delays": 0, "number": 2},
    {"occurrences": 0, "delays": 0, "number": 3},
    {"occurrences": 0, "delays": 0, "number": 4},
    {"occurrences": 0, "delays": 0, "number": 5},
    {"occurrences": 0, "delays": 0, "number": 6},
    {"occurrences": 0, "delays": 0, "number": 7},
    {"occurrences": 0, "delays": 0, "number": 8},
    {"occurrences": 0, "delays": 0, "number": 9},
    {"occurrences": 0, "delays": 0, "number": 10},
    {"occurrences": 0, "delays": 0, "number": 11},
    {"occurrences": 0, "delays": 0, "number": 12},
    {"occurrences": 0, "delays": 0, "number": 13},
    {"occurrences": 0, "delays": 0, "number": 14},
    {"occurrences": 0, "delays": 0, "number": 15},
    {"occurrences": 0, "delays": 0, "number": 16},
    {"occurrences": 0, "delays": 0, "number": 17},
    {"occurrences": 0, "delays": 0, "number": 18},
    {"occurrences": 0, "delays": 0, "number": 19},
    {"occurrences": 0, "delays": 0, "number": 20}
  ]
};

Statistics tempStatsModel = Statistics.fromJson(tempStats);

class LandingPage extends StatefulWidget {
  const LandingPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int draws = 0;

  double loadingPercentage = 0;
  double currentJackpot = 0;

  bool _loading = true;

  DateTime? latestDraw;
  DateTime? nextDraw;

  LastResult? lastResult;

  Statistics? latestResultStatistics;

  Future<List<Map<int, int>>> getResults() async {
    Map<int, int> numberOccurences = {};
    Map<int, int> tzokerOccurences = {};

    DateTime from = DateTime.now();
    DateTime to = from.subtract(const Duration(days: 30));

    int months = 12;

    for (int i = 0; i <= months; i++) {
      final resp = await Tzoker.instance.getDrawsInRange(
          DateFormat("yyyy-MM-dd").format(to),
          DateFormat("yyyy-MM-dd").format(from));

      if (resp != null) {
        draws += resp.draws.length;

        for (Draw draw in resp.draws) {
          // Increment the tzoker occurence
          tzokerOccurences[draw.winningNumbers.tzoker.first] =
              (tzokerOccurences[draw.winningNumbers.tzoker.first] ?? 0) + 1;

          for (int num in draw.winningNumbers.numbers) {
            // Increment the number occurence
            numberOccurences[num] = (numberOccurences[num] ?? 0) + 1;
          }
        }
      }

      from = to;
      to = to.subtract(const Duration(days: 30));
      latestDraw = to;
      setState(() {
        loadingPercentage = (i / months) * 100;
      });
    }
    loadingPercentage = 0;

    return [numberOccurences, tzokerOccurences];
  }

  Future<void> _prepareLandingPage() async {
    kLog.i('Preparing landing page');
    final res = await Tzoker.instance.getJackpot();

    // await Tzoker.instance.getSpecificStat();

    lastResult = await Tzoker.instance.getLastResult();
    latestResultStatistics = await Tzoker.instance
        .getStatsForDrawCount((lastResult?.drawCount ?? 0) - 1);

    nextDraw = await Tzoker.instance.getUpcomingDrawDate();

    currentJackpot = res;
    setState(() {
      _loading = false;
    });
  }

  // Future<void> updateDatabase() async {
  //   tempStats = await Tzoker.instance
  //       .getStatsForDrawCount(2043)
  //       .then((value) => value.toJson());
  //   for (int i = 2043; i <= 2483; i++) {
  //     final draw = await Tzoker.instance.getDraw(i);

  //     for (Map<String, dynamic> stat in tempStats['numbers']) {
  //       if (draw.winningNumbers.numbers.contains(stat['number'])) {
  //         stat['occurrences']++;
  //         stat['delays'] = 0;
  //       } else {
  //         stat['delays']++;
  //       }
  //     }

  //     for (Map<String, dynamic> stat in tempStats['bonusNumbers']) {
  //       if (draw.winningNumbers.tzoker.contains(stat['number'])) {
  //         stat['occurrences']++;
  //         stat['delays'] = 0;
  //       } else {
  //         stat['delays']++;
  //       }
  //     }

  //     tempStats['header']['dateTo'] =
  //         draw.drawDate.millisecondsSinceEpoch / 1000;

  //     tempStats['header']['drawCount'] = i;

  //     await Tzoker.instance.updateStats(i, tempStats);
  //   }

  //   kLog.wtf(tempStats);
  // }

  @override
  void initState() {
    super.initState();

    _prepareLandingPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          ),
          SliverAppBar(
            flexibleSpace: Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/tzoker_generator.png',
              ),
            ),
            toolbarHeight: 100,
            backgroundColor: Colors.white,
            primary: true,
          ),
          if (_loading)
            SliverFillRemaining(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/tzoker.json',
                  ),
                  if (loadingPercentage != 0)
                    Text(
                      '${loadingPercentage.toStringAsFixed(0)}%',
                      style: kStyleDefault,
                    )
                ],
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: TextButton(
                    onPressed: () => Get.toNamed('stats'),
                    child: Text(
                      'Generate tzoker',
                      style: kStyleDefault,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Επομένη κλήρωση ${DateFormat("dd MMMM yyyy, HH:ss").format(nextDraw!)}',
                      style: kStyleDefault.copyWith(
                        fontFamily: 'Arial',
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SlideCountdown(
                      decoration: BoxDecoration(
                        color: const Color(0xfff8b828),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: nextDraw!.difference(DateTime.now()),
                      separatorType: SeparatorType.title,
                      textStyle: kStyleDefault.copyWith(
                        color: const Color(0xff3c5c8f),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      children: [
                        Text(
                          'Jackpot',
                          style: kStyleDefault.copyWith(fontSize: 25),
                        ),
                        if (currentJackpot == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              'New draw soon...!',
                              style: kStyleDefault.copyWith(
                                fontFamily: 'Arial',
                                fontSize: 25,
                              ),
                            ),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '€',
                                style: kStyleDefault.copyWith(
                                  fontSize: 70,
                                ),
                              ),
                              Text(
                                NumberFormat(
                                  "###,###.###",
                                ).format(currentJackpot),
                                style: kStyleDefault.copyWith(
                                  fontSize: 70,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 3),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Latest Draw',
                      style: kStyleDefault.copyWith(
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      DateFormat("dd MMMM yyyy, HH:ss")
                          .format(lastResult!.date),
                      style: kStyleDefault.copyWith(
                        fontSize: 18,
                        fontFamily: 'Arial',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 6.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xfff8b828),
                              shape: BoxShape.circle,
                            ),
                            child: TzokerBall(
                              color:
                                  Tzoker.instance.getColor(lastResult!.tzoker),
                              height: 50,
                              width: 50,
                              number: lastResult!.tzoker,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          //
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appeared after ${latestResultStatistics?.bonusNumbers.firstWhere((n) => n.number == lastResult!.tzoker).delays} delays',
                                style: kStyleDefault,
                              ),
                              Text(
                                'Had ${((latestResultStatistics!.bonusNumbers.firstWhere((n) => n.number == lastResult!.tzoker).occurrences * 100) / (lastResult!.drawCount - 1)).toStringAsFixed(2)}% total appearence chance',
                                style: kStyleDefault.copyWith(
                                  fontSize: 16,
                                  color:
                                      const Color(0xff3b6250).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ...lastResult!.sortedWinningNumbers.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(
                          top: 6.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TzokerBall(
                              color: Tzoker.instance.getColor(e),
                              height: 50,
                              width: 50,
                              number: e,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appeared after ${latestResultStatistics?.numbers.firstWhere((n) => n.number == e).delays} delays',
                                  style: kStyleDefault,
                                ),
                                Text(
                                  'Had ${((latestResultStatistics!.numbers.firstWhere((n) => n.number == e).occurrences * 100) / (lastResult!.drawCount - 1)).toStringAsFixed(2)}% total appearence chance',
                                  style: kStyleDefault.copyWith(
                                    fontSize: 16,
                                    color: const Color(0xff3b6250)
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

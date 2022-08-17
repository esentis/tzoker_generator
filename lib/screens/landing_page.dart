import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/models/tzoker_response.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Map<int, int> numberOccurences = {};
  Map<int, int> tzokerOccurences = {};

  int draws = 0;

  double loadingPercentage = 0;
  double currentJackpot = 0;

  bool _loading = true;

  DateTime? latestDraw;
  DateTime? nextDraw;

  LastResult? lastResult;

  void getResults() async {
    setState(() {
      _loading = true;
    });
    numberOccurences = {};
    tzokerOccurences = {};

    DateTime from = DateTime.now();
    DateTime to = DateTime.now().subtract(const Duration(days: 30));

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

    setState(() {
      _loading = false;
      loadingPercentage = 0;
    });
  }

  Color getColor(int num) {
    if (num >= 1 && num <= 10) {
      return const Color(0xff344ed6);
    }
    if (num > 10 && num <= 20) {
      return const Color(0xff8d0d46);
    }
    if (num >= 21 && num <= 30) {
      return const Color(0xffb9d4ef);
    }
    if (num >= 31 && num <= 40) {
      return const Color(0xffc0e051);
    }
    if (num >= 41 && num <= 45) {
      return const Color(0xff3b6250);
    }
    return Colors.red;
  }

  Future<void> _prepareLandingPage() async {
    kLog.i('Preparing landing page');
    final res = await Tzoker.instance.getJackpot();

    lastResult = await Tzoker.instance.getLastResult();
    nextDraw = await Tzoker.instance.getUpcomingDrawDate();

    final stats = await Tzoker.instance.getStatistics();

    kLog.wtf(stats.toJson());

    currentJackpot = res;
    setState(() {
      _loading = false;
    });
  }

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
          SliverAppBar(
            flexibleSpace: Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/tzoker_generator.png',
              ),
            ),
            toolbarHeight: 100,
            backgroundColor: Colors.white,
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
              child: TextButton(
                onPressed: () => Get.toNamed('stats'),
                child: Text(
                  'Στατιστικά',
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
                  if (numberOccurences.isNotEmpty)
                    Text(
                      'Occurences in $draws draws\nsince $latestDraw',
                      style: kStyleDefault,
                    ),
                  Wrap(
                    children: [
                      for (int i = 1; i <= 45; i++)
                        if (numberOccurences[i] != null)
                          TzokerBall(
                            color: getColor(i),
                            number: i,
                          ),
                    ],
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 55.0),
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
                              'Σύντομα κληρώνει...!',
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
                  if (numberOccurences.isNotEmpty)
                    Text(
                      'Tzokers',
                      style: kStyleDefault,
                    ),
                  Wrap(
                    children: [
                      for (int i = 1; i <= 20; i++)
                        if (tzokerOccurences[i] != null)
                          TzokerBall(
                            color: getColor(i),
                            number: i,
                          ),
                    ],
                  ),
                ],
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 10),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Τελευταία κλήρωση',
                        style: kStyleDefault.copyWith(
                          fontSize: 25,
                          fontFamily: 'Arial',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Tzoker',
                              style: kStyleDefault,
                            ),
                          ),
                          Wrap(
                            children: [
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
                                    color: getColor(lastResult!.tzoker),
                                    number: lastResult!.tzoker,
                                  ),
                                ),
                              ),
                              ...lastResult!.sortedWinningNumbers.map(
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
                                      color: getColor(e),
                                      number: e,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ]),
              ),
            ),
          ]
        ],
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

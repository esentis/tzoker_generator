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
  int draws = 0;

  double loadingPercentage = 0;
  double currentJackpot = 0;

  bool _loading = true;

  DateTime? latestDraw;
  DateTime? nextDraw;

  LastResult? lastResult;

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

    lastResult = await Tzoker.instance.getLastResult();

    kLog.wtf(lastResult?.toJson());

    nextDraw = await Tzoker.instance.getUpcomingDrawDate();

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
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 6.0,
                              top: 6.0,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xfff8b828),
                                shape: BoxShape.circle,
                              ),
                              child: TzokerBall(
                                color: Tzoker.instance
                                    .getColor(lastResult!.tzoker),
                                number: lastResult!.tzoker,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                          ...lastResult!.sortedWinningNumbers.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(
                                top: 6.0,
                              ),
                              child: TzokerBall(
                                color: Tzoker.instance.getColor(e),
                                height: 50,
                                width: 50,
                                number: e,
                              ),
                            ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/tzoker_response.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Map<int, int> numberOccurences = {};
  Map<int, int> tzokerOccurences = {};

  int draws = 0;

  double loadingPercentage = 0;

  bool _loading = false;
  DateTime? latestDraw;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            flexibleSpace: Image.asset('assets/tzoker_generator.png'),
            toolbarHeight: 100,
            backgroundColor: Colors.white,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 40),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final res = await Tzoker.instance.getJackpot();

                      kLog.wtf(res);
                    },
                    child: Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 50,
                    ),
                  ),
                ),
              )
            ],
          ),
          if (_loading)
            SliverFillRemaining(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/tzoker.json',
                  ),
                  Text(
                    '${loadingPercentage.toStringAsFixed(0)}%',
                    style: kStyleDefault,
                  )
                ],
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
                          occurences: numberOccurences[i].toString(),
                          percentage:
                              '${((numberOccurences[i] ?? 0) / (draws * 5) * 100).toStringAsFixed(2)}%',
                        ),
                  ],
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
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
                          occurences: tzokerOccurences[i].toString(),
                          percentage:
                              '${((tzokerOccurences[i] ?? 0) / draws * 100).toStringAsFixed(2)}%',
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

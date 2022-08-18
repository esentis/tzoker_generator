import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/constants.dart';
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
    kLog.wtf(stats?.toJson());
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Column(
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/tzoker_generator.png',
              ),
            ),
            if (!loading) ...[
              const SizedBox(
                height: 15,
              ),
              Text(
                'Κληρώσεις ${stats?.header.drawCount}',
                style: kStyleDefault,
              ),
              Text(
                '${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(stats!.header.dateFrom * 1000))} εώς ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
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
          : Row(
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
                            decoration: BoxDecoration(border: Border.all()),
                            child: ListTile(
                              tileColor: Tzoker.instance
                                  .getColorOccurence(stats!.numbers[i].delays),
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
                              decoration: BoxDecoration(border: Border.all()),
                              child: ListTile(
                                tileColor: Tzoker.instance.getColorOccurence(
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
    );
  }
}

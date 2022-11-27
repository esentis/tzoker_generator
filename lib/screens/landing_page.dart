import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/helpers/assets.dart';
import 'package:tzoker_generator/helpers/utils.dart';
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/numbers_dialog.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class NumberStatsDialog extends Intent {
  const NumberStatsDialog();
}

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // int draws = 0;

  int currentDraw = 0;
  int latestDraw = 0;

  double loadingPercentage = 0;
  double currentJackpot = 0;

  bool _loading = true;
  bool _loadingNewDraw = false;

  DateTime? latestDrawDate;
  DateTime? nextDraw;

  DrawResult? showingDraw;

  Statistics? latestResultStatistics;

  // Future<List<Map<int, int>>> getResults() async {
  //   Map<int, int> numberOccurences = {};
  //   Map<int, int> tzokerOccurences = {};

  //   DateTime from = DateTime.now();
  //   DateTime to = from.subtract(const Duration(days: 30));

  //   int months = 12;

  //   for (int i = 0; i <= months; i++) {
  //     final resp = await Tzoker.instance.getDrawsInRange(
  //         DateFormat("yyyy-MM-dd").format(to),
  //         DateFormat("yyyy-MM-dd").format(from));

  //     if (resp != null) {
  //       draws += resp.draws.length;

  //       for (Draw draw in resp.draws) {
  //         // Increment the tzoker occurence
  //         tzokerOccurences[draw.winningNumbers.tzoker.first] =
  //             (tzokerOccurences[draw.winningNumbers.tzoker.first] ?? 0) + 1;

  //         for (int num in draw.winningNumbers.numbers) {
  //           // Increment the number occurence
  //           numberOccurences[num] = (numberOccurences[num] ?? 0) + 1;
  //         }
  //       }
  //     }

  //     from = to;
  //     to = to.subtract(const Duration(days: 30));
  //     latestDraw = to;
  //     setState(() {
  //       loadingPercentage = (i / months) * 100;
  //     });
  //   }
  //   loadingPercentage = 0;

  //   return [numberOccurences, tzokerOccurences];
  // }

  Future<void> _prepareLandingPage() async {
    kLog.i('Preparing landing page');
    final res = await Tzoker.instance.getJackpot();

    showingDraw = await Tzoker.instance.getLastResult();

    currentDraw = showingDraw!.drawCount;
    latestDraw = showingDraw!.drawCount;

    await Tzoker.instance.saveDraw(showingDraw!);

    latestResultStatistics = await Tzoker.instance
        .getStatsForDrawCount((showingDraw?.drawCount ?? 0) - 1);

    nextDraw = await Tzoker.instance.getUpcomingDrawDate();

    currentJackpot = res;
    setState(() {
      _loading = false;
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Tzoker.instance.updateDatabase(start: 2513, end: 2519);
    _prepareLandingPage();
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyK):
              const NumberStatsDialog(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            NumberStatsDialog: CallbackAction<NumberStatsDialog>(
              onInvoke: (NumberStatsDialog intent) {
                return Get.dialog(
                  const Center(child: NumbersDialog()),
                );
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thumbColor: kColorOrange,
                radius: const Radius.circular(12),
                thickness: 8,
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        leading: Get.currentRoute != '/'
                            ? IconButton(
                                icon: const Icon(Icons.back_hand),
                                onPressed: Get.back,
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
                      SliverAppBar(
                        primary: false,
                        //pinned: true,
                        floating: true,
                        backgroundColor: Colors.white,
                        flexibleSpace: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: TextButton(
                                  onPressed: () => Get.toNamed('/generate'),
                                  style: TextButton.styleFrom(
                                    backgroundColor: kColorOrange,
                                    textStyle: kStyleDefault,
                                    elevation: 6,
                                  ),
                                  child: const Text('Generate'),
                                ),
                              ),
                              // ! Still under development
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              //   child: TextButton(
                              //     onPressed: () => Get.toNamed('/stats'),
                              //     style: TextButton.styleFrom(
                              //       backgroundColor: const Color(0xfff8b828),
                              //       textStyle: kStyleDefault,
                              //       elevation: 6,
                              //     ),
                              //     child: const Text('Stats'),
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: TextButton(
                                  onPressed: () => Get.toNamed('/search'),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xfff8b828),
                                    textStyle: kStyleDefault,
                                    elevation: 6,
                                  ),
                                  child: const Text('Search'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_loading)
                        SliverFillRemaining(
                          child: Column(
                            children: [
                              Lottie.asset(
                                Assets.loading,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Next draw ${DateFormat("dd MMMM yyyy, HH:ss").format(nextDraw!)}',
                                  style: kStyleDefault.copyWith(
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
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 10,
                                        color: Colors.grey[400]!,
                                        offset: const Offset(0, 3),
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  duration:
                                      nextDraw!.difference(DateTime.now()),
                                  separatorType: SeparatorType.title,
                                  textStyle: kStyleDefault.copyWith(
                                    color: Colors.black.withOpacity(0.7),
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
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'Minimum distributed on next draw',
                                        style: kStyleDefault.copyWith(
                                            fontSize: 25),
                                      ),
                                    ),
                                    if (currentJackpot == 0)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '€',
                                            style: kStyleDefault.copyWith(
                                              fontSize: 50,
                                            ),
                                          ),
                                          Text(
                                            NumberFormat(
                                              "###,###.###",
                                            ).format(currentJackpot),
                                            style: kStyleDefault.copyWith(
                                              fontSize: 50,
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
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 3.0),
                            child: Divider(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Center(
                            child: Column(
                              children: [
                                TextButton(
                                  onPressed: latestDraw == currentDraw
                                      ? null
                                      : () async {
                                          setState(() {
                                            _loadingNewDraw = true;
                                            currentDraw = latestDraw;
                                          });

                                          final draw = await Tzoker.instance
                                              .getDraw(currentDraw);

                                          showingDraw =
                                              DrawResult.fromDraw(draw);

                                          latestResultStatistics = await Tzoker
                                              .instance
                                              .getStatsForDrawCount(
                                            currentDraw - 1,
                                          );

                                          setState(() {
                                            _loadingNewDraw = false;
                                          });
                                        },
                                  child: Text(
                                    latestDraw == currentDraw
                                        ? 'Latest draw'
                                        : 'Go to the latest draw',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 20,
                                      color: latestDraw != currentDraw
                                          ? Colors.blue
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 350,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          setState(() {
                                            _loadingNewDraw = true;
                                          });
                                          currentDraw--;
                                          final draw = await Tzoker.instance
                                              .getDraw(currentDraw);

                                          showingDraw =
                                              DrawResult.fromDraw(draw);

                                          latestResultStatistics = await Tzoker
                                              .instance
                                              .getStatsForDrawCount(
                                                  currentDraw - 1);

                                          setState(() {
                                            _loadingNewDraw = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: currentDraw == 1
                                              ? Colors.grey
                                              : Colors.blue,
                                          size: 45,
                                        ),
                                      ),
                                      Text(
                                        'Draw $currentDraw',
                                        style: kStyleDefault.copyWith(
                                          fontSize: 25,
                                          color: const Color(0xff8d0d46),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: currentDraw == latestDraw
                                            ? null
                                            : () async {
                                                setState(() {
                                                  _loadingNewDraw = true;
                                                });
                                                currentDraw++;
                                                final draw = await Tzoker
                                                    .instance
                                                    .getDraw(currentDraw);

                                                showingDraw =
                                                    DrawResult.fromDraw(draw);

                                                latestResultStatistics =
                                                    await Tzoker.instance
                                                        .getStatsForDrawCount(
                                                  currentDraw - 1,
                                                );

                                                setState(() {
                                                  _loadingNewDraw = false;
                                                });
                                              },
                                        icon: Icon(
                                          Icons.arrow_forward,
                                          size: 45,
                                          color: currentDraw == latestDraw
                                              ? Colors.grey
                                              : Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  DateFormat("dd MMMM yyyy, HH:ss")
                                      .format(showingDraw!.date),
                                  style: kStyleDefault.copyWith(
                                    fontSize: 18,
                                    color: const Color(0xff3b6250)
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                const SizedBox(
                                  width: 350,
                                  child: Divider(
                                    color: Color(0xfff8b828),
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                // TZOKER NUMBER
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 6.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      DecoratedBox(
                                        decoration: const BoxDecoration(
                                          color: Color(0xfff8b828),
                                          shape: BoxShape.circle,
                                        ),
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              kLog.wtf(
                                                'Tapped on tzoker ${showingDraw!.tzoker}',
                                              );

                                              Get.toNamed(
                                                '/numberStats?number=${showingDraw!.tzoker}',
                                              );
                                            },
                                            child: TzokerBall(
                                              color: Tzoker.instance.getColor(
                                                showingDraw!.tzoker,
                                              ),
                                              height: 50,
                                              width: 50,
                                              number: showingDraw!.tzoker,
                                              isLoading: _loadingNewDraw,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      //
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_loadingNewDraw) ...[
                                            Shimmer.fromColors(
                                              baseColor: Colors.white,
                                              highlightColor:
                                                  Colors.black.withOpacity(0.6),
                                              child: Container(
                                                width: 200,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Shimmer.fromColors(
                                              baseColor: Colors.white,
                                              highlightColor:
                                                  const Color(0xff8d0d46)
                                                      .withOpacity(0.6),
                                              child: Container(
                                                width: 250,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                              ),
                                            ),
                                          ] else ...[
                                            Text(
                                              'Appeared after ${latestResultStatistics?.bonusNumbers.firstWhere((n) => n.number == showingDraw!.tzoker).delays} delays',
                                              style: kStyleDefault,
                                            ),
                                            Text(
                                              'Had ${((latestResultStatistics!.bonusNumbers.firstWhere((n) => n.number == showingDraw!.tzoker).occurrences * 100) / (showingDraw!.drawCount - 1)).toStringAsFixed(2)}% total appearence chance',
                                              style: kStyleDefault.copyWith(
                                                fontSize: 16,
                                                color: const Color(0xff8d0d46)
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 350,
                                  child: Divider(
                                    color: Color(0xfff8b828),
                                  ),
                                ),
                                ...showingDraw!.sortedWinningNumbers.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => Get.toNamed(
                                                '/numberStats?number=$e'),
                                            child: TzokerBall(
                                              color:
                                                  Tzoker.instance.getColor(e),
                                              height: 50,
                                              width: 50,
                                              number: e,
                                              isLoading: _loadingNewDraw,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (_loadingNewDraw) ...[
                                              Shimmer.fromColors(
                                                baseColor: Colors.white,
                                                highlightColor: Colors.black
                                                    .withOpacity(0.6),
                                                child: Container(
                                                  width: 200,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Shimmer.fromColors(
                                                baseColor: Colors.white,
                                                highlightColor:
                                                    const Color(0xff8d0d46)
                                                        .withOpacity(0.6),
                                                child: Container(
                                                  width: 250,
                                                  height: 18,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                ),
                                              ),
                                            ] else ...[
                                              Text(
                                                'Appeared after ${latestResultStatistics?.numbers.firstWhere((n) => n.number == e).delays} delays',
                                                style: kStyleDefault,
                                              ),
                                              Text(
                                                'Had ${((latestResultStatistics!.numbers.firstWhere((n) => n.number == e).occurrences * 100) / (showingDraw!.drawCount - 1)).toStringAsFixed(2)}% total appearence chance',
                                                style: kStyleDefault.copyWith(
                                                  fontSize: 16,
                                                  color: const Color(0xff8d0d46)
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    'Version ${Utils.version}',
                                    style: kStyleDefault.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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
                ),
              ),
              // This trailing comma makes auto-formatting nicer for build methods.
            ),
          ),
        ),
      ),
    );
  }
}

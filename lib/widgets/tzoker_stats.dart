import 'package:flutter/material.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

enum SortFilter {
  number,
  delay,
  occurences,
  percentage,
}

class TzokerStats extends StatefulWidget {
  const TzokerStats({
    required this.numbers,
    required this.drawCount,
    required this.title,
    Key? key,
  }) : super(key: key);

  final List<Number> numbers;
  final int drawCount;
  final String title;
  @override
  State<TzokerStats> createState() => _TzokerStatsState();
}

class _TzokerStatsState extends State<TzokerStats> {
  SortFilter _currentFilter = SortFilter.number;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: ScrollController(),
        slivers: [
          SliverAppBar(
            elevation: 1,
            forceElevated: true,
            shadowColor: Colors.white,
            leading: const SizedBox(),
            backgroundColor: const Color(0xff3c5c8f),
            title: Text(
              widget.title,
              style: kStyleDefault,
            ),
            centerTitle: true,
            pinned: true,
          ),
          SliverAppBar(
            elevation: 6,
            primary: false,
            leading: const SizedBox(),
            backgroundColor: const Color(0xff3c5c8f),
            flexibleSpace: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_currentFilter == SortFilter.number) {
                          if (widget.numbers[0].number >
                              widget.numbers[1].number) {
                            widget.numbers.sort(
                              (a, b) => a.number.compareTo(b.number),
                            );
                          } else {
                            widget.numbers.sort(
                              (a, b) => b.number.compareTo(a.number),
                            );
                          }
                        } else {
                          widget.numbers.sort(
                            (a, b) => a.number.compareTo(b.number),
                          );
                        }
                        _currentFilter = SortFilter.number;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Text(
                            'Number',
                            style: kStyleDefault.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (_currentFilter == SortFilter.number)
                            if (widget.numbers[0].number >
                                widget.numbers[1].number)
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              )
                            else
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_currentFilter == SortFilter.delay) {
                          if (widget.numbers[0].delays == 0) {
                            widget.numbers.sort(
                              (a, b) => b.delays.compareTo(a.delays),
                            );
                          } else {
                            widget.numbers.sort(
                              (a, b) => a.delays.compareTo(b.delays),
                            );
                          }
                        } else {
                          widget.numbers.sort(
                            (a, b) => a.delays.compareTo(b.delays),
                          );
                        }
                        _currentFilter = SortFilter.delay;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Text(
                            'Delays',
                            style: kStyleDefault.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (_currentFilter == SortFilter.delay)
                            if (widget.numbers[0].delays >
                                widget.numbers[1].delays)
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              )
                            else
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        kLog.wtf(widget.numbers[0].occurrences >
                            widget.numbers[1].occurrences);

                        if (_currentFilter == SortFilter.occurences) {
                          if (widget.numbers[0].occurrences >
                              widget.numbers[1].occurrences) {
                            widget.numbers.sort(
                              (a, b) => a.occurrences.compareTo(b.occurrences),
                            );
                          } else {
                            widget.numbers.sort(
                              (a, b) => b.occurrences.compareTo(a.occurrences),
                            );
                          }
                        } else {
                          widget.numbers.sort(
                            (a, b) => a.occurrences.compareTo(b.occurrences),
                          );
                        }

                        _currentFilter = SortFilter.occurences;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Text(
                            'Occurences',
                            style: kStyleDefault.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (_currentFilter == SortFilter.occurences)
                            if (widget.numbers[0].occurrences >
                                widget.numbers[1].occurrences)
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              )
                            else
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        kLog.wtf(widget.numbers[0].occurrences >
                            widget.numbers[1].occurrences);

                        if (_currentFilter == SortFilter.percentage) {
                          if (widget.numbers[0].occurrences >
                              widget.numbers[1].occurrences) {
                            widget.numbers.sort(
                              (a, b) => (a.occurrences *
                                      100 /
                                      (widget.drawCount))
                                  .compareTo(
                                      b.occurrences * 100 / (widget.drawCount)),
                            );
                          } else {
                            widget.numbers.sort(
                              (a, b) => (b.occurrences *
                                      100 /
                                      (widget.drawCount))
                                  .compareTo(
                                      a.occurrences * 100 / (widget.drawCount)),
                            );
                          }
                        } else {
                          widget.numbers.sort(
                            (a, b) => (a.occurrences * 100 / (widget.drawCount))
                                .compareTo(
                                    b.occurrences * 100 / (widget.drawCount)),
                          );
                        }

                        _currentFilter = SortFilter.percentage;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Text(
                            'Percentages',
                            style: kStyleDefault.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (_currentFilter == SortFilter.percentage)
                            if ((((widget.numbers[0].occurrences * 100) /
                                    widget.drawCount)) >
                                (((widget.numbers[1].occurrences * 100) /
                                    widget.drawCount)))
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              )
                            else
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                      .getColorOccurence(widget.numbers[i].delays),
                  leading: TzokerBall(
                    color: Tzoker.instance.getColor(i + 1),
                    number: widget.numbers[i].number,
                    isLoading: false,
                  ),
                  title: Text(
                    'Delays ${widget.numbers[i].delays}',
                    style: kStyleDefault,
                  ),
                  subtitle: Text(
                    'Occurences ${widget.numbers[i].occurrences}\nPercentage ${((widget.numbers[i].occurrences * 100) / widget.drawCount).toStringAsFixed(2)}%',
                    style: kStyleDefault,
                  ),
                ),
              ),
              childCount: widget.numbers.length,
            ),
          )
        ],
      ),
    );
  }
}

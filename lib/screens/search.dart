import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/helpers/assets.dart';
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/search_numbers.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<int> _selectedNumbers = [];
  final List<int> _selectedTzokers = [];

  List<DrawResult> foundDraws = [];

  bool isLoading = false;

  Future<void> searchDraws() async {
    foundDraws = [];
    setState(() {
      isLoading = true;
    });

    if (_selectedNumbers.isEmpty && _selectedTzokers.isEmpty) {
      foundDraws = [];
    } else {
      final res = await Tzoker.instance.getDrawsOfSpecificSequence(
        nums: _selectedNumbers,
        tzoker: _selectedTzokers.isNotEmpty ? _selectedTzokers.first : null,
      );

      foundDraws = res;
      foundDraws.sort(
        (a, b) => a.drawCount.compareTo(b.drawCount),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  String formatDifference(int days) {
    if (days == 0) {
      return 'Consecutive draw';
    }
    if (days > 0 && days <= 30) {
      return '$days days after the last draw';
    }
    if (days > 30 && days <= 365) {
      return '${(days / 30).floor()} months, ${days % 30} days after the last draw';
    }
    if (days > 365) {
      return '${(days / 365).floor()} years, ${((days % 365) / 30).floor()} months, ${(days % 365) % 30} days after the last draw';
    }
    return '';
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thumbColor: kColorOrange,
        radius: const Radius.circular(12),
        thickness: 8,
        child: CustomScrollView(
          controller: _scrollController,
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
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SearchNumbers(
                      count: 45,
                      isLoading: isLoading,
                      selectedNumbers: _selectedNumbers,
                      onNumberTap: (number) {
                        if (_selectedNumbers.contains(number + 1)) {
                          _selectedNumbers.remove(number + 1);
                          searchDraws();
                        } else {
                          if (_selectedNumbers.length < 5) {
                            _selectedNumbers.add(number + 1);
                            searchDraws();
                          }
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: SearchNumbers(
                      count: 25,
                      isLoading: isLoading,
                      selectedNumbers: _selectedTzokers,
                      onNumberTap: (tzoker) {
                        if (_selectedTzokers.contains(tzoker + 1)) {
                          _selectedTzokers.remove(tzoker + 1);
                          searchDraws();
                        } else {
                          if (_selectedTzokers.isEmpty) {
                            _selectedTzokers.add(tzoker + 1);
                            searchDraws();
                          }
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  foundDraws[index].winningNumbers.sort();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 15,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff8b828),
                                    shape: BoxShape.circle,
                                    border: _selectedTzokers
                                            .contains(foundDraws[index].tzoker)
                                        ? Border.all(
                                            color: Colors.red,
                                            width: 5,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${foundDraws[index].tzoker}',
                                      style: kStyleDefault.copyWith(
                                        fontSize: 20,
                                        color: const Color(0xff2c345b),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Wrap(
                                children: foundDraws[index]
                                    .winningNumbers
                                    .map(
                                      (e) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            color: const Color(0xff2c345b),
                                            shape: BoxShape.circle,
                                            border: _selectedNumbers.contains(e)
                                                ? Border.all(
                                                    color: Colors.red,
                                                    width: 5,
                                                  )
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$e',
                                              style: kStyleDefault.copyWith(
                                                fontSize: 20,
                                                color: const Color(0xffc0e051),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        subtitle: index != 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat("dd/MM/yyyy")
                                        .format(foundDraws[index].date),
                                    style: kStyleDefault,
                                  ),
                                  Text(
                                    formatDifference(
                                      foundDraws[index]
                                          .date
                                          .difference(
                                            foundDraws[index - 1].date,
                                          )
                                          .inDays,
                                    ),
                                    style: kStyleDefault.copyWith(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Text(
                                  DateFormat("dd/MM/yyyy")
                                      .format(foundDraws[index].date),
                                  style: kStyleDefault,
                                ),
                              ),
                        isThreeLine: true,
                      ),
                    ),
                  );
                },
                childCount: foundDraws.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}

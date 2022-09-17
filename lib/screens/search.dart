import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

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
    final res = await Tzoker.instance.getDrawsOfSpecificSequence(
      nums: _selectedNumbers,
      tzoker: _selectedTzokers.isNotEmpty ? _selectedTzokers.first : null,
    );
    foundDraws = res;
    // if (foundDraws.isNotEmpty) {
    //   res.forEach((d) => kLog.wtf(d.toJson()));
    // } else {
    //   kLog.w('No drawas found with the specific numbers');
    // }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            flexibleSpace: Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Get.offAllNamed('/'),
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/tzoker_generator.png',
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
                Flexible(
                  child: Column(
                    children: [
                      Text(
                        'Numbers',
                        style: kStyleDefault,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              children: List.generate(
                                45,
                                (index) => GestureDetector(
                                  onTap: () {
                                    if (_selectedNumbers.contains(index + 1)) {
                                      _selectedNumbers.remove(index + 1);
                                      searchDraws();
                                    } else {
                                      if (_selectedNumbers.length < 5) {
                                        _selectedNumbers.add(index + 1);
                                        searchDraws();
                                      }
                                    }
                                    setState(() {});
                                  },
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedNumbers.contains(index + 1)
                                              ? Colors.red
                                              : null,
                                      shape: BoxShape.circle,
                                    ),
                                    child: TzokerBall(
                                      height: 35,
                                      width: 35,
                                      color:
                                          Tzoker.instance.getColor(index + 1),
                                      number: index + 1,
                                      isLoading: isLoading,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Text(
                        'Tzoker',
                        style: kStyleDefault,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                            ),
                          ),
                          child: Wrap(
                            children: List.generate(
                              25,
                              (index) => GestureDetector(
                                onTap: () {
                                  if (_selectedTzokers.contains(index + 1)) {
                                    _selectedTzokers.remove(index + 1);
                                    searchDraws();
                                  } else {
                                    if (_selectedTzokers.isEmpty) {
                                      _selectedTzokers.add(index + 1);
                                      searchDraws();
                                    }
                                  }
                                  setState(() {});
                                },
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: _selectedTzokers.contains(index + 1)
                                        ? Colors.red
                                        : null,
                                    shape: BoxShape.circle,
                                  ),
                                  child: TzokerBall(
                                    height: 35,
                                    width: 35,
                                    color: Tzoker.instance.getColor(index + 1),
                                    number: index + 1,
                                    isLoading: isLoading,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('${foundDraws[index].winningNumbers}'),
              ),
              childCount: foundDraws.length,
            ),
          )
        ],
      ),
    );
  }
}

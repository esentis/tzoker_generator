import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/api/connection.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Map<int, int> numberOccurences = {};
  Map<int, int> tzokerOccurences = {};
  bool _loading = false;

  void getResults() async {
    setState(() {
      _loading = true;
    });
    numberOccurences = {};
    tzokerOccurences = {};

    DateTime from = DateTime.now();
    DateTime to = DateTime.now().subtract(const Duration(days: 30));

    for (int i = 0; i <= 24; i++) {
      final resp = await getTzokerResults(DateFormat("yyyy-MM-dd").format(to),
          DateFormat("yyyy-MM-dd").format(from));

      resp?.draws.forEach((c) {
        // Count tzoker occurences for this period
        tzokerOccurences[c.winningNumbers.tzoker.first] =
            (tzokerOccurences[c.winningNumbers.tzoker.first] ?? 0) + 1;

        for (int num in c.winningNumbers.numbers) {
          numberOccurences[num] = (numberOccurences[num] ?? 0) + 1;
        }
      });

      from = to;
      to = to.subtract(const Duration(days: 30));
    }

    List<int> sortedValues = numberOccurences.values.toList()..sort();

    setState(() {
      _loading = false;
    });
  }

  Color getColor(int num) {
    if (num >= 1 && num <= 10) {
      return Color(0xff344ed6);
    }
    if (num > 10 && num <= 20) {
      return Color(0xff8d0d46);
    }
    if (num >= 21 && num <= 30) {
      return Color(0xffb9d4ef);
    }
    if (num >= 31 && num <= 40) {
      return const Color(0xffc0e051);
    }
    if (num >= 41 && num <= 45) {
      return Color(0xff3b6250);
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_loading)
            Center(
              child: Lottie.asset(
                'assets/tzoker.json',
                height: 250,
              ),
            ),
          Column(
            children: [
              if (numberOccurences.isNotEmpty)
                Text(
                  'Occurences',
                  style: TextStyle(fontSize: 35),
                ),
              Wrap(
                children: [
                  for (int i = 1; i <= 45; i++)
                    if (numberOccurences[i] != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: getColor(i),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 12,
                                    offset: Offset(5, 1),
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                  BoxShadow(
                                      blurRadius: 5,
                                      offset: Offset(0, 5),
                                      color: Colors.grey.shade400)
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  height: 50,
                                  width: 40,
                                  color: const Color(0xff2c345b),
                                  child: Center(
                                    child: Text(
                                      '$i',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        color: Color(0xffc0e051),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text('${numberOccurences[i]}')
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              if (numberOccurences.isNotEmpty)
                Text(
                  'Tzokers',
                  style: TextStyle(fontSize: 35),
                ),
              Wrap(
                children: [
                  for (int i = 1; i <= 20; i++)
                    if (tzokerOccurences[i] != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: getColor(i),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 12,
                                    offset: Offset(5, 1),
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                  BoxShadow(
                                      blurRadius: 5,
                                      offset: Offset(0, 5),
                                      color: Colors.grey.shade400)
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  height: 40,
                                  width: 30,
                                  color: const Color(0xff2c345b),
                                  child: Center(
                                    child: Text(
                                      '$i',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        color: Color(0xffc0e051),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text('${tzokerOccurences[i]}')
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getResults,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

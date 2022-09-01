import 'package:flutter/material.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class NumberStatsScreen extends StatefulWidget {
  const NumberStatsScreen({required this.number, Key? key}) : super(key: key);

  final int number;

  @override
  State<NumberStatsScreen> createState() => _NumberStatsScreenState();
}

class _NumberStatsScreenState extends State<NumberStatsScreen> {
  int totalDrawsAsNumber = 0;
  int totalDrawsAsTzoker = 0;

  Future<void> getNumberStats() async {
    final res = await Future.wait([
      Tzoker.instance.getDrawsOfSpecificSequence(nums: [widget.number]),
      if (widget.number <= 20)
        Tzoker.instance.getDrawsOfSpecificSequence(tzoker: widget.number),
    ]);

    totalDrawsAsNumber = res[0].length;
    if (widget.number <= 20) totalDrawsAsTzoker = res[1].length;

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNumberStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          ),
          SliverAppBar(
            leading: const SizedBox(),
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
          SliverToBoxAdapter(
            child: Column(
              children: [
                TzokerBall(
                  color: Tzoker.instance.getColor(widget.number),
                  height: 100,
                  width: 100,
                  number: widget.number,
                  isLoading: false,
                ),
                Text('Appeared as number in $totalDrawsAsNumber draws'),
                if (widget.number <= 20)
                  Text('Appeared as tzoker in $totalDrawsAsTzoker draws'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

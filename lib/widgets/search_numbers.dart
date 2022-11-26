import 'package:flutter/material.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class SearchNumbers extends StatefulWidget {
  const SearchNumbers({
    required this.onNumberTap,
    required this.count,
    required this.isLoading,
    required this.selectedNumbers,
    super.key,
  });
  final Function(int) onNumberTap;
  final int count;
  final bool isLoading;
  final List<int> selectedNumbers;
  @override
  State<SearchNumbers> createState() => _SearchNumbersState();
}

class _SearchNumbersState extends State<SearchNumbers> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Numbers ${widget.selectedNumbers.length}/5',
          style: kStyleDefault,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: List.generate(
                widget.count,
                (index) => GestureDetector(
                  onTap: () {
                    widget.onNumberTap(index);
                    setState(() {});
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.selectedNumbers.contains(index + 1)
                          ? Colors.red
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: TzokerBall(
                      height: 35,
                      width: 35,
                      color: Tzoker.instance.getColor(index + 1),
                      number: index + 1,
                      isLoading: widget.isLoading,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

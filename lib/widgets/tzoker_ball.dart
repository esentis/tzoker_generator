import 'package:flutter/material.dart';
import 'package:tzoker_generator/constants.dart';

class TzokerBall extends StatelessWidget {
  const TzokerBall({required this.color, required this.number, Key? key})
      : super(key: key);

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(5, 1),
              color: Colors.black.withOpacity(0.6),
            ),
            BoxShadow(
                blurRadius: 5,
                offset: const Offset(0, 5),
                color: Colors.grey.shade400)
          ],
        ),
        child: Center(
          child: Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              color: Color(0xff2c345b),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: kStyleDefault.copyWith(
                  fontSize: 20,
                  color: const Color(0xffc0e051),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

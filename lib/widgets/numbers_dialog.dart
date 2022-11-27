import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/services/tzoker.dart';
import 'package:tzoker_generator/widgets/tzoker_ball.dart';

class NumbersDialog extends StatelessWidget {
  const NumbersDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        DefaultTextStyle(
          style: kStyleDefault.copyWith(
            fontSize: 25,
            color: Colors.white,
          ),
          child: Text(
            'Tap on a number to check its stats',
            style: kStyleDefault.copyWith(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Flexible(
          child: Wrap(
            children: List<Widget>.generate(
              45,
              (index) => Material(
                color: Colors.transparent,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        '/numberStats?number=${index + 1}',
                      );
                    },
                    child: Card(
                      color: kColorOrange,
                      child: TzokerBall(
                        color: Tzoker.instance.getColor(index + 1),
                        number: index + 1,
                        isLoading: false,
                      ),
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

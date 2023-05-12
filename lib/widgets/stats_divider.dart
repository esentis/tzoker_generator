import 'package:flutter/material.dart';

class StatsDivider extends StatelessWidget {
  const StatsDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: 4,
        ),
        SizedBox(
          width: 350,
          child: Divider(
            color: Colors.red,
          ),
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }
}

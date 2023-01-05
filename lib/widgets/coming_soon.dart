import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/helpers/assets.dart';
import 'package:tzoker_generator/helpers/utils.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Image.asset(
          Assets.logo,
        ),
        toolbarHeight: 100,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Column(
            children: [
              Text(
                'Oops',
                style: kStyleDefault,
              ),
              Center(
                child: Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_4fewfamh.json',
                ),
              ),
              Text(
                'Currently only on Desktop',
                style: kStyleDefault,
              )
            ],
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
    );
  }
}

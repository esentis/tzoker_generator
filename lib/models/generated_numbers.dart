import 'package:tzoker_generator/models/statistics.dart';

class GeneratedNumbers {
  final List<Number> numbers;
  final Number tzoker;

  GeneratedNumbers({
    required this.numbers,
    required this.tzoker,
  });

  Map<String, dynamic> toJson() {
    numbers.sort(
      (a, b) => a.number.compareTo(b.number),
    );
    return {
      "numbers": numbers.map((e) => e.number),
      "tzoker": tzoker.number,
    };
  }
}

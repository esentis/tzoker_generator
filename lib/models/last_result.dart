import 'package:tzoker_generator/models/tzoker_response.dart';

class DrawResult {
  DrawResult({
    required this.date,
    required this.tzoker,
    required this.winningNumbers,
    required this.sortedWinningNumbers,
    required this.drawCount,
  });

  final DateTime date;
  final List<int> winningNumbers;
  final int tzoker;
  final int drawCount;
  final List<int> sortedWinningNumbers;

  factory DrawResult.fromDraw(Draw draw) {
    return DrawResult(
      date: DateTime.fromMillisecondsSinceEpoch(draw.drawTime),
      tzoker: draw.winningNumbers.tzoker.first,
      winningNumbers: draw.winningNumbers.numbers,
      sortedWinningNumbers: draw.winningNumbers.numbers
        ..sort((a, b) => a.compareTo(b)),
      drawCount: draw.drawId,
    );
  }

  factory DrawResult.fromJson(Map<String, dynamic> draw) {
    return DrawResult(
      date: DateTime.parse(draw['drawDate'] as String),
      tzoker: draw['tzoker'] as int,
      winningNumbers: List<int>.generate(
        5,
        (index) => (draw['numbers'] as List)[index] as int,
      ).toList(),
      sortedWinningNumbers: List<int>.generate(
        5,
        (index) => (draw['numbers'] as List)[index] as int,
      ).toList()
        ..sort((a, b) => a.compareTo(b)),
      drawCount: draw['id'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
        "date": date,
        "drawCount": drawCount,
        "winningNumbers": sortedWinningNumbers.map((e) => e),
        "tzoker": tzoker,
      };
}

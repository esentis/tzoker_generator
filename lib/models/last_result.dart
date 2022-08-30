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
  final List sortedWinningNumbers;

  Map<String, dynamic> toJson() => {
        "date": date,
        "drawCount": drawCount,
        "winningNumbers": sortedWinningNumbers.map((e) => e),
        "tzoker": tzoker,
      };

  factory DrawResult.fromDraw(Draw draw) {
    return DrawResult(
      date: DateTime.fromMillisecondsSinceEpoch(draw.drawTime),
      tzoker: draw.winningNumbers.tzoker.first,
      winningNumbers: draw.winningNumbers.numbers,
      sortedWinningNumbers: draw.winningNumbers.numbers
        ..sort(((a, b) => a.compareTo(b))),
      drawCount: draw.drawId,
    );
  }
}

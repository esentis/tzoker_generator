class LastResult {
  LastResult({
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
}

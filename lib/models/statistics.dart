// To parse this JSON data, do
//
//     final statistics = statisticsFromJson(jsonString);

import 'dart:convert';

Statistics statisticsFromJson(String str) => Statistics.fromJson(json.decode(str));

String statisticsToJson(Statistics data) => json.encode(data.toJson());

class Statistics {
  Statistics({
    required this.header,
    required this.numbers,
    required this.bonusNumbers,
  });

  Header header;
  List<Number> numbers;
  List<Number> bonusNumbers;

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
        header: Header.fromJson(json["header"]),
        numbers: List<Number>.from(json["numbers"].map((x) => Number.fromJson(x))),
        bonusNumbers: List<Number>.from(
          json["bonusNumbers"].map((x) => Number.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "header": header.toJson(),
        "numbers": List<dynamic>.from(numbers.map((x) => x.toJson())),
        "bonusNumbers": List<dynamic>.from(bonusNumbers.map((x) => x.toJson())),
      };
}

class Number {
  Number({
    required this.occurrences,
    required this.delays,
    required this.number,
  });

  int occurrences;
  int delays;
  int number;

  factory Number.fromJson(Map<String, dynamic> json) => Number(
        occurrences: json["occurrences"],
        delays: json["delays"],
        number: json["number"],
      );

  Map<String, dynamic> toJson() => {
        "occurrences": occurrences,
        "delays": delays,
        "number": number,
      };
}

class Header {
  Header({
    required this.dateFrom,
    required this.dateTo,
    required this.drawCount,
  });

  int dateFrom;
  int dateTo;
  int drawCount;

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        dateFrom: json["dateFrom"],
        dateTo: json["dateTo"].toInt(),
        drawCount: json["drawCount"],
      );

  Map<String, dynamic> toJson() => {
        "dateFrom": dateFrom,
        "dateTo": dateTo,
        "drawCount": drawCount,
      };
}

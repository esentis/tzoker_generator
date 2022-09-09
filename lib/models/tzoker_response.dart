// To parse this JSON data, do
//
//     final tzokerResponse = tzokerResponseFromJson(jsonString);

import 'dart:convert';

TzokerResponse tzokerResponseFromJson(String str) =>
    TzokerResponse.fromJson(json.decode(str));

String tzokerResponseToJson(TzokerResponse data) => json.encode(data.toJson());

class TzokerResponse {
  TzokerResponse({
    required this.draws,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.numberOfElements,
    required this.sort,
    required this.first,
    required this.size,
    required this.number,
  });

  List<Draw> draws;
  int totalPages;
  int totalElements;
  bool last;
  int numberOfElements;
  List<Sort> sort;
  bool first;
  int size;
  int number;

  factory TzokerResponse.fromJson(Map<String, dynamic> json) => TzokerResponse(
        draws: List<Draw>.from(json["content"].map((x) => Draw.fromJson(x))),
        totalPages: json["totalPages"],
        totalElements: json["totalElements"],
        last: json["last"],
        numberOfElements: json["numberOfElements"],
        sort: List<Sort>.from(json["sort"].map((x) => Sort.fromJson(x))),
        first: json["first"],
        size: json["size"],
        number: json["number"],
      );

  Map<String, dynamic> toJson() => {
        "content": List<dynamic>.from(draws.map((x) => x.toJson())),
        "totalPages": totalPages,
        "totalElements": totalElements,
        "last": last,
        "numberOfElements": numberOfElements,
        "sort": List<dynamic>.from(sort.map((x) => x.toJson())),
        "first": first,
        "size": size,
        "number": number,
      };
}

class Draw {
  Draw({
    required this.gameId,
    required this.drawId,
    required this.drawTime,
    required this.status,
    required this.drawBreak,
    required this.visualDraw,
    required this.pricePoints,
    required this.winningNumbers,
    required this.prizeCategories,
    required this.wagerStatistics,
    required this.drawDate,
  });

  int gameId;
  int drawId;
  int drawTime;
  Status? status;
  int drawBreak;
  int visualDraw;
  PricePoints pricePoints;
  WinningNumbers winningNumbers;
  List<PrizeCategory> prizeCategories;
  WagerStatistics wagerStatistics;
  late DateTime drawDate;

  factory Draw.fromJson(Map<String, dynamic> json) => Draw(
        gameId: json["gameId"],
        drawId: json["drawId"],
        drawTime: json["drawTime"],
        status: statusValues.map[json["status"]],
        drawBreak: json["drawBreak"],
        visualDraw: json["visualDraw"],
        pricePoints: PricePoints.fromJson(json["pricePoints"]),
        winningNumbers: WinningNumbers.fromJson(json["winningNumbers"]),
        prizeCategories: List<PrizeCategory>.from(
          json["prizeCategories"].map((x) => PrizeCategory.fromJson(x)),
        ),
        wagerStatistics: WagerStatistics.fromJson(json["wagerStatistics"]),
        drawDate: DateTime.fromMillisecondsSinceEpoch(json["drawTime"]),
      );

  Map<String, dynamic> toJson() => {
        "gameId": gameId,
        "drawId": drawId,
        "drawTime": drawTime,
        "status": statusValues.reverse[status],
        "drawBreak": drawBreak,
        "visualDraw": visualDraw,
        "pricePoints": pricePoints.toJson(),
        "winningNumbers": winningNumbers.toJson(),
        "prizeCategories":
            List<dynamic>.from(prizeCategories.map((x) => x.toJson())),
        "wagerStatistics": wagerStatistics.toJson(),
        "drawDate": drawDate,
      };
}

class PricePoints {
  PricePoints({
    required this.amount,
  });

  double amount;

  factory PricePoints.fromJson(Map<String, dynamic> json) => PricePoints(
        amount: json["amount"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
      };
}

class PrizeCategory {
  PrizeCategory({
    required this.id,
    required this.divident,
    required this.winners,
    required this.distributed,
    required this.jackpot,
    required this.fixed,
    required this.categoryType,
    required this.gameType,
    required this.minimumDistributed,
  });

  int id;
  double divident;
  int winners;
  double distributed;
  double jackpot;
  double fixed;
  int categoryType;
  String gameType;
  num? minimumDistributed;

  factory PrizeCategory.fromJson(Map<String, dynamic> json) => PrizeCategory(
        id: json["id"],
        divident: json["divident"].toDouble(),
        winners: json["winners"],
        distributed: json["distributed"].toDouble(),
        jackpot: json["jackpot"].toDouble(),
        fixed: json["fixed"].toDouble(),
        categoryType: json["categoryType"],
        gameType: json["gameType"],
        minimumDistributed:
            json["minimumDistributed"] ?? json["minimumDistributed"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "divident": divident,
        "winners": winners,
        "distributed": distributed,
        "jackpot": jackpot,
        "fixed": fixed,
        "categoryType": categoryType,
        "gameType": gameType,
        "minimumDistributed": minimumDistributed ?? minimumDistributed,
      };
}

enum Status { RESULTS }

final statusValues = EnumValues({"results": Status.RESULTS});

class WagerStatistics {
  WagerStatistics({
    required this.columns,
    required this.wagers,
    required this.addOn,
  });

  int columns;
  int wagers;
  List<dynamic> addOn;

  factory WagerStatistics.fromJson(Map<String, dynamic> json) =>
      WagerStatistics(
        columns: json["columns"],
        wagers: json["wagers"],
        addOn: List<dynamic>.from(json["addOn"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "columns": columns,
        "wagers": wagers,
        "addOn": List<dynamic>.from(addOn.map((x) => x)),
      };
}

class WinningNumbers {
  WinningNumbers({
    required this.numbers,
    required this.tzoker,
  });

  List<int> numbers;
  List<int> tzoker;

  factory WinningNumbers.fromJson(Map<String, dynamic> json) => WinningNumbers(
        numbers: List<int>.from(json["list"].map((x) => x)),
        tzoker: List<int>.from(json["bonus"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(numbers.map((x) => x)),
        "bonus": List<dynamic>.from(tzoker.map((x) => x)),
      };
}

class Sort {
  Sort({
    required this.direction,
    required this.property,
    required this.ignoreCase,
    required this.nullHandling,
    required this.descending,
    required this.ascending,
  });

  String direction;
  String property;
  bool ignoreCase;
  String nullHandling;
  bool descending;
  bool ascending;

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
        direction: json["direction"],
        property: json["property"],
        ignoreCase: json["ignoreCase"],
        nullHandling: json["nullHandling"],
        descending: json["descending"],
        ascending: json["ascending"],
      );

  Map<String, dynamic> toJson() => {
        "direction": direction,
        "property": property,
        "ignoreCase": ignoreCase,
        "nullHandling": nullHandling,
        "descending": descending,
        "ascending": ascending,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap!;
  }
}

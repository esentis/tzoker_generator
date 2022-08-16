import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tzoker_generator/models/last_result.dart';
import 'package:tzoker_generator/models/statistics.dart';
import 'package:tzoker_generator/models/tzoker_response.dart';

String baseUrl = 'https://api.opap.gr';

class Tzoker {
  Tzoker._private();
  static final Tzoker instance = Tzoker._private();

  /// Returns the draws in a range of dates.
  ///
  /// [from] & [to] are `String` with format '2018-06-01' (for June 1st, 2018).
  ///
  /// Maximum range is one month since the results have limit 10 draws per request.
  Future<TzokerResponse?> getDrawsInRange(String from, String to) async {
    final response = await http.get(
      Uri.parse('$baseUrl/draws/v3.0/5104/draw-date/$from/$to/'),
    );
    final Map<String, dynamic> data = jsonDecode(response.body);

    TzokerResponse tzokerResp = TzokerResponse.fromJson(data);
  }

  /// Returns the current minimum amount distributed for 5 + 1.
  Future<double> getJackpot() async {
    final response =
        await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/last/1'));

    final List<dynamic> data = jsonDecode(response.body);

    return data.first['prizeCategories'][0]['minimumDistributed'];
  }

  Future<DateTime> getUpcomingDrawDate() async {
    final response =
        await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/upcoming/1'));

    final List<dynamic> data = jsonDecode(response.body);

    return DateTime.fromMillisecondsSinceEpoch(data.first['drawTime']);
  }

  Future<LastResult> getLastResult() async {
    final response = await http
        .get(Uri.parse('$baseUrl/draws/v3.0/5104/last-result-and-active'));

    final data = jsonDecode(response.body);

    List<dynamic> winningNumbers = data['last']['winningNumbers']['list'];
    int tzoker = data['last']['winningNumbers']['bonus'].first;
    DateTime drawDate =
        DateTime.fromMillisecondsSinceEpoch(data['last']['drawTime']);

    return LastResult(
        date: drawDate,
        tzoker: tzoker,
        winningNumbers: winningNumbers,
        sortedWinningNumbers: winningNumbers..sort());
  }

  Future<Statistics> getStatistics() async {
    final response =
        await http.get(Uri.parse('$baseUrl/games/v1.0/5104/statistics'));
    final Map<String, dynamic> data = jsonDecode(response.body);
    final stats = Statistics.fromJson(data);

    return stats;
  }
}

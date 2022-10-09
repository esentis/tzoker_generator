import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tzoker_generator/constants.dart';
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
  // Future<TzokerResponse?> getDrawsInRange(String from, String to) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/draws/v3.0/5104/draw-date/$from/$to/'),
  //   );
  //   final Map<String, dynamic> data = jsonDecode(response.body);

  //   TzokerResponse tzokerResp = TzokerResponse.fromJson(data);
  // }

  /// Returns the current minimum amount distributed for 5 + 1.
  Future<double> getJackpot() async {
    final response =
        await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/last/1'));

    final List<dynamic> data = jsonDecode(response.body);

    return data.first['prizeCategories'][0]['minimumDistributed'];
  }

  /// Returns the [DateTime] of the upcoming draw.
  Future<DateTime> getUpcomingDrawDate() async {
    final response =
        await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/upcoming/1'));

    final List<dynamic> data = jsonDecode(response.body);

    return DateTime.fromMillisecondsSinceEpoch(data.first['drawTime']);
  }

  /// Returns the latest draw result.
  Future<DrawResult> getLastResult() async {
    final response = await http
        .get(Uri.parse('$baseUrl/draws/v3.0/5104/last-result-and-active'));

    final data = jsonDecode(response.body);

    final List<int> winningNumbers = List<int>.generate(
      data['last']['winningNumbers']['list'].length,
      (index) => data['last']['winningNumbers']['list'][index],
    );

    final int tzoker = data['last']['winningNumbers']['bonus'].first;
    final DateTime drawDate =
        DateTime.fromMillisecondsSinceEpoch(data['last']['drawTime']);

    return DrawResult(
      date: drawDate,
      tzoker: tzoker,
      winningNumbers: winningNumbers,
      drawCount: data['last']['drawId'],
      sortedWinningNumbers: winningNumbers..sort(),
    );
  }

  /// Returns the stats from the OPAP services.
  Future<Statistics> getStatistics() async {
    final response =
        await http.get(Uri.parse('$baseUrl/games/v1.0/5104/statistics'));
    final Map<String, dynamic> data = jsonDecode(response.body);
    final stats = Statistics.fromJson(data);

    return stats;
  }

  /// Returns the stats for a specific draw.
  Future<Statistics> getStatsForDrawCount(int drawCount) async {
    PostgrestResponse<dynamic> response;

    kLog.wtf('Looking stats for $drawCount');

    response = await Supabase.instance.client
        .from('StatHistory')
        .select()
        .eq('drawCount', drawCount)
        .execute();

    final Statistics stats =
        Statistics.fromJson(jsonDecode(response.data[0]['stats']));

    return stats;
  }

  /// Returns the stats for a specific draw.
//   Future<void> getSpecificStat() async {
//     PostgrestResponse<dynamic> response;

//     kLog.wtf('Looking specific stats');

//     response = await Supabase.instance.client.from('StatHistory').select('''
// stats->numb
// ''').execute();

//     kLog.wtf(response.data);
//     // Statistics stats =
//     //     Statistics.fromJson(jsonDecode(response.data[0]['stats']));

//     // return stats;
//   }

  /// Checks whether the stats are already saved in the database.
  Future<bool> checkIfStatsExist(int drawCount) async {
    PostgrestResponse<dynamic> response;

    response = await Supabase.instance.client
        .from('StatHistory')
        .select()
        .eq('drawCount', drawCount)
        .execute();

    if (response.data == null || response.data.isEmpty) {
      return false;
    }
    return true;
  }

  /// Updates the stats in the database.
  Future<void> updateStats(int drawCount, Map<String, dynamic> json) async {
    final exists = await checkIfStatsExist(drawCount);

    if (exists) {
      kLog.w('The current stats are already saved.');
    } else {
      await Supabase.instance.client.from('StatHistory').insert({
        'stats': jsonEncode(json),
        'drawCount': drawCount,
      }).execute();

      kLog.i('Stats for latest draw has been saved.');
    }
  }

  /// Returns all stats from the database.
  Future<void> getAllStatsHistory() async {
    PostgrestResponse<dynamic> response;

    response =
        await Supabase.instance.client.from('StatHistory').select().execute();

    kLog.wtf(response.data);
  }

  /// Returns a [Draw] provided a [drawId]. This call searchs OPAP webservices.
  Future<Draw> getDraw(int drawId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/$drawId'));
    final Map<String, dynamic> data = jsonDecode(response.body);

    return Draw.fromJson(data);
  }

  /// Searchs for draws provided [nums] and/or [tzoker]. Returns a [List] of [Draw].
  Future<List<DrawResult>> getDrawsOfSpecificSequence({
    List<int>? nums,
    int? tzoker,
  }) async {
    final String normalizedNums =
        "{${nums?.map((e) => e)}}".replaceAll("(", '').replaceAll(')', '');

    PostgrestResponse<dynamic> response;

    if (tzoker != null) {
      if (nums != null) {
        response = await Supabase.instance.client
            .from('Draws')
            .select()
            .contains('numbers', normalizedNums)
            .eq('tzoker', '$tzoker')
            .execute();
      } else {
        response = await Supabase.instance.client
            .from('Draws')
            .select()
            .eq('tzoker', '$tzoker')
            .execute();
      }
    } else {
      if (nums != null) {
        response = await Supabase.instance.client
            .from('Draws')
            .select()
            .contains('numbers', normalizedNums)
            .execute();
      } else {
        response = const PostgrestResponse(data: []);
      }
    }

    if (response.data.isNotEmpty) {
      return List<DrawResult>.generate(
        response.data.length,
        (index) => DrawResult.fromJson(
          response.data[index],
        ),
      );
    } else {
      return [];
    }
  }

  /// Checks whether the stats are already saved in the database.
  Future<bool> checkIfDrawExist(int id) async {
    PostgrestResponse<dynamic> response;

    response = await Supabase.instance.client
        .from('Draws')
        .select()
        .eq('id', id)
        .execute();

    if (response.data == null || response.data.isEmpty) {
      return false;
    }
    return true;
  }

  /// Saves a [DrawResult] after first checking if it already exists.
  Future<void> saveDraw(DrawResult draw) async {
    if (await checkIfDrawExist(draw.drawCount)) {
      kLog.w('Draw ${draw.drawCount} is already saved');
    } else {
      await Supabase.instance.client.from('Draws').insert({
        'id': draw.drawCount,
        'drawDate': draw.date.toIso8601String(),
        'tzoker': draw.tzoker,
        'numbers': draw.winningNumbers,
      }).execute();

      kLog.i('Draw ${draw.drawCount} successfully saved');
    }
  }

  /// Returns the color associated with the number.
  Color getColor(int num) {
    if (num >= 1 && num <= 10) {
      return const Color(0xff344ed6);
    }
    if (num > 10 && num <= 20) {
      return const Color(0xff8d0d46);
    }
    if (num >= 21 && num <= 30) {
      return const Color(0xffb9d4ef);
    }
    if (num >= 31 && num <= 40) {
      return const Color(0xffc0e051);
    }
    if (num >= 41 && num <= 45) {
      return const Color(0xff3b6250);
    }
    return Colors.red;
  }

  /// Returns the color to indicate how long is the delay for a number.
  Color getColorOccurence(int delays) {
    if (delays >= 0 && delays <= 2) {
      return const Color(0xff5FD068);
    }
    if (delays > 2 && delays <= 7) {
      return const Color(0xffF5DF99);
    }
    if (delays >= 8 && delays <= 12) {
      return const Color(0xffFF5B00);
    }
    return const Color(0xffFF1E00);
  }
}

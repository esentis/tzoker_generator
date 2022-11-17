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
  final supabase = SupabaseClient(
    'https://qvliopsxcffejpcxxmfb.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2bGlvcHN4Y2ZmZWpwY3h4bWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjAzMjk3MzksImV4cCI6MTk3NTkwNTczOX0.OshaOvSwzZ2Fgtj9kAqL_COmgTfBlnGHmV43EAyDja4',
  );

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
    final response = await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/last/1'));

    final List<dynamic> data = jsonDecode(response.body);

    return data.first['prizeCategories'][0]['minimumDistributed'];
  }

  /// Returns the [DateTime] of the upcoming draw.
  Future<DateTime> getUpcomingDrawDate() async {
    final response = await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/upcoming/1'));

    final List<dynamic> data = jsonDecode(response.body);

    return DateTime.fromMillisecondsSinceEpoch(data.first['drawTime']);
  }

  /// Returns the latest draw result.
  Future<DrawResult> getLastResult() async {
    final response = await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/last-result-and-active'));

    final data = jsonDecode(response.body);

    final List<int> winningNumbers = List<int>.generate(
      data['last']['winningNumbers']['list'].length,
      (index) => data['last']['winningNumbers']['list'][index],
    );

    final int tzoker = data['last']['winningNumbers']['bonus'].first;
    final DateTime drawDate = DateTime.fromMillisecondsSinceEpoch(data['last']['drawTime']);

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
    final response = await http.get(Uri.parse('$baseUrl/games/v1.0/5104/statistics'));
    final Map<String, dynamic> data = jsonDecode(response.body);
    final stats = Statistics.fromJson(data);

    return stats;
  }

  /// Returns the stats for a specific draw.
  Future<Statistics> getStatsForDrawCount(int drawCount) async {
    dynamic response;

    kLog.wtf('Looking stats for $drawCount');

    response = await supabase
        .from(
          'StatHistory',
        )
        .select()
        .eq('drawCount', drawCount);

    final Statistics stats = Statistics.fromJson(
      jsonDecode(
        response[0]['stats'],
      ),
    );

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
    dynamic response;

    response = await supabase.from('StatHistory').select().eq('drawCount', drawCount);

    if (response == null || response.isEmpty) {
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
      await supabase.from('StatHistory').insert({
        'stats': jsonEncode(json),
        'drawCount': drawCount,
      });

      kLog.i('Stats for latest draw has been saved.');
    }
  }

  /// Returns all stats from the database.
  Future<void> getAllStatsHistory() async {
    dynamic response;

    response = await supabase.from('StatHistory').select();

    kLog.wtf(response);
  }

  /// Returns a [Draw] provided a [drawId]. This call searchs OPAP webservices.
  Future<Draw> getDraw(int drawId) async {
    final response = await http.get(Uri.parse('$baseUrl/draws/v3.0/5104/$drawId'));
    final Map<String, dynamic> data = jsonDecode(response.body);

    return Draw.fromJson(data);
  }

  /// Searchs for draws provided [nums] and/or [tzoker]. Returns a [List] of [Draw].
  Future<List<DrawResult>> getDrawsOfSpecificSequence({
    List<int>? nums,
    int? tzoker,
  }) async {
    final String normalizedNums = "{${nums?.map((e) => e)}}".replaceAll("(", '').replaceAll(')', '');

    dynamic response;

    if (tzoker != null) {
      if (nums != null) {
        response = await supabase.from('Draws').select().contains('numbers', normalizedNums).eq('tzoker', '$tzoker');
      } else {
        response = await supabase.from('Draws').select().eq('tzoker', '$tzoker');
      }
    } else {
      if (nums != null) {
        response = await supabase.from('Draws').select().contains('numbers', normalizedNums);
      } else {
        response = const PostgrestResponse(data: [], status: 404);
      }
    }
    kLog.wtf(response);
    if (response.isNotEmpty) {
      return List<DrawResult>.generate(
        response.length,
        (index) => DrawResult.fromJson(
          response[index],
        ),
      );
    } else {
      return [];
    }
  }

  /// Checks whether the stats are already saved in the database.
  Future<bool> checkIfDrawExist(int id) async {
    dynamic response;

    response = await supabase.from('Draws').select().eq('id', id);

    if (response == null || response.isEmpty) {
      return false;
    }
    return true;
  }

  /// Saves a [DrawResult] after first checking if it already exists.
  Future<dynamic> saveDraw(DrawResult draw) async {
    if (await checkIfDrawExist(draw.drawCount)) {
      kLog.w('Draw ${draw.drawCount} is already saved');
    } else {
      kLog.wtf('Saving draw ${draw.drawCount}');
      final res = await supabase.from('Draws').insert({
        'id': draw.drawCount,
        'drawDate': draw.date.toIso8601String(),
        'tzoker': draw.tzoker,
        'numbers': draw.winningNumbers,
      });
      if (res.error != null) {
        kLog.e(res.error);
      } else {
        kLog.i('Draw ${draw.drawCount} added in the database.');
      }
      return res;
    }
  }

  /// Updates Supabase database with missing draws, also updates the stats history of each draw.
  ///
  /// Provide [start] and [end] (both included) draw id (draw count).
  Future<void> updateDatabase({required int start, required int end}) async {
    // Get the latest saved stats from Database
    final tempStats = await getStatsForDrawCount(start - 1).then((value) => value.toJson());

    // We iterate the range of draws we want the stats saved.
    for (int i = start; i <= end; i++) {
      final draw = await getDraw(i);

      await saveDraw(DrawResult.fromDraw(draw));

      for (final Map<String, dynamic> stat in tempStats['numbers']) {
        if (draw.winningNumbers.numbers.contains(stat['number'])) {
          stat['occurrences']++;
          stat['delays'] = 0;
        } else {
          stat['delays']++;
        }
      }

      for (final Map<String, dynamic> stat in tempStats['bonusNumbers']) {
        if (draw.winningNumbers.tzoker.contains(stat['number'])) {
          stat['occurrences']++;
          stat['delays'] = 0;
        } else {
          stat['delays']++;
        }
      }

      tempStats['header']['dateTo'] = draw.drawDate.millisecondsSinceEpoch / 1000;

      tempStats['header']['drawCount'] = i;

      await updateStats(i, tempStats);
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

import 'package:dio/dio.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/tzoker_response.dart';

BaseOptions httpOptions = BaseOptions(
  baseUrl: 'https://api.opap.gr/draws/v3.0/5104/',
  receiveDataWhenStatusError: true,
  connectTimeout: 6 * 1000, // 6 seconds
  receiveTimeout: 6 * 1000, // 6 seconds
);
Dio tzoker = Dio(httpOptions);

class Tzoker {
  Tzoker._private();
  static final Tzoker instance = Tzoker._private();

  /// Returns the draws in a range of dates.
  ///
  /// [from] & [to] are `String` with format '2018-06-01' (for June 1st, 2018).
  ///
  /// Maximum range is one month since the results have limit 10 draws per request.
  Future<TzokerResponse?> getDrawsInRange(String from, String to) async {
    try {
      final response = await tzoker.get(
        'draw-date/$from/$to/',
      );
      final data = response.data.cast<String, dynamic>();

      TzokerResponse tzokerResp = TzokerResponse.fromJson(data);

      return tzokerResp;
    } on DioError catch (e) {
      kLog.e(e.message);
      return null;
    }
  }

  Future<double> getJackpot() async {
    final response = await tzoker.get('/active');
    final data = response.data.cast<String, dynamic>();

    kLog.wtf(data);

    return data['prizeCategories'][0]['jackpot'];
  }
}

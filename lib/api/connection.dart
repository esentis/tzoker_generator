import 'package:dio/dio.dart';
import 'package:tzoker_generator/constants.dart';
import 'package:tzoker_generator/models/tzoker_response.dart';

BaseOptions httpOptions = BaseOptions(
  baseUrl: 'https://api.opap.gr/draws/v3.0/5104/draw-date/',
  receiveDataWhenStatusError: true,
  connectTimeout: 6 * 1000, // 6 seconds
  receiveTimeout: 6 * 1000, // 6 seconds
);
Dio tzoker = Dio(httpOptions);

Future<TzokerResponse?> getTzokerResults(String from, String to) async {
  try {
    final response = await tzoker.get(
      '$from/$to/',
    );
    final data = response.data.cast<String, dynamic>();

    TzokerResponse tzokerResp = TzokerResponse.fromJson(data);

    return tzokerResp;
  } on DioError catch (e) {
    kLog.e(e.message);
    return null;
  }
}

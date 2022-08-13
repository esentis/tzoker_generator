import 'package:logger/logger.dart';

Logger kLog = Logger();

extension DetailedWhere<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K key, V value) f) => Map<K, V>.fromEntries(
        entries.where((entry) => f(entry.key, entry.value)),
      );

  Map<K, V> whereKey(bool Function(K key) f) =>
      {...where((key, value) => f(key))};
  Map<K, V> whereValue(bool Function(V value) f) =>
      {...where((key, value) => f(value))};
}

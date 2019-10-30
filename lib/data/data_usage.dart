import 'dart:math' as Math;

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum DataUnit { B, KB, MB, GB, TB }

class DataAmount {
  final double amount;
  final DataUnit unit;

  const DataAmount(this.amount, this.unit);

  int get bytes => (amount * Math.pow(1000, unit.index)).toInt();

  factory DataAmount.fromBytes(int bytes) {
    if (bytes == null || bytes <= 0) return DataAmount(0, DataUnit.B);

    final int notation = Math.log(bytes) ~/ Math.log(1000);

    return DataAmount(
      bytes / Math.pow(1000, notation),
      DataUnit.values[notation],
    );
  }

  factory DataAmount.parse(String amount, String suffix) {
    final double value = double.parse(amount.replaceAll(',', '.'));
    final int notation = DataUnit.values.indexWhere((unit) => unit.toString().split('.')[1] == suffix.toUpperCase());

    return DataAmount.fromBytes((value * Math.pow(1000, notation)).toInt());
  }

  @override
  String toString() {
    // Double to String without leading zeroes
    final String num = amount.toString().replaceAll(RegExp(r'(\.0+)$|(?<=\.[1-9]+)0+$'), '');
    return '$num${unit.toString().split('.')[1]}';
  }
}

class DataUsage with ChangeNotifier {
  DataAmount _usage;
  DataAmount _limit;
  DateTime _reset;

  DataUsage({DataAmount usage, DataAmount limit, DateTime reset})
      : _usage = usage,
        _limit = limit,
        _reset = reset {
    SharedPreferences.getInstance().then((prefs) {
      save('usage', _usage.bytes);
      save('limit', _limit.bytes);
      save('reset', _reset.millisecondsSinceEpoch);
    });
  }

  factory DataUsage.fromGenerics(int usage, int limit, int reset) {
    return DataUsage(
      usage: usage != null ? DataAmount.fromBytes(usage) : null,
      limit: limit != null ? DataAmount.fromBytes(limit) : null,
      reset: reset != null ? DateTime.fromMillisecondsSinceEpoch(reset) : null,
    );
  }

  factory DataUsage.fromSharedPrefs(SharedPreferences prefs) {
    return DataUsage.fromGenerics(
      prefs.getInt('usage'),
      prefs.getInt('limit'),
      prefs.getInt('reset'),
    );
  }

  bool get hasData => usage != null && limit != null && reset != null;

  DataAmount get usage => _usage;
  set usage(DataAmount newUsage) {
    _usage = newUsage;
    notifyListeners();
    save('usage', _usage.bytes);
  }

  DataAmount get limit => _limit;
  set limit(DataAmount newLimit) {
    _limit = newLimit;
    notifyListeners();
    save('limit', _limit.bytes);
  }

  double get percent => usage.bytes != 0 && limit.bytes != 0 ? usage.bytes / limit.bytes : 0;

  DateTime get reset => _reset;
  set reset(DateTime newReset) {
    _reset = newReset;
    notifyListeners();
    save('reset', _reset.millisecondsSinceEpoch);
  }

  DateTime get start => DateTime(reset.year, reset.month - 1, reset.day);

  double get datePercent {
    print(DateTime.now().millisecondsSinceEpoch - this.start.millisecondsSinceEpoch);

    return (DateTime.now().millisecondsSinceEpoch - this.start.millisecondsSinceEpoch) /
        (this.reset.millisecondsSinceEpoch - this.start.millisecondsSinceEpoch);
  }

  void save(String key, num value) async {
    final prefs = await SharedPreferences.getInstance();
    if (num is int) {
      prefs.setInt(key, value);
    } else if (num is double) {
      prefs.setDouble(key, value);
    }
  }
}

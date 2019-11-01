import 'dart:math' as Math;

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

class DataUsage {
  final DataAmount usage;
  final DataAmount limit;
  final DateTime reset;

  const DataUsage({this.usage, this.limit, this.reset});

  factory DataUsage.fromJSON(Map<String, dynamic> json) {
    return DataUsage(
      usage: DataAmount.fromBytes(json['usage']),
      limit: DataAmount.fromBytes(json['limit']),
      reset: DateTime.fromMillisecondsSinceEpoch(json['reset']),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'usage': usage.bytes,
      'limit': limit.bytes,
      'reset': reset.millisecondsSinceEpoch,
    };
  }

  bool get hasData => usage != null && limit != null && reset != null;

  double get percent => usage.bytes != 0 && limit.bytes != 0 ? usage.bytes / limit.bytes : 0;

  DateTime get start => DateTime(reset.year, reset.month - 1, reset.day);

  double get datePercent =>
      (DateTime.now().millisecondsSinceEpoch - this.start.millisecondsSinceEpoch) /
      (this.reset.millisecondsSinceEpoch - this.start.millisecondsSinceEpoch);
}

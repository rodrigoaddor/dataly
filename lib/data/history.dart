import 'package:dataly/data/data_usage.dart';

class DataHistory {
  final DataUsage data;
  final DateTime date;

  DataHistory({this.data, DateTime date}) : this.date = date ?? DateTime.now();

  factory DataHistory.fromJSON(Map<String, dynamic> json) {
    return DataHistory(
      data: DataUsage.fromJSON(json['data']),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'])
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'data': this.data.toJSON(),
      'date': this.date.millisecondsSinceEpoch,
    };
  }
}

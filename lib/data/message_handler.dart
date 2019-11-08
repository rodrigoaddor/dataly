import 'package:dataly/data/carrier.dart';
import 'package:dataly/data/data_usage.dart';

class MessageHandler {
  final Carrier carrier;

  MessageHandler({this.carrier});

  DataUsage handle(String message) {
    final match = carrier.regex.firstMatch(message);
    if (match == null) throw FormatException('Message has no match.');

    final List<int> date = match.namedGroup('date').split('/').map((i) => int.parse(i)).toList(growable: false);

    return DataUsage(
      usage: DataAmount.parse(match.namedGroup('usage'), match.namedGroup('usageUnit')),
      limit: DataAmount.parse(match.namedGroup('limit'), match.namedGroup('limitUnit')),
      reset: DateTime(date[2], date[1], date[0]),
    );
  }
}

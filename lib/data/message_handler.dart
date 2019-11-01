import 'package:dataly/data/data_usage.dart';

enum Carrier { TIM }

final Map<Carrier, RegExp> parsers = {
  Carrier.TIM: RegExp(
    r'[^\d,]+(?<usage>[\d,]+)(?<usageUnit>GB|MB)[^\d,]+(?<limit>[\d,]+)(?<limitUnit>GB|MB)[^\d/]+(?<date>(?:\d{1,4}\/?)+)',
  )
};

class MessageHandler {
  final Carrier carrier;

  MessageHandler({this.carrier});

  RegExp get parser => parsers[this.carrier];

  DataUsage handle(String message) {
    final match = parser.firstMatch(message);
    if (match == null) throw FormatException('Message has no match.');

    final List<int> date = match.namedGroup('date').split('/').map((i) => int.parse(i)).toList(growable: false);

    return DataUsage(
      usage: DataAmount.parse(match.namedGroup('usage'), match.namedGroup('usageUnit')),
      limit: DataAmount.parse(match.namedGroup('limit'), match.namedGroup('limitUnit')),
      reset: DateTime(date[2], date[1], date[0]),
    );
  }
}

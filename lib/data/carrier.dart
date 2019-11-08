import 'package:sms_maintained/sms.dart';

const List<Carrier> Carriers = [
  Carrier(
    name: 'TIM',
    number: '4141',
    message: 'consumoweb',
    regex:
        r'[^\d,]+(?<usage>[\d,]+)(?<usageUnit>GB|MB)[^\d,]+(?<limit>[\d,]+)(?<limitUnit>GB|MB)[^\d/]+(?<date>(?:\d{1,4}\/?)+)',
  )
];

class Carrier {
  final String name;
  final String number;
  final String message;
  final String _regex;

  const Carrier({this.name, this.number, this.message, String regex}) : this._regex = regex;

  RegExp get regex => RegExp(this._regex);
  SmsMessage get smsMessage => SmsMessage(this.number, this.message);
}

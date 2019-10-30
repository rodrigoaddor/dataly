import 'package:dataly/data/data_usage.dart';
import 'package:dataly/data/patterns.dart';
import 'package:flutter/material.dart';

import 'package:dataly/page/home.dart';
import 'package:dataly/data/pref_notifier.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_maintained/sms.dart';

DataUsage dataUsage;

bool handleMessage(String message) {
  final match = tim.firstMatch(message);
  if (match == null || match.groupCount < 5) return false;

  final List<int> date = match.group(5).split('/').map((i) => int.parse(i)).toList(growable: false);

  dataUsage.usage = DataAmount.parse(match.group(1), match.group(2));
  dataUsage.limit = DataAmount.parse(match.group(3), match.group(4));
  dataUsage.reset = DateTime(date[2], date[1], date[0]);

  return true;
}

void main() async {
  final prefs = await SharedPreferences.getInstance();

  dataUsage = DataUsage.fromSharedPrefs(prefs);

  List<SingleChildCloneableWidget> providers = [
    ChangeNotifierProvider<PrefNotifier<ThemeMode>>.value(
      value: PrefNotifier(
        name: 'theme',
        values: ThemeMode.values,
        defaultValue: ThemeMode.light,
        prefs: prefs,
      ),
    ),
    ChangeNotifierProvider<DataUsage>.value(
      value: dataUsage,
    ),
  ];

  SmsReceiver().onSmsReceived.listen((message) {
    if (message.sender == '4141') handleMessage(message.body);
  });

  runApp(MultiProvider(providers: providers, child: DatalyApp()));
}

class DatalyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dataly',
      themeMode: Provider.of<PrefNotifier<ThemeMode>>(context).value,
      home: HomePage(),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:dataly/data/app_state.dart';
import 'package:dataly/data/message_handler.dart';
import 'package:dataly/page/home.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_maintained/sms.dart';

AppState appState;

void main() async {
  final prefs = await SharedPreferences.getInstance();

  appState = AppState.fromPrefs(prefs);

  List<SingleChildCloneableWidget> providers = [
    ChangeNotifierProvider<AppState>.value(
      value: appState,
    ),
  ];

  SmsReceiver().onSmsReceived.listen((message) {
    if (message.sender == '4141') {
      try {
        appState.data = MessageHandler(carrier: appState.carrier).handle(message.body);
      } on FormatException catch (_) {}
    }
  });

  runApp(MultiProvider(providers: providers, child: DatalyApp()));
}

class DatalyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dataly',
      home: HomePage(),
      theme: ThemeData.light(),
    );
  }
}

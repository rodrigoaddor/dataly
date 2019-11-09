import 'dart:async';

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

  StreamSubscription<SmsMessage> smsSubscription;
  void updateSmsSubscription() {
    if (smsSubscription != null) smsSubscription.cancel();
    smsSubscription = SmsReceiver().onSmsReceived.listen((message) {
      if (message.sender == appState.carrier.number) {
        try {
          appState.data = MessageHandler(carrier: appState.carrier).handle(message.body);
          if (appState.updating != null) appState.updating.complete();
        } on FormatException catch (_) {}
      }
    });
  }

  appState.addListener(updateSmsSubscription);
  updateSmsSubscription();

  List<SingleChildCloneableWidget> providers = [
    ChangeNotifierProvider<AppState>.value(
      value: appState,
    ),
  ];

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

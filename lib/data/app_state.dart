import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dataly/data/message_handler.dart';
import 'package:dataly/data/data_usage.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> getPrefs() => SharedPreferences.getInstance();

class AppState with ChangeNotifier {
  DataUsage _data;
  Carrier _carrier;

  AppState({DataUsage data, Carrier carrier})
      : this._data = data,
        this._carrier = carrier;

  factory AppState.fromPrefs(SharedPreferences prefs) {
    return AppState(
      data: prefs.containsKey('data') ? DataUsage.fromJSON(jsonDecode(prefs.getString('data'))) : null,
      carrier: prefs.containsKey('carrier')
          ? Carrier.values.firstWhere((carrier) => carrier.toString().split('.')[1] == prefs.getString('carrier'))
          : null,
    );
  }

  bool get hasDataUsage => this._data != null;
  DataUsage get data => this._data;
  set data(DataUsage newData) {
    this._data = newData;
    notifyListeners();
    getPrefs().then((prefs) => prefs.setString('data', jsonEncode(this._data.toJSON())));
  }

  String get carrierName => this._carrier.toString().split('.')[1];
  Carrier get carrier => this._carrier;
  set carrier(Carrier newCarrier) {
    this._carrier = newCarrier;
    notifyListeners();
    getPrefs().then((prefs) => prefs.setString('carrier', this.carrierName));
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dataly/data/carrier.dart';
import 'package:dataly/data/data_usage.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum UpdateStatus {
  WAITING,
  CANCELLED,
  CANCELLED_BY_USER,
}

Future<SharedPreferences> getPrefs() => SharedPreferences.getInstance();

class AppState with ChangeNotifier {
  DataUsage _data;
  Carrier _carrier;
  Completer<UpdateStatus> _updating;
  ThemeMode _theme;

  AppState({DataUsage data, Carrier carrier, ThemeMode theme})
      : this._data = data,
        this._carrier = carrier,
        this._theme = theme;

  factory AppState.fromPrefs(SharedPreferences prefs) {
    return AppState(
      data: prefs.containsKey('data') ? DataUsage.fromJSON(jsonDecode(prefs.getString('data'))) : null,
      carrier: prefs.containsKey('carrier')
          ? Carriers.firstWhere((carrier) => carrier.name == prefs.getString('carrier'))
          : null,
      theme: prefs.containsKey('theme') ? ThemeMode.values[prefs.getInt('theme')] : ThemeMode.light,
    );
  }

  bool get hasDataUsage => this._data != null;
  DataUsage get data => this._data;
  set data(DataUsage newData) {
    this._data = newData;
    notifyListeners();
    getPrefs().then((prefs) => prefs.setString('data', jsonEncode(this._data.toJSON())));
  }

  Carrier get carrier => this._carrier;
  set carrier(Carrier newCarrier) {
    this._carrier = newCarrier;
    notifyListeners();
    getPrefs().then((prefs) => prefs.setString('carrier', this._carrier.name));
  }

  Completer<UpdateStatus> get updating => this._updating;
  set updating(Completer<UpdateStatus> completer) {
    this._updating = completer;
    notifyListeners();
  }

  ThemeMode get theme => this._theme;
  set theme(ThemeMode newTheme) {
    this._theme = newTheme;
    print(this._theme);
    notifyListeners();
    getPrefs().then((prefs) => prefs.setInt('theme', this._theme.index));
  }
}

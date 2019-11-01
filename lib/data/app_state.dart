import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dataly/data/data_usage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> getPrefs() => SharedPreferences.getInstance();

class AppState with ChangeNotifier {
  DataUsage _data;

  AppState({DataUsage data}) : this._data = data;

  factory AppState.fromPrefs(SharedPreferences prefs) {
    return AppState(
      data: prefs.containsKey('data') ? DataUsage.fromJSON(jsonDecode(prefs.getString('data'))) : null,
    );
  }

  bool get hasDataUsage => this._data != null;
  DataUsage get data => this._data;
  set data(DataUsage newData) {
    this._data = newData;
    notifyListeners();
    getPrefs().then((prefs) => prefs.setString('data', jsonEncode(this._data.toJSON())));
  }
}

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dataly/data/history.dart';
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
  List<DataHistory> _history;

  AppState({DataUsage data, Carrier carrier, ThemeMode theme, List<DataHistory> history})
      : this._data = data,
        this._carrier = carrier,
        this._theme = theme,
        this._history = history;

  factory AppState.fromPrefs(SharedPreferences prefs) {
    return AppState(
      data: prefs.containsKey('data') ? DataUsage.fromJSON(jsonDecode(prefs.getString('data'))) : null,
      carrier: prefs.containsKey('carrier')
          ? Carriers.firstWhere((carrier) => carrier.name == prefs.getString('carrier'))
          : null,
      theme: prefs.containsKey('theme') ? ThemeMode.values[prefs.getInt('theme')] : ThemeMode.light,
      history: prefs.containsKey('history')
          ? prefs.getStringList('history').map((entry) => DataHistory.fromJSON(jsonDecode(entry))).toList()
          : [],
    );
  }

  bool get hasDataUsage => this._data != null;
  DataUsage get data => this._data;
  set data(DataUsage newData) {
    this._data = newData;
    notifyListeners();
    addToHistory(this._data);
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

  void saveHistory() async {
    final prefs = await getPrefs();
    prefs.setStringList(
      'history',
      this._history.map((entry) => jsonEncode(entry.toJSON())).toList(growable: false),
    );
  }

  UnmodifiableListView<DataHistory> get history => UnmodifiableListView(this._history);
  bool addToHistory(DataUsage usage, [DateTime date]) {
    if (this._history.length == 0 || this._history.last.data.usage.bytes != usage.usage.bytes) {
      this._history.add(DataHistory(data: usage, date: date));
      if (date != null && this._history.last.date.millisecondsSinceEpoch < date.millisecondsSinceEpoch) {
        this._history.sort((a, b) => a.date.millisecondsSinceEpoch.compareTo(b.date.millisecondsSinceEpoch));
      }
      notifyListeners();
      saveHistory();
      return true;
    } else {
      return false;
    }
  }

  bool removeFromHistory(int index) {
    if (this._history.length >= index + 1) {
      this._history.removeAt(index);
      saveHistory();
      return true;
    } else {
      return false;
    }
  }
}

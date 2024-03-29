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

  factory AppState.fromJSON(Map<String, dynamic> json) {
    return AppState(
      data: json.containsKey('data') ? DataUsage.fromJSON(jsonDecode(json['data'])) : null,
      carrier: json.containsKey('carrier') ? Carriers.firstWhere((carrier) => carrier.name == json['carrier']) : null,
      theme: json.containsKey('theme') ? ThemeMode.values[json['theme']] : ThemeMode.light,
      history: json.containsKey('history')
          ? json['history'].map((entry) => DataHistory.fromJSON(jsonDecode(entry))).toList<DataHistory>()
          : [],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'data': this._data.toJSON(),
      'carrier': this._carrier.name,
      'theme': this._theme.index,
      'history': this._history.map((entry) => jsonEncode(entry.toJSON())).toList(growable: false)
    };
  }

  void updateFromJSON(Map<String, dynamic> json) {
    if (json.containsKey('data')) this.data = DataUsage.fromJSON(json['data']);
    if (json.containsKey('carrier')) this.carrier = Carriers.firstWhere((carrier) => carrier.name == json['carrier']);
    if (json.containsKey('theme')) this.theme = ThemeMode.values[json['theme']];
    if (json.containsKey('history')) {
      this._history = json['history'].map<DataHistory>((entry) => DataHistory.fromJSON(jsonDecode(entry))).toList();
      saveHistory();
    }
    print('Updated with JSON: $json');

    notifyListeners();
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
  void addToHistory(DataUsage usage, [DateTime date, int index]) {
    this._history.insert(index ?? this._history.length, DataHistory(data: usage, date: date));
    notifyListeners();
    saveHistory();
  }

  void removeFromHistory(int index) {
    if (this._history.length >= index + 1) {
      this._history.removeAt(index);
      notifyListeners();
      saveHistory();
    }
  }
}

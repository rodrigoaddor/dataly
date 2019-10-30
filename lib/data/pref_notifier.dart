import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefNotifier<T> with ChangeNotifier {
  static SharedPreferences prefs;

  final String name;
  final List<T> values;
  final int defaultIndex;

  PrefNotifier({
    @required this.name,
    @required this.values,
    T defaultValue,
    SharedPreferences prefs,
  }) : this.defaultIndex = defaultValue != null ? values.indexOf(defaultValue) : -1 {
    if (prefs != null) {
      PrefNotifier.prefs = prefs;
    } else if (PrefNotifier.prefs != null) {
      throw Exception('PrefNotifier created with no existing SharedPreferences instance.');
    }
  }

  T get value {
    final index = PrefNotifier.prefs.getInt(this.name) ?? this.defaultIndex;
    if (index == null) throw new Exception('PrefNotifier found no saved or default value for ${this.name}');
    return this.values[index];
  }

  set value(T value) {
    prefs.setInt(name, this.values.indexOf(value));
    notifyListeners();
  }
}

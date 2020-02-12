import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeChanger(this._themeMode);
  getTheme() => _themeMode;
  setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

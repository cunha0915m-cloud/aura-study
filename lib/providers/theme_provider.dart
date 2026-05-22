import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestão de tema claro/escuro com persistência local.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('themeMode');
    if (v == 'dark') _themeMode = ThemeMode.dark;
    if (v == 'light') _themeMode = ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggle() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}

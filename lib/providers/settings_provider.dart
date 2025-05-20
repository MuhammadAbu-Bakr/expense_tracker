import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _currencyKey = 'currency';
  static const String _isDarkModeKey = 'isDarkMode';

  late SharedPreferences _prefs;
  String _currency = 'USD';
  bool _isDarkMode = false;

  String get currency => _currency;
  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currency = _prefs.getString(_currencyKey) ?? 'USD';
    _isDarkMode = _prefs.getBool(_isDarkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await _prefs.setString(_currencyKey, currency);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_isDarkModeKey, _isDarkMode);
    notifyListeners();
  }

  String formatAmount(double amount) {
    switch (_currency) {
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      case 'PKR':
        return '₨${amount.toStringAsFixed(2)}';
      case 'USD':
      default:
        return '\$${amount.toStringAsFixed(2)}';
    }
  }
}

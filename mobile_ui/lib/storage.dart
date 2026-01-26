import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesInstance {
  static late final SharedPreferences _storage;
  SharedPreferences get prefs => _storage;

  static final SharedPreferencesInstance _instance = SharedPreferencesInstance._internal();

  SharedPreferencesInstance._internal();

  factory SharedPreferencesInstance() => _instance;

  static initialize() async {
    _storage = await SharedPreferences.getInstance();
  }
}

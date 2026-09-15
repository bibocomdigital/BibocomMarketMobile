import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool getBool(String key) => _prefs.getBool(key) ?? false;

  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}

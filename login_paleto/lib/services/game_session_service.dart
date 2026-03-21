import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_save.dart';

class GameSessionService {
  GameSessionService._();

  static const String _loggedUserKey = 'logged_user';
  static const String _guestSaveKey = 'game_save_guest';

  static String _saveKeyForEmail(String email) =>
      'game_save_${email.toLowerCase()}';

  static Future<String?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedUserKey);
  }

  static Future<void> setLoggedUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedUserKey, email.toLowerCase());
  }

  static Future<void> clearLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedUserKey);
  }

  static Future<GameSave?> loadSavedGameForUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_saveKeyForEmail(email));
    if (payload == null || payload.isEmpty) {
      return null;
    }

    return GameSave.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  static Future<void> saveGameForUser(String email, GameSave save) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKeyForEmail(email), jsonEncode(save.toJson()));
  }

  static Future<GameSave?> loadSavedGameFromCurrentSession() async {
    final email = await getLoggedUser();
    if (email == null || email.isEmpty) {
      return null;
    }
    return loadSavedGameForUser(email);
  }

  static Future<void> saveCurrentSessionGame(GameSave save) async {
    final email = await getLoggedUser();
    if (email == null || email.isEmpty) {
      return;
    }
    await saveGameForUser(email, save);
  }

  static Future<void> saveGuestGame(GameSave save) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestSaveKey, jsonEncode(save.toJson()));
  }

  static Future<GameSave?> loadGuestGame() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_guestSaveKey);
    if (payload == null || payload.isEmpty) {
      return null;
    }

    return GameSave.fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  static Future<void> clearGuestGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestSaveKey);
  }
}

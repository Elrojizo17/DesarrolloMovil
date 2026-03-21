import 'package:flutter/foundation.dart';

import '../models/game_save.dart';
import '../services/game_session_service.dart';

class Amalgam {
  final int id;
  final String name;
  final int level;
  final double maxHealth;
  double currentHealth;
  final bool isElite;

  Amalgam({
    required this.id,
    required this.name,
    required this.level,
    required this.maxHealth,
    this.isElite = false,
  }) : currentHealth = maxHealth;

  bool get isDefeated => currentHealth <= 0;

  void takeDamage(double damage) {
    currentHealth = (currentHealth - damage).clamp(0, maxHealth);
  }

  void heal(double amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
  }
}

class GameProvider extends ChangeNotifier {
  GameSave _gameSave = GameSave.newGame();
  Amalgam? _currentAmalgam;
  String _userEmail = '';
  bool _isGuestMode = false;

  // Getters
  GameSave get gameSave => _gameSave;
  Amalgam? get currentAmalgam => _currentAmalgam;
  String get userEmail => _userEmail;
  bool get isGuestMode => _isGuestMode;

  // Constantes
  static const int maxLevelGuest = 5;
  static const int maxLevelNormal = 100;

  int get levelLimit => _isGuestMode ? maxLevelGuest : maxLevelNormal;
  bool get canLevelUp => _gameSave.currentLevel < levelLimit;

  GameProvider({
    required GameSave initialSave,
    required String userEmail,
    required bool isGuestMode,
  }) {
    _gameSave = initialSave;
    _userEmail = userEmail;
    _isGuestMode = isGuestMode;
    _spawnNextAmalgam();
  }

  void _spawnNextAmalgam() {
    final level = _gameSave.currentLevel;
    final isElite = level > 10 && level % 5 == 0;
    final name = _getAmalgamName(level, isElite);
    final maxHealth = 50.0 + (level * 10.0) + (isElite ? 100.0 : 0);

    _currentAmalgam = Amalgam(
      id: level,
      name: name,
      level: level,
      maxHealth: maxHealth,
      isElite: isElite,
    );
  }

  String _getAmalgamName(int level, bool isElite) {
    final prefix = isElite ? '⭐ ' : '';
    if (level <= 5) return '${prefix}Masa de Pan';
    if (level <= 10) return '${prefix}Puré Corrupto';
    if (level <= 20) return '${prefix}Caldo Oscuro';
    if (level <= 30) return '${prefix}Amalgama Frito';
    if (level <= 50) return '${prefix}Bestia de Especies';
    if (level <= 75) return '${prefix}Técnica Prohibida';
    return '${prefix}Señor de la Amalgama';
  }

  Future<void> tapAttack() async {
    if (_currentAmalgam == null) return;

    final baseDamage = 10.0 + (_gameSave.currentLevel * 2);
    final isCrit = DateTime.now().millisecond % 20 == 0;
    final damage = isCrit ? baseDamage * 2 : baseDamage;

    _currentAmalgam!.takeDamage(damage);

    if (_currentAmalgam!.isDefeated) {
      await _defeatAmalgam();
    }

    notifyListeners();
  }

  Future<void> _defeatAmalgam() async {
    final goldReward = (50.0 + (_gameSave.currentLevel * 10)).toInt();
    final fragmentReward = (_gameSave.currentLevel / 5).ceil().toDouble();

    _gameSave = _gameSave.copyWith(
      gold: _gameSave.gold + goldReward,
      knifeFragments: _gameSave.knifeFragments + fragmentReward,
    );

    await _saveGameIfNotGuest();
    notifyListeners();
  }

  Future<void> levelUp() async {
    if (!canLevelUp) return;

    _gameSave = _gameSave.copyWith(
      currentLevel: _gameSave.currentLevel + 1,
    );

    _spawnNextAmalgam();
    await _saveGameIfNotGuest();
    notifyListeners();
  }

  Future<void> _saveGameIfNotGuest() async {
    if (_isGuestMode) {
      await GameSessionService.saveGuestGame(_gameSave);
    } else {
      await GameSessionService.saveGameForUser(_userEmail, _gameSave);
    }
  }

  void addGold(double amount) {
    _gameSave = _gameSave.copyWith(
      gold: _gameSave.gold + amount,
    );
    notifyListeners();
  }

  void addFragments(double amount) {
    _gameSave = _gameSave.copyWith(
      knifeFragments: _gameSave.knifeFragments + amount,
    );
    notifyListeners();
  }

  void addRestartToken() {
    _gameSave = _gameSave.copyWith(
      restartTokens: _gameSave.restartTokens + 1,
    );
    notifyListeners();
  }
}

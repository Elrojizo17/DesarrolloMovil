import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/game_constants.dart';
import '../models/battle_character.dart';
import '../models/battle_state.dart';
import '../widgets/compact_health_bar.dart';
import '../widgets/chef_character.dart';
import '../widgets/enemy_character.dart';

class BattleGameScreen extends StatefulWidget {
  final BattleCharacter chef;
  final BattleCharacter enemy;

  const BattleGameScreen({super.key, required this.chef, required this.enemy});

  @override
  State<BattleGameScreen> createState() => _BattleGameScreenState();
}

class _BattleGameScreenState extends State<BattleGameScreen>
    with TickerProviderStateMixin {
  late BattleState battleState;
  late AnimationController _gameLoopController;
  final Random _random = Random();

  // Gameplay constants
  static const double _chefMoveSpeed = 0.028;
  static const double _enemyHitZonePx = 120;
  static const double _enemyBaseDamage = 8;
  static const double _enemyBonusDamage = 8;
  static const double _chefBaseDamage = 8;
  static const double _chefBonusDamage = 14;
  static const Duration _enemyTelegraphDuration = Duration(milliseconds: 900);
  static const Duration _enemyStrikeDuration = Duration(milliseconds: 240);
  static const Duration _enemyAttackCooldown = Duration(milliseconds: 1600);
  static const Duration _chefAttackCooldown = Duration(milliseconds: 280);
  static const Duration _comboWindow = Duration(milliseconds: 700);

  // Touch input
  bool _touchingLeft = false;
  bool _touchingRight = false;
  bool _isAttacking = false;

  // Runtime state
  double _arenaMaxOffsetPx = 140;
  DateTime _nextEnemyAttackAt = DateTime.now();
  DateTime? _enemyTelegraphEndsAt;
  DateTime? _enemyAttackEndsAt;
  DateTime? _lastChefAttackAt;
  int _chefCombo = 0;
  bool _enemyStrikeResolved = false;
  double _enemyTelegraphProgress = 0;
  double _enemyTargetXNorm = 0;
  double? _lockedEnemyTargetXNorm;

  // Damage display
  String? _lastChefDamage;
  String? _lastEnemyDamage;
  bool _showChefDamage = false;
  bool _showEnemyDamage = false;

  @override
  void initState() {
    super.initState();
    battleState = BattleState(chef: widget.chef, enemy: widget.enemy);

    // Game loop ~60fps
    _gameLoopController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    _nextEnemyAttackAt = DateTime.now().add(
      _enemyAttackCooldown + _nextJitter(),
    );

    _gameLoopController.addListener(_gameLoop);
  }

  Duration _nextJitter() => Duration(milliseconds: 200 + _random.nextInt(500));

  double _chefCenterDistancePx() =>
      battleState.chefPositionX * _arenaMaxOffsetPx;

  void _startEnemyTelegraph(DateTime now) {
    battleState.status = BattleStatus.enemyAttacking;
    _enemyStrikeResolved = false;
    _enemyTelegraphProgress = 0;
    _enemyTargetXNorm = battleState.chefPositionX;
    _lockedEnemyTargetXNorm = null;
    _enemyTelegraphEndsAt = now.add(_enemyTelegraphDuration);
    _enemyAttackEndsAt = _enemyTelegraphEndsAt!.add(_enemyStrikeDuration);
  }

  void _resolveEnemyStrike(double targetXNorm) {
    final chefX = _chefCenterDistancePx();
    final targetX = targetXNorm * _arenaMaxOffsetPx;
    final distance = (chefX - targetX).abs();
    final hitRadius = _enemyHitZonePx / 2;
    if (distance > hitRadius) {
      return;
    }

    final proximity = (1 - (distance / hitRadius)).clamp(0.0, 1.0);
    final damage = _enemyBaseDamage + (_enemyBonusDamage * proximity);

    battleState.chef.takeDamage(damage);
    _lastEnemyDamage = damage.toStringAsFixed(0);
    _showEnemyDamage = true;

    Future.delayed(const Duration(milliseconds: 480), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showEnemyDamage = false;
      });
    });

    if (battleState.chef.currentHealth <= 0) {
      _gameLoopController.stop();
    }
  }

  void _updateEnemyAttack(DateTime now) {
    if (_enemyTelegraphEndsAt == null) {
      if (!now.isBefore(_nextEnemyAttackAt)) {
        _startEnemyTelegraph(now);
      }
      return;
    }

    final msLeft = _enemyTelegraphEndsAt!.difference(now).inMilliseconds;
    _enemyTelegraphProgress =
        (1 - (msLeft / _enemyTelegraphDuration.inMilliseconds)).clamp(0.0, 1.0);

    if (!_enemyStrikeResolved) {
      // Follow chef movement while charging attack.
      _enemyTargetXNorm =
          (_enemyTargetXNorm * 0.72) + (battleState.chefPositionX * 0.28);
    }

    if (!_enemyStrikeResolved && !now.isBefore(_enemyTelegraphEndsAt!)) {
      _enemyStrikeResolved = true;
      _lockedEnemyTargetXNorm = _enemyTargetXNorm;
    }

    if (_enemyAttackEndsAt != null && !now.isBefore(_enemyAttackEndsAt!)) {
      _resolveEnemyStrike(_lockedEnemyTargetXNorm ?? _enemyTargetXNorm);
      _enemyTelegraphEndsAt = null;
      _enemyAttackEndsAt = null;
      _enemyTelegraphProgress = 0;
      _lockedEnemyTargetXNorm = null;
      if (battleState.status == BattleStatus.enemyAttacking) {
        battleState.status = BattleStatus.idle;
      }
      _nextEnemyAttackAt = now.add(_enemyAttackCooldown + _nextJitter());
    }
  }

  void _gameLoop() {
    if (!mounted || battleState.isGameOver) return;

    setState(() {
      // Update chef position
      if (_touchingLeft) {
        battleState.chefPositionX = (battleState.chefPositionX - _chefMoveSpeed)
            .clamp(-1.0, 1.0);
      }
      if (_touchingRight) {
        battleState.chefPositionX = (battleState.chefPositionX + _chefMoveSpeed)
            .clamp(-1.0, 1.0);
      }

      _updateEnemyAttack(DateTime.now());

      // Check game over
      if (battleState.chef.currentHealth <= 0 ||
          battleState.enemy.currentHealth <= 0) {
        _gameLoopController.stop();
      }
    });
  }

  void _chefAttack() {
    if (_isAttacking || battleState.isGameOver) return;

    final now = DateTime.now();
    if (_lastChefAttackAt != null &&
        now.difference(_lastChefAttackAt!) < _chefAttackCooldown) {
      return;
    }

    if (_lastChefAttackAt != null &&
        now.difference(_lastChefAttackAt!) <= _comboWindow) {
      _chefCombo = (_chefCombo + 1).clamp(1, 4);
    } else {
      _chefCombo = 1;
    }
    _lastChefAttackAt = now;

    _isAttacking = true;
    setState(() {
      battleState.status = BattleStatus.chefAttacking;
    });

    // Hit depends on real distance, not a fixed timer.
    final distance = _chefCenterDistancePx().abs();
    final reachPx = (_arenaMaxOffsetPx * 1.1).clamp(160.0, 320.0);
    if (distance <= reachPx) {
      final proximity = (1 - (distance / reachPx)).clamp(0.0, 1.0);
      final comboBonus = ((_chefCombo - 1) * 0.18).clamp(0.0, 0.54);
      final damage =
          (_chefBaseDamage + (_chefBonusDamage * proximity)) * (1 + comboBonus);
      battleState.enemy.takeDamage(damage);

      // Show damage
      _showChefDamage = true;
      _lastChefDamage = damage.toStringAsFixed(0);

      if (battleState.enemy.currentHealth <= 0) {
        _gameLoopController.stop();
      }

      // Reset damage display
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showChefDamage = false;
          });
        }
      });
    }

    // Reset attack state
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() {
          if (battleState.status == BattleStatus.chefAttacking) {
            battleState.status = BattleStatus.idle;
          }
          _isAttacking = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(GameConstants.darkBackground),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final shortestSide = min(screenWidth, screenHeight);

            final hudHeight = (screenHeight * 0.14).clamp(88.0, 136.0);
            final controlsHeight = (screenHeight * 0.28).clamp(190.0, 275.0);
            final arenaHeight = max(
              220.0,
              screenHeight - hudHeight - controlsHeight,
            );

            final enemySize = (shortestSide * 0.28).clamp(96.0, 166.0);
            final chefSize = (shortestSide * 0.26).clamp(94.0, 154.0);
            final attackButtonHeight = (controlsHeight * 0.34).clamp(
              58.0,
              90.0,
            );
            final moveButtonHeight = (controlsHeight * 0.26).clamp(52.0, 82.0);
            final moveIconSize = (shortestSide * 0.088).clamp(24.0, 36.0);
            final hitZoneWidth = min(screenWidth - 26, _enemyHitZonePx);

            _arenaMaxOffsetPx = max(
              72.0,
              (screenWidth / 2) - (chefSize / 2) - 14,
            );

            final targetXNorm = _lockedEnemyTargetXNorm ?? _enemyTargetXNorm;
            final targetOffsetX = targetXNorm * _arenaMaxOffsetPx;

            return Column(
              children: [
                SizedBox(
                  height: hudHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: CompactHealthBar(
                            name: battleState.enemy.name,
                            currentHealth: battleState.enemy.currentHealth,
                            maxHealth: battleState.enemy.maxHealth,
                            isPlayer: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CompactHealthBar(
                            name: 'Chef',
                            currentHealth: battleState.chef.currentHealth,
                            maxHealth: battleState.chef.maxHealth,
                            isPlayer: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: arenaHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Game over overlay
                      if (battleState.isGameOver)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            color: Colors.black.withAlpha(220),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    battleState.chefWon
                                        ? Icons.celebration
                                        : Icons.sentiment_very_dissatisfied,
                                    size: 80,
                                    color: battleState.chefWon
                                        ? Colors.green[400]
                                        : Colors.red[400],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    battleState.chefWon
                                        ? '¡VICTORIA!'
                                        : '¡DERROTA!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          color: battleState.chefWon
                                              ? Colors.green[400]
                                              : Colors.red[400],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    battleState.chefWon
                                        ? 'Enemigo derrotado'
                                        : 'Has sido derrotado',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('Volver'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange[700],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Enemy at top
                      Positioned(
                        top: arenaHeight * 0.06,
                        child: EnemyCharacter(
                          name: battleState.enemy.name,
                          isAttacking:
                              battleState.status == BattleStatus.enemyAttacking,
                          size: enemySize,
                        ),
                      ),

                      if (_enemyTelegraphEndsAt != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Transform.translate(
                                offset: Offset(
                                  targetOffsetX,
                                  -arenaHeight * 0.125,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 70),
                                  width: hitZoneWidth,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(
                                      (85 + (_enemyTelegraphProgress * 130))
                                          .toInt(),
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _enemyStrikeResolved
                                          ? Colors.red[100]!
                                          : Colors.red[300]!,
                                      width: _enemyStrikeResolved ? 2.8 : 1.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (_enemyTelegraphEndsAt != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment.center,
                              child: Transform.translate(
                                offset: Offset(targetOffsetX, 0),
                                child: Container(
                                  width: 2,
                                  height: arenaHeight * 0.58,
                                  color: Colors.red.withAlpha(
                                    _enemyStrikeResolved ? 210 : 120,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (_enemyTelegraphEndsAt != null)
                        Positioned(
                          top: arenaHeight * 0.02,
                          child: Container(
                            width: min(screenWidth * 0.76, 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[900]?.withAlpha(210),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red[400]!,
                                width: 1.4,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _enemyStrikeResolved
                                      ? 'Golpe bloqueado: mueve rapido para esquivar'
                                      : 'Ataque dirigido al chef: cambia de posicion',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: _enemyTelegraphProgress,
                                  minHeight: 6,
                                  backgroundColor: Colors.black.withAlpha(120),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red[300]!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Damage display for enemy
                      if (_showChefDamage && _lastChefDamage != null)
                        Positioned(
                          top: arenaHeight * 0.14,
                          child: Text(
                            '-${_lastChefDamage!}',
                            style: TextStyle(
                              fontSize: (shortestSide * 0.11).clamp(30.0, 42.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[400],
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(200),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Knife separator
                      Positioned(
                        top: arenaHeight * 0.47,
                        child: Column(
                          children: [
                            Container(
                              width: 2,
                              height: 20,
                              color: Colors.orange[400],
                            ),
                            Icon(
                              Icons.content_cut,
                              size: 30,
                              color: Colors.orange[600],
                            ),
                            Container(
                              width: 2,
                              height: 20,
                              color: Colors.orange[400],
                            ),
                          ],
                        ),
                      ),

                      // Chef at bottom
                      Positioned(
                        bottom: arenaHeight * 0.12,
                        left:
                            (screenWidth / 2 - chefSize / 2) +
                            (battleState.chefPositionX * _arenaMaxOffsetPx),
                        child: ChefCharacter(
                          position: battleState.chefPositionX,
                          size: chefSize,
                        ),
                      ),

                      // Damage display for chef
                      if (_showEnemyDamage && _lastEnemyDamage != null)
                        Positioned(
                          bottom: arenaHeight * 0.22,
                          child: Text(
                            '-${_lastEnemyDamage!}',
                            style: TextStyle(
                              fontSize: (shortestSide * 0.11).clamp(30.0, 42.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.red[400],
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(200),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Container(
                  height: controlsHeight,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border(top: BorderSide(color: Colors.grey[800]!)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: attackButtonHeight,
                        child: ElevatedButton.icon(
                          onPressed: _isAttacking ? null : _chefAttack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isAttacking
                                ? Colors.red[800]
                                : Colors.red[700],
                            disabledBackgroundColor: Colors.red[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Icon(
                            Icons.flash_on,
                            size: (shortestSide * 0.09).clamp(24.0, 34.0),
                          ),
                          label: Text(
                            _chefCombo > 1 ? 'ATACAR x$_chefCombo' : 'ATACAR',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: (shortestSide * 0.052).clamp(
                                    16.0,
                                    21.0,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Listener(
                              onPointerDown: (_) {
                                setState(() => _touchingLeft = true);
                              },
                              onPointerUp: (_) {
                                setState(() => _touchingLeft = false);
                              },
                              onPointerCancel: (_) {
                                setState(() => _touchingLeft = false);
                              },
                              child: Container(
                                height: moveButtonHeight,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _touchingLeft
                                      ? Colors.blue[500]
                                      : Colors.blue[900],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue[700]!,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_left,
                                    color: Colors.white,
                                    size: moveIconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Listener(
                              onPointerDown: (_) {
                                setState(() => _touchingRight = true);
                              },
                              onPointerUp: (_) {
                                setState(() => _touchingRight = false);
                              },
                              onPointerCancel: (_) {
                                setState(() => _touchingRight = false);
                              },
                              child: Container(
                                height: moveButtonHeight,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: _touchingRight
                                      ? Colors.blue[500]
                                      : Colors.blue[900],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue[700]!,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                    size: moveIconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ataques enemigos dirigidos: mueve al chef fuera de la zona roja.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

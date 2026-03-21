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

  const BattleGameScreen({
    super.key,
    required this.chef,
    required this.enemy,
  });

  @override
  State<BattleGameScreen> createState() => _BattleGameScreenState();
}

class _BattleGameScreenState extends State<BattleGameScreen>
    with SingleTickerProviderStateMixin {
  late BattleState battleState;
  late AnimationController _gameLoopController;
  late AnimationController _enemyAttackController;

  // Game constants
  static const double enemyAttackInterval = 2.5; // seconds
  static const double enemyDamage = 12.0;
  static const double chefDamage = 15.0;
  static const double enemyAttackRange = 200.0;
  static const double chefMoveSpeed = 0.03;
  static const double enemyPositionX = 0;

  // Touch input
  bool _touchingLeft = false;
  bool _touchingRight = false;
  bool _isAttacking = false;

  // Damage display
  String? _lastDamage;
  bool _showChefDamage = false;
  bool _showEnemyDamage = false;

  @override
  void initState() {
    super.initState();
    battleState = BattleState(
      chef: widget.chef,
      enemy: widget.enemy,
    );

    // Game loop ~60fps
    _gameLoopController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    // Enemy attack animation
    _enemyAttackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _gameLoopController.addListener(_gameLoop);
  }

  void _gameLoop() {
    if (!mounted || battleState.isGameOver) return;

    setState(() {
      // Update chef position
      if (_touchingLeft) {
        battleState.chefPositionX = (battleState.chefPositionX - chefMoveSpeed)
            .clamp(-1.0, 1.0);
      }
      if (_touchingRight) {
        battleState.chefPositionX = (battleState.chefPositionX + chefMoveSpeed)
            .clamp(-1.0, 1.0);
      }

      // Enemy attack logic
      final now = DateTime.now();
      final lastAttack = battleState.lastEnemyAttackTime;

      if (lastAttack == null ||
          now.difference(lastAttack).inMilliseconds >
              (enemyAttackInterval * 1000).toInt()) {
        battleState.lastEnemyAttackTime = now;

        // Check if chef is in range
        final chefPixelX = battleState.chefPositionX * 100;
        final distance = (chefPixelX - enemyPositionX).abs();

        if (distance < enemyAttackRange) {
          // Enemy hits chef
          battleState.chef.takeDamage(enemyDamage);
          battleState.status = BattleStatus.enemyAttacking;

          // Show damage
          _showEnemyDamage = true;
          _lastDamage = enemyDamage.toStringAsFixed(0);

          // Play animation
          _enemyAttackController.forward().then((_) {
            _enemyAttackController.reverse();
          });

          // Reset after animation
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _showEnemyDamage = false;
                battleState.status = BattleStatus.idle;
              });
            }
          });
        }
      }

      // Check game over
      if (battleState.chef.currentHealth <= 0 ||
          battleState.enemy.currentHealth <= 0) {
        _gameLoopController.stop();
      }
    });
  }

  void _chefAttack() {
    if (_isAttacking || battleState.isGameOver) return;

    _isAttacking = true;
    setState(() {
      battleState.status = BattleStatus.chefAttacking;
    });

    // Check if enemy is in range
    final distance = (battleState.chefPositionX * 100).abs();
    if (distance < 250) {
      // Enemy hit
      battleState.enemy.takeDamage(chefDamage);

      // Show damage
      _showChefDamage = true;
      _lastDamage = chefDamage.toStringAsFixed(0);

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
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          battleState.status = BattleStatus.idle;
          _isAttacking = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _enemyAttackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(GameConstants.darkBackground),
      body: SafeArea(
        child: Column(
          children: [
            // Battle arena
            Expanded(
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
                    top: screenHeight * 0.08,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                        CurvedAnimation(
                          parent: _enemyAttackController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: EnemyCharacter(
                        name: battleState.enemy.name,
                        isAttacking:
                            battleState.status == BattleStatus.enemyAttacking,
                      ),
                    ),
                  ),

                  // Damage display for enemy
                  if (_showChefDamage && _lastDamage != null)
                    Positioned(
                      top: screenHeight * 0.15,
                      child: Text(
                        '+${_lastDamage!}',
                        style: TextStyle(
                          fontSize: 40,
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
                    top: screenHeight * 0.45,
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
                    bottom: screenHeight * 0.15,
                    left: (screenWidth / 2 - 65) +
                        (battleState.chefPositionX * (screenWidth / 2 - 100)),
                    child: ChefCharacter(
                      position: battleState.chefPositionX,
                    ),
                  ),

                  // Damage display for chef
                  if (_showEnemyDamage && _lastDamage != null)
                    Positioned(
                      bottom: screenHeight * 0.25,
                      child: Text(
                        '-${_lastDamage!}',
                        style: TextStyle(
                          fontSize: 40,
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

            // Controls area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: Column(
                children: [
                  // Attack button
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton.icon(
                      onPressed: _isAttacking ? null : _chefAttack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isAttacking ? Colors.red[800] : Colors.red[700],
                        disabledBackgroundColor: Colors.red[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.flash_on,
                        size: 32,
                      ),
                      label: Text(
                        'ATACAR',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Movement controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Left
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
                            height: 55,
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
                            child: const Center(
                              child: Icon(
                                Icons.arrow_left,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Right
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
                            height: 55,
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
                            child: const Center(
                              child: Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Health bars at bottom
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Enemy health
                  Expanded(
                    child: CompactHealthBar(
                      name: battleState.enemy.name,
                      currentHealth: battleState.enemy.currentHealth,
                      maxHealth: battleState.enemy.maxHealth,
                      isPlayer: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chef health
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
          ],
        ),
      ),
    );
  }
}

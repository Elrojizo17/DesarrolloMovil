import 'package:flutter/material.dart';

import '../constants/game_constants.dart';
import '../models/battle_character.dart';
import '../models/battle_state.dart';
import '../widgets/battle_life_bar.dart';
import '../widgets/chef_character.dart';
import '../widgets/enemy_character.dart';

class BattlePlayScreen extends StatefulWidget {
  final BattleCharacter chef;
  final BattleCharacter enemy;

  const BattlePlayScreen({
    super.key,
    required this.chef,
    required this.enemy,
  });

  @override
  State<BattlePlayScreen> createState() => _BattlePlayScreenState();
}

class _BattlePlayScreenState extends State<BattlePlayScreen>
    with SingleTickerProviderStateMixin {
  late BattleState battleState;
  late AnimationController _gameLoopController;

  // Battle constants
  static const double enemyAttackInterval = 2.0; // seconds
  static const double enemyDamage = 10.0;
  static const double enemyAttackRange = 180.0; // pixels - increased for circular chars
  static const double enemyPositionX = 0; // Center
  static const double chefMoveSpeed = 0.02; // position units per frame

  // Touch input
  bool _touchingLeft = false;
  bool _touchingRight = false;

  @override
  void initState() {
    super.initState();
    battleState = BattleState(
      chef: widget.chef,
      enemy: widget.enemy,
    );

    // Game loop running at ~60fps
    _gameLoopController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    _gameLoopController.addListener(_gameLoop);
  }

  void _gameLoop() {
    if (!mounted || battleState.isGameOver) return;

    setState(() {
      // Update chef position based on input
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
        final chefPixelX = battleState.chefPositionX * 100; // Convert to pixels
        final distance = (chefPixelX - enemyPositionX).abs();

        if (distance < enemyAttackRange) {
          // Enemy hits chef
          battleState.chef.takeDamage(enemyDamage);
          battleState.status = BattleStatus.enemyAttacking;

          // Reset status after animation
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                battleState.status = BattleStatus.idle;
              });
            }
          });
        }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(GameConstants.darkBackground),
      body: SafeArea(
        child: Column(
          children: [
            // Enemy info and life bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barra de Vida Enemigo',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.orange[400],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  BattleLifeBar(
                    name: battleState.enemy.name,
                    currentHealth: battleState.enemy.currentHealth,
                    maxHealth: battleState.enemy.maxHealth,
                    isPlayer: false,
                  ),
                ],
              ),
            ),
            
            // Battle arena - Enemy at top
            Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Game over overlay
                  if (battleState.isGameOver)
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black.withAlpha(200),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                battleState.chefWon
                                    ? '¡Victoria!'
                                    : '¡Derrota!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: battleState.chefWon
                                          ? Colors.green[400]
                                          : Colors.red[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Volver'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Enemy - circular at top
                  Positioned(
                    top: 30,
                    child: EnemyCharacter(
                      name: battleState.enemy.name,
                      isAttacking:
                          battleState.status == BattleStatus.enemyAttacking,
                    ),
                  ),
                  
                  // Chef - circular at bottom
                  Positioned(
                    bottom: 30,
                    left: (screenWidth / 2 - 65) +
                        (battleState.chefPositionX * (screenWidth / 2 - 100)),
                    child: ChefCharacter(
                      position: battleState.chefPositionX,
                    ),
                  ),

                  // Knife divider in the middle
                  Positioned(
                    top: screenHeight * 0.35,
                    child: Column(
                      children: [
                        Container(
                          width: 3,
                          height: 30,
                          color: Colors.grey[400],
                        ),
                        Icon(
                          Icons.brightness_1,
                          size: 8,
                          color: Colors.grey[400],
                        ),
                        Icon(
                          Icons.content_cut,
                          size: 40,
                          color: Colors.orange[400],
                        ),
                        Icon(
                          Icons.brightness_1,
                          size: 8,
                          color: Colors.grey[400],
                        ),
                        Container(
                          width: 3,
                          height: 30,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chef info and life bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barra de Vida Chef',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.amber[400],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  BattleLifeBar(
                    name: 'Chef',
                    currentHealth: battleState.chef.currentHealth,
                    maxHealth: battleState.chef.maxHealth,
                    isPlayer: true,
                  ),
                ],
              ),
            ),

            // Resources at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gold display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber[600]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on,
                            color: Colors.amber[300], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Oro',
                          style: TextStyle(
                            color: Colors.amber[300],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Difficulty indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange[600]!,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Nivel ${battleState.enemy.maxHealth.toStringAsFixed(0).replaceAll('.0', '')} HP',
                      style: TextStyle(
                        color: Colors.orange[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Movement controls
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left button
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
                        height: 60,
                        decoration: BoxDecoration(
                          color: _touchingLeft
                              ? Colors.blue[400]
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
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right button
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
                        height: 60,
                        decoration: BoxDecoration(
                          color: _touchingRight
                              ? Colors.blue[400]
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
                            size: 32,
                          ),
                        ),
                      ),
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

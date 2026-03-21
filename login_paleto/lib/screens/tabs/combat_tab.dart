import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/battle_character.dart';
import '../../providers/game_provider.dart';
import '../battle_game_screen.dart';

class CombatTab extends StatelessWidget {
  const CombatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final amalgam = gameProvider.currentAmalgam;
        final isAtLevelLimit = !gameProvider.canLevelUp;

        if (amalgam == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Create battle characters
        final chef = BattleCharacter(
          name: 'Chef',
          maxHealth: 100.0 + (gameProvider.gameSave.currentLevel * 5),
          isPlayer: true,
        );

        final enemy = BattleCharacter(
          name: amalgam.name,
          maxHealth: amalgam.maxHealth,
          isPlayer: false,
        );

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nivel ${gameProvider.gameSave.currentLevel}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange[700],
                          ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.deepOrange[700]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            amalgam.isElite ? Icons.star : Icons.restaurant,
                            size: 64,
                            color: amalgam.isElite
                                ? Colors.amber[300]
                                : Colors.orange[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            amalgam.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: amalgam.isElite
                                  ? Colors.amber[300]
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nivel ${amalgam.level} ${amalgam.isElite ? "⭐" : ""}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Vida del Enemigo: ${amalgam.currentHealth.toStringAsFixed(0)} / ${amalgam.maxHealth.toStringAsFixed(0)} HP',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to battle game screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BattleGameScreen(
                                    chef: chef,
                                    enemy: enemy,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.sports_kabaddi),
                            label: const Text('Iniciar Batalla'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'El Chef debe esquivar los ataques moviéndose horizontalmente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: Column(
                children: [
                  if (isAtLevelLimit)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: Colors.orange[300]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gameProvider.isGuestMode
                                  ? 'Límite en Modo Visitante: Nivel 5'
                                  : 'Máximo nivel alcanzado',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => gameProvider.levelUp(),
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('Subir Nivel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

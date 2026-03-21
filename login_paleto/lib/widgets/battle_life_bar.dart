import 'package:flutter/material.dart';

import '../../constants/game_constants.dart';

class BattleLifeBar extends StatelessWidget {
  final String name;
  final double currentHealth;
  final double maxHealth;
  final bool isPlayer;

  const BattleLifeBar({
    super.key,
    required this.name,
    required this.currentHealth,
    required this.maxHealth,
    required this.isPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final healthPercent = (currentHealth / maxHealth).clamp(0, 1);
    final healthColor = healthPercent > 0.5
        ? Colors.green[400]
        : healthPercent > 0.2
            ? Colors.orange[400]
            : Colors.red[400];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(GameConstants.primaryOrange),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Health bar background
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 28,
                  color: Colors.grey[800],
                ),
                // Health bar fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width * 0.9 * healthPercent,
                  height: 28,
                  color: healthColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Health text
          Text(
            '${currentHealth.toStringAsFixed(0)} / ${maxHealth.toStringAsFixed(0)} HP',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

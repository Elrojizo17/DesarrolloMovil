import 'package:flutter/material.dart';

class CompactHealthBar extends StatelessWidget {
  final String name;
  final double currentHealth;
  final double maxHealth;
  final bool isPlayer;

  const CompactHealthBar({
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPlayer ? Colors.amber[600]! : Colors.red[600]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.grey[800],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (100.0 * healthPercent).toDouble(),
                  height: 12,
                  color: healthColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${currentHealth.toInt()}/${maxHealth.toInt()}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

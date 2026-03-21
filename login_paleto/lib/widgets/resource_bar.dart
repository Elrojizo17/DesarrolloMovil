import 'package:flutter/material.dart';

import '../constants/game_constants.dart';
import '../models/game_save.dart';

class ResourceBar extends StatelessWidget {
  final GameSave gameSave;

  const ResourceBar({
    super.key,
    required this.gameSave,
  });

  String _formatNumber(num value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(GameConstants.darkBackground),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ResourceItem(
              icon: Icons.monetization_on,
              value: _formatNumber(gameSave.gold),
              color: Colors.amber[300]!,
            ),
            _ResourceItem(
              icon: Icons.content_cut,
              value: _formatNumber(gameSave.knifeFragments),
              color: Colors.orange[300]!,
            ),
            _ResourceItem(
              icon: Icons.confirmation_num,
              value: gameSave.restartTokens.toString(),
              color: Colors.lightGreen[300]!,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _ResourceItem({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

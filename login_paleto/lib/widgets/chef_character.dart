import 'package:flutter/material.dart';

class ChefCharacter extends StatelessWidget {
  final double position; // -1 to 1
  final double size;

  const ChefCharacter({super.key, required this.position, this.size = 130});

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.46).clamp(28.0, 74.0);
    final labelFontSize = (size * 0.09).clamp(10.0, 16.0);
    final borderWidth = (size * 0.03).clamp(2.0, 5.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber[700],
        border: Border.all(color: Colors.amber[600]!, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.amber[600]!.withAlpha(150),
            blurRadius: size * 0.12,
            spreadRadius: size * 0.025,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: iconSize, color: Colors.white),
          SizedBox(height: size * 0.06),
          Text(
            'Chef',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: labelFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

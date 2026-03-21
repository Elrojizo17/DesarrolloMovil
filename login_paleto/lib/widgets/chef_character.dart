import 'package:flutter/material.dart';

class ChefCharacter extends StatelessWidget {
  final double position; // -1 to 1

  const ChefCharacter({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber[700],
        border: Border.all(
          color: Colors.amber[600]!,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber[600]!.withAlpha(150),
            blurRadius: 16,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            'Chef',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

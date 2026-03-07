import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final VoidCallback onReset;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.yellow, width: 2),
            ),
            child: Text(
              'Score: $score',
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, color: Colors.yellow),
            label: const Text('Reiniciar', style: TextStyle(color: Colors.yellow)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.yellow, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
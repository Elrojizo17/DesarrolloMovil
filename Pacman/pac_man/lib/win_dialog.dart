import 'package:flutter/material.dart';

void showWinDialog(BuildContext context, int score, VoidCallback onPlayAgain) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('¡Felicidades!', style: TextStyle(color: Colors.yellow)),
        content: Text(
          'Has ganado con $score puntos',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPlayAgain();
            },
            child: const Text('Jugar de nuevo', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      );
    },
  );
}
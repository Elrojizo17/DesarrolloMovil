import 'dart:math';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'game_map.dart';

class GamePainter extends CustomPainter {
  final double pacmanX;
  final double pacmanY;
  final String direction;

  GamePainter({
    required this.pacmanX,
    required this.pacmanY,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / kMapWidth;
    final cellHeight = size.height / kMapHeight;

    // Fondo negro
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    // Dibujar el mapa
    for (int y = 0; y < kMapHeight; y++) {
      for (int x = 0; x < kMapWidth; x++) {
        final rect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        switch (GameMap.layout[y][x]) {
          case 1: // Pared
            final wallPaint = Paint()..color = kWallColor;
            canvas.drawRect(rect, wallPaint);

            final borderPaint = Paint()..color = kWallBorderColor;
            canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 2), borderPaint);
            canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, 2, rect.height), borderPaint);
            break;

          case 2: // Punto normal
            canvas.drawCircle(
              rect.center,
              cellWidth * 0.1,
              Paint()..color = kDotColor,
            );
            break;

          case 3: // Punto grande (power pellet)
            canvas.drawCircle(
              rect.center,
              cellWidth * 0.2,
              Paint()..color = kPowerDotColor,
            );
            final glowPaint = Paint()
              ..color = kPowerDotColor.withAlpha(77)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
            canvas.drawCircle(rect.center, cellWidth * 0.25, glowPaint);
            break;
        }
      }
    }

    // Dibujar Pac-Man
    final pacRect = Rect.fromLTWH(
      pacmanX * cellWidth,
      pacmanY * cellHeight,
      cellWidth,
      cellHeight,
    );

    final pacPaint = Paint()..color = kPacmanColor;

    // Animación de boca
    double time = DateTime.now().millisecondsSinceEpoch / 200.0;
    double mouthAngle = 0.3 + sin(time) * 0.2;

    double startAngle = 0;
    double sweepAngle = 2 * pi;

    switch (direction) {
      case 'right':
        startAngle = mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
      case 'left':
        startAngle = pi + mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
      case 'up':
        startAngle = pi / 2 + mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
      case 'down':
        startAngle = (3 * pi) / 2 + mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
    }

    canvas.drawArc(pacRect, startAngle, sweepAngle, true, pacPaint);

    // Ojo
    final eyePaint = Paint()..color = kEyeColor;
    Offset eyePosition;

    switch (direction) {
      case 'right':
        eyePosition = Offset(
          pacRect.center.dx + cellWidth * 0.2,
          pacRect.center.dy - cellHeight * 0.15,
        );
        break;
      case 'left':
        eyePosition = Offset(
          pacRect.center.dx - cellWidth * 0.2,
          pacRect.center.dy - cellHeight * 0.15,
        );
        break;
      case 'up':
        eyePosition = Offset(
          pacRect.center.dx,
          pacRect.center.dy - cellHeight * 0.25,
        );
        break;
      case 'down':
        eyePosition = Offset(
          pacRect.center.dx,
          pacRect.center.dy + cellHeight * 0.1,
        );
        break;
      default:
        eyePosition = Offset(
          pacRect.center.dx + cellWidth * 0.2,
          pacRect.center.dy - cellHeight * 0.15,
        );
    }

    canvas.drawCircle(eyePosition, cellWidth * 0.1, eyePaint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return oldDelegate.pacmanX != pacmanX ||
        oldDelegate.pacmanY != pacmanY ||
        oldDelegate.direction != direction;
  }
}
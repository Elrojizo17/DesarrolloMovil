import 'package:flutter/material.dart';

class EnemyCharacter extends StatefulWidget {
  final String name;
  final bool isAttacking;
  final double size;

  const EnemyCharacter({
    super.key,
    required this.name,
    required this.isAttacking,
    this.size = 150,
  });

  @override
  State<EnemyCharacter> createState() => _EnemyCharacterState();
}

class _EnemyCharacterState extends State<EnemyCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _attackController;

  @override
  void initState() {
    super.initState();
    _attackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(EnemyCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAttacking && !oldWidget.isAttacking) {
      _attackController.forward().then((_) {
        _attackController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _attackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = (widget.size * 0.47).clamp(30.0, 84.0);
    final labelFontSize = (widget.size * 0.09).clamp(10.0, 16.0);
    final borderWidth = (widget.size * 0.03).clamp(2.0, 5.0);

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _attackController, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[800],
          border: Border.all(color: Colors.red[600]!, width: borderWidth),
          boxShadow: widget.isAttacking
              ? [
                  BoxShadow(
                    color: Colors.red[600]!.withAlpha(200),
                    blurRadius: widget.size * 0.18,
                    spreadRadius: widget.size * 0.055,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.red[800]!.withAlpha(100),
                    blurRadius: widget.size * 0.09,
                    spreadRadius: widget.size * 0.015,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: iconSize, color: Colors.orange[300]),
            SizedBox(height: widget.size * 0.06),
            Text(
              widget.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: labelFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

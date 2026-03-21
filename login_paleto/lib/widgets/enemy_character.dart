import 'package:flutter/material.dart';

class EnemyCharacter extends StatefulWidget {
  final String name;
  final bool isAttacking;

  const EnemyCharacter({
    super.key,
    required this.name,
    required this.isAttacking,
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
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.15)
          .animate(CurvedAnimation(parent: _attackController, curve: Curves.easeInOut)),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[800],
          border: Border.all(
            color: Colors.red[600]!,
            width: 4,
          ),
          boxShadow: widget.isAttacking
              ? [
                  BoxShadow(
                    color: Colors.red[600]!.withAlpha(200),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.red[800]!.withAlpha(100),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 70,
              color: Colors.orange[300],
            ),
            const SizedBox(height: 8),
            Text(
              'Enemigo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

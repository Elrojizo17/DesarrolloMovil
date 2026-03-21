import 'battle_character.dart';

enum BattleStatus { idle, chefAttacking, enemyAttacking, gameOver }

class BattleState {
  final BattleCharacter chef;
  final BattleCharacter enemy;
  BattleStatus status;
  DateTime? lastEnemyAttackTime;
  double chefPositionX; // -1 to 1 (left to right)

  BattleState({
    required this.chef,
    required this.enemy,
    this.status = BattleStatus.idle,
    this.chefPositionX = 0,
  });

  bool get isGameOver => chef.isDefeated || enemy.isDefeated;
  bool get chefWon => enemy.isDefeated && !chef.isDefeated;
  bool get enemyWon => chef.isDefeated;

  void reset() {
    chef.reset();
    enemy.reset();
    status = BattleStatus.idle;
    chefPositionX = 0;
    lastEnemyAttackTime = null;
  }
}

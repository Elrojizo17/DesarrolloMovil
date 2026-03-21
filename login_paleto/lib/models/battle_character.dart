class BattleCharacter {
  final String name;
  final double maxHealth;
  double currentHealth;
  final bool isPlayer;

  BattleCharacter({
    required this.name,
    required this.maxHealth,
    required this.isPlayer,
  }) : currentHealth = maxHealth;

  bool get isDefeated => currentHealth <= 0;
  double get healthPercent => (currentHealth / maxHealth).clamp(0, 1);

  void takeDamage(double damage) {
    currentHealth = (currentHealth - damage).clamp(0, maxHealth);
  }

  void heal(double amount) {
    currentHealth = (currentHealth + amount).clamp(0, maxHealth);
  }

  void reset() {
    currentHealth = maxHealth;
  }
}

class GameSave {
  final int currentLevel;
  final int currentWorld;
  final double gold;
  final double knifeFragments;
  final int restartTokens;

  const GameSave({
    this.currentLevel = 1,
    this.currentWorld = 1,
    this.gold = 0,
    this.knifeFragments = 0,
    this.restartTokens = 0,
  });

  factory GameSave.newGame() => const GameSave();

  GameSave copyWith({
    int? currentLevel,
    int? currentWorld,
    double? gold,
    double? knifeFragments,
    int? restartTokens,
  }) {
    return GameSave(
      currentLevel: currentLevel ?? this.currentLevel,
      currentWorld: currentWorld ?? this.currentWorld,
      gold: gold ?? this.gold,
      knifeFragments: knifeFragments ?? this.knifeFragments,
      restartTokens: restartTokens ?? this.restartTokens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'currentWorld': currentWorld,
      'gold': gold,
      'knifeFragments': knifeFragments,
      'restartTokens': restartTokens,
    };
  }

  factory GameSave.fromJson(Map<String, dynamic> json) {
    return GameSave(
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
      currentWorld: (json['currentWorld'] as num?)?.toInt() ?? 1,
      gold: (json['gold'] as num?)?.toDouble() ?? 0,
      knifeFragments: (json['knifeFragments'] as num?)?.toDouble() ?? 0,
      restartTokens: (json['restartTokens'] as num?)?.toInt() ?? 0,
    );
  }
}

class EnemyModel {
  final int id;
  final int elementId;
  final String name;
  final String type;
  final String imageUrl;
  final int hp;
  final int damage;

  EnemyModel({
    required this.id,
    required this.elementId,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.hp,
    required this.damage,
  });

  factory EnemyModel.fromJson(Map<String, dynamic> json) {
    return EnemyModel(
      id: json['EnemyID'] ?? json['enemyId'] ?? 0,
      elementId: json['ElementID'] ?? json['elementId'] ?? 0,
      name: json['Name'] ?? json['name'] ?? '',
      type: json['Type'] ?? json['type'] ?? '',
      imageUrl: json['ImageURL'] ?? json['imageUrl'] ?? '',
      hp: json['HP'] ?? json['hp'] ?? 0,
      damage: json['Damage'] ?? json['damage'] ?? 0,
    );
  }

  /// Get the element emoji for display
  String get elementEmoji {
    // This will be resolved through the element model
    return '✦';
  }

  /// Difficulty rating based on HP and damage
  String get difficulty {
    final power = hp + (damage * 10);
    if (power > 50000) return 'Legendary';
    if (power > 30000) return 'Hard';
    if (power > 15000) return 'Medium';
    return 'Easy';
  }

  /// Estimated mora reward
  double get estimatedReward {
    return (hp * 0.3 + damage * 5).roundToDouble();
  }
}

class BattleResultModel {
  final int battleId;
  final String userId;
  final int enemyId;
  final String enemyName;
  final double moneyEarned;
  final bool won;
  final DateTime battleDate;
  final int damageDealt;
  final int damageTaken;
  final int turnsCount;

  BattleResultModel({
    required this.battleId,
    required this.userId,
    required this.enemyId,
    required this.enemyName,
    required this.moneyEarned,
    required this.won,
    required this.battleDate,
    this.damageDealt = 0,
    this.damageTaken = 0,
    this.turnsCount = 0,
  });

  factory BattleResultModel.fromJson(Map<String, dynamic> json) {
    return BattleResultModel(
      battleId: json['BattleID'] ?? json['battleId'] ?? 0,
      userId: json['UserID'] ?? json['userId'] ?? '',
      enemyId: json['EnemyID'] ?? json['enemyId'] ?? 0,
      enemyName: json['enemyName'] ?? 'Unknown',
      moneyEarned: (json['Money'] ?? json['money'] ?? 0).toDouble(),
      won: json['won'] ?? true,
      battleDate: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : DateTime.now(),
    );
  }
}

// ─── Dummy Enemies ───
final List<EnemyModel> dummyEnemies = [
  EnemyModel(
    id: 1,
    elementId: 1,
    name: 'Pyro Regisvine',
    type: 'Boss',
    imageUrl: '',
    hp: 48000,
    damage: 1200,
  ),
  EnemyModel(
    id: 2,
    elementId: 2,
    name: 'Oceanid',
    type: 'Boss',
    imageUrl: '',
    hp: 42000,
    damage: 980,
  ),
  EnemyModel(
    id: 3,
    elementId: 3,
    name: 'Thunder Manifestation',
    type: 'Boss',
    imageUrl: '',
    hp: 55000,
    damage: 1500,
  ),
  EnemyModel(
    id: 4,
    elementId: 4,
    name: 'Cryo Hypostasis',
    type: 'Boss',
    imageUrl: '',
    hp: 38000,
    damage: 850,
  ),
  EnemyModel(
    id: 5,
    elementId: 6,
    name: 'Maguu Kenki',
    type: 'Elite',
    imageUrl: '',
    hp: 62000,
    damage: 1800,
  ),
  EnemyModel(
    id: 6,
    elementId: 7,
    name: 'Geo Hypostasis',
    type: 'Boss',
    imageUrl: '',
    hp: 35000,
    damage: 780,
  ),
  EnemyModel(
    id: 7,
    elementId: 5,
    name: 'Jadeplume Terrorshroom',
    type: 'Boss',
    imageUrl: '',
    hp: 45000,
    damage: 1100,
  ),
  EnemyModel(
    id: 8,
    elementId: 1,
    name: 'Aeonblight Drake',
    type: 'Elite',
    imageUrl: '',
    hp: 72000,
    damage: 2200,
  ),
];

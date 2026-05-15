class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] ?? json['userId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'USER',
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
      };

  UserModel copyWith({String? token}) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      role: role,
      token: token ?? this.token,
    );
  }
}

class PlayerStatsModel {
  final int id;
  final String userId;
  final int hp;
  final int damage;
  final double criticalChance;
  final double criticalDamage;
  final double money;

  PlayerStatsModel({
    required this.id,
    required this.userId,
    required this.hp,
    required this.damage,
    required this.criticalChance,
    required this.criticalDamage,
    required this.money,
  });

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      id: json['PlayerStatsID'] ?? json['playerStatsId'] ?? 0,
      userId: json['UserID'] ?? json['userId'] ?? '',
      hp: json['HP'] ?? json['hp'] ?? 0,
      damage: json['Damage'] ?? json['damage'] ?? 0,
      criticalChance:
          (json['CriticalChance'] ?? json['criticalChance'] ?? 0).toDouble(),
      criticalDamage:
          (json['CriticalDamage'] ?? json['criticalDamage'] ?? 0).toDouble(),
      money: (json['Money'] ?? json['money'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'hp': hp,
        'damage': damage,
        'criticalChance': criticalChance,
        'criticalDamage': criticalDamage,
        'money': money,
      };

  /// Get formatted money string
  String get formattedMoney {
    if (money >= 1000000) {
      return '${(money / 1000000).toStringAsFixed(1)}M';
    } else if (money >= 1000) {
      return '${(money / 1000).toStringAsFixed(1)}K';
    }
    return money.toStringAsFixed(0);
  }
}

// ─── Dummy Player Stats ───
final PlayerStatsModel dummyPlayerStats = PlayerStatsModel(
  id: 0,
  userId: '',
  hp: 800,
  damage: 50,
  criticalChance: 5.0,
  criticalDamage: 50.0,
  money: 10000,
);

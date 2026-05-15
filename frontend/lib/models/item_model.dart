import '../services/api_service.dart';

// Helper to safely parse a value to double (handles String, int, double, null)
double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

// Helper to safely parse a value to int
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class ElementModel {
  final int id;
  final String name;
  final String type;
  final String imageUrl;

  ElementModel({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
  });

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      id: json['ElementID'] ?? json['elementId'] ?? 0,
      name: json['Name'] ?? json['name'] ?? '',
      type: json['Type'] ?? json['type'] ?? '',
      imageUrl: ApiService.resolveImageUrl(json['ImageURL'] ?? json['imageUrl']),
    );
  }

  Map<String, dynamic> toJson() => {
        'elementId': id,
        'name': name,
        'type': type,
        'imageUrl': imageUrl,
      };

  /// Get the icon data for this element
  String get emoji {
    switch (type.toLowerCase()) {
      case 'pyro':
        return '🔥';
      case 'hydro':
        return '💧';
      case 'electro':
        return '⚡';
      case 'cryo':
        return '❄️';
      case 'dendro':
        return '🌿';
      case 'anemo':
        return '🌀';
      case 'geo':
        return '🪨';
      default:
        return '✦';
    }
  }
}

class SubstatModel {
  final String stat;
  final double value;

  SubstatModel({required this.stat, required this.value});

  factory SubstatModel.fromJson(Map<String, dynamic> json) {
    return SubstatModel(
      stat: json['stat'] ?? '',
      value: _toDouble(json['value']),
    );
  }
}

abstract class ShopItem {
  int get id;
  String get name;
  String get setName;
  String get type;
  String get description;
  int get stock;
  String get imageUrl;
  double get price;
  int get elementId;
  String get itemCategory; // 'weapon' or 'artifact'
  
  // Inventory fields
  int? get inventoryId;
  int get level;
  int get reinforceLevel;
  double? get mainStatValue;
  List<SubstatModel>? get substats;
}

class WeaponModel implements ShopItem {
  @override
  final int id;
  @override
  final int elementId;
  @override
  final String name;
  @override
  String get setName => name; // Weapons don't have sets, just use name
  @override
  final String type;
  @override
  final String description;
  @override
  final int stock;
  @override
  final String imageUrl;
  @override
  final double price;
  final int damage;

  @override
  final int? inventoryId;
  @override
  final int level;
  @override
  final int reinforceLevel;
  @override
  final double? mainStatValue;
  @override
  final List<SubstatModel>? substats;

  @override
  String get itemCategory => 'Weapon';

  WeaponModel({
    required this.id,
    required this.elementId,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.imageUrl,
    required this.price,
    required this.damage,
    this.inventoryId,
    this.level = 0,
    this.reinforceLevel = 0,
    this.mainStatValue,
    this.substats,
  });
  factory WeaponModel.fromJson(Map<String, dynamic> json) {
    List<SubstatModel>? parsedSubstats;
    if (json['substats'] != null && json['substats'] is List) {
      parsedSubstats = (json['substats'] as List).map((e) => SubstatModel.fromJson(e)).toList();
    }
    
    return WeaponModel(
      id: _toInt(json['id'] ?? json['WeaponID'] ?? json['weaponId']),
      elementId: _toInt(json['elementId'] ?? json['ElementID']),
      name: json['name'] ?? json['Name'] ?? '',
      type: json['type'] ?? json['Type'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      stock: _toInt(json['stock'] ?? json['Stock']),
      imageUrl: ApiService.resolveImageUrl(json['imageUrl'] ?? json['ImageURL']),
      price: _toDouble(json['price'] ?? json['Price']),
      damage: _toInt(json['damage'] ?? json['Damage']),
      inventoryId: json['inventoryId'],
      level: _toInt(json['level'] ?? 0),
      reinforceLevel: _toInt(json['reinforceLevel'] ?? 0),
      mainStatValue: json['mainStatValue'] != null ? _toDouble(json['mainStatValue']) : null,
      substats: parsedSubstats,
    );
  }

  Map<String, dynamic> toJson() => {
        'elementId': elementId,
        'name': name,
        'type': type,
        'description': description,
        'stock': stock,
        'imageUrl': imageUrl,
        'price': price,
        'damage': damage,
      };

  WeaponModel copyWith({
    int? id,
    int? elementId,
    String? name,
    String? type,
    String? description,
    int? stock,
    String? imageUrl,
    double? price,
    int? damage,
  }) {
    return WeaponModel(
      id: id ?? this.id,
      elementId: elementId ?? this.elementId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      damage: damage ?? this.damage,
    );
  }
}

class ArtifactModel implements ShopItem {
  @override
  final int id;
  @override
  final int elementId;
  @override
  final String name;
  @override
  final String setName;
  @override
  final String type;
  @override
  final String description;
  @override
  final int stock;
  @override
  final String imageUrl;
  @override
  final double price;
  final double primaryStat;
  final double secondaryStat;

  @override
  final int? inventoryId;
  @override
  final int level;
  @override
  final int reinforceLevel;
  @override
  final double? mainStatValue;
  @override
  final List<SubstatModel>? substats;

  @override
  String get itemCategory => 'Artifact';

  ArtifactModel({
    required this.id,
    required this.elementId,
    required this.name,
    required this.setName,
    required this.type,
    required this.description,
    required this.stock,
    required this.imageUrl,
    required this.price,
    required this.primaryStat,
    required this.secondaryStat,
    this.inventoryId,
    this.level = 0,
    this.reinforceLevel = 0,
    this.mainStatValue,
    this.substats,
  });

  factory ArtifactModel.fromJson(Map<String, dynamic> json) {
    List<SubstatModel>? parsedSubstats;
    if (json['substats'] != null && json['substats'] is List) {
      parsedSubstats = (json['substats'] as List).map((e) => SubstatModel.fromJson(e)).toList();
    }

    return ArtifactModel(
      id: _toInt(json['id'] ?? json['ArtifactID'] ?? json['artifactId']),
      elementId: _toInt(json['elementId'] ?? json['ElementID']),
      name: json['name'] ?? json['Name'] ?? '',
      setName: json['setName'] ?? json['SetName'] ?? json['name'] ?? json['Name'] ?? '',
      type: json['type'] ?? json['Type'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      stock: _toInt(json['stock'] ?? json['Stock']),
      imageUrl: ApiService.resolveImageUrl(json['imageUrl'] ?? json['ImageURL']),
      price: _toDouble(json['price'] ?? json['Price']),
      primaryStat: _toDouble(json['primaryStat'] ?? json['PrimaryStat']),
      secondaryStat: _toDouble(json['secondaryStat'] ?? json['SecondaryStat']),
      inventoryId: json['inventoryId'],
      level: _toInt(json['level'] ?? 0),
      reinforceLevel: _toInt(json['reinforceLevel'] ?? 0),
      mainStatValue: json['mainStatValue'] != null ? _toDouble(json['mainStatValue']) : null,
      substats: parsedSubstats,
    );
  }

  Map<String, dynamic> toJson() => {
        'elementId': elementId,
        'name': name,
        'setName': setName,
        'type': type,
        'description': description,
        'stock': stock,
        'imageUrl': imageUrl,
        'price': price,
        'primaryStat': primaryStat,
        'secondaryStat': secondaryStat,
      };

  ArtifactModel copyWith({
    int? id,
    int? elementId,
    String? name,
    String? setName,
    String? type,
    String? description,
    int? stock,
    String? imageUrl,
    double? price,
    double? primaryStat,
    double? secondaryStat,
  }) {
    return ArtifactModel(
      id: id ?? this.id,
      elementId: elementId ?? this.elementId,
      name: name ?? this.name,
      setName: setName ?? this.setName,
      type: type ?? this.type,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      primaryStat: primaryStat ?? this.primaryStat,
      secondaryStat: secondaryStat ?? this.secondaryStat,
    );
  }
}

// ─── Dummy Elements ───
final List<ElementModel> dummyElements = [
  ElementModel(id: 1, name: 'Pyro', type: 'Pyro', imageUrl: ''),
  ElementModel(id: 2, name: 'Hydro', type: 'Hydro', imageUrl: ''),
  ElementModel(id: 3, name: 'Electro', type: 'Electro', imageUrl: ''),
  ElementModel(id: 4, name: 'Cryo', type: 'Cryo', imageUrl: ''),
  ElementModel(id: 5, name: 'Dendro', type: 'Dendro', imageUrl: ''),
  ElementModel(id: 6, name: 'Anemo', type: 'Anemo', imageUrl: ''),
  ElementModel(id: 7, name: 'Geo', type: 'Geo', imageUrl: ''),
];

// ─── Dummy Weapons ───
final List<WeaponModel> dummyWeapons = [
  WeaponModel(
    id: 1,
    elementId: 1,
    name: 'Staff of Homa',
    type: 'Polearm',
    description:
        'A "firewood" staff that was once used in ancient and long-lost rituals. The fires that were lit with this staff were said to be able to purify the land.',
    stock: 10,
    imageUrl: '',
    price: 15000,
    damage: 608,
  ),
  WeaponModel(
    id: 2,
    elementId: 2,
    name: "Wolf's Gravestone",
    type: 'Claymore',
    description:
        'A heavy claymore left behind by the Wolf Knight. On the nights of the full moon, this weapon can sometimes be heard letting out a lone wolf\'s howl.',
    stock: 5,
    imageUrl: '',
    price: 12000,
    damage: 608,
  ),
  WeaponModel(
    id: 3,
    elementId: 3,
    name: 'Engulfing Lightning',
    type: 'Polearm',
    description:
        'A naginata used to "cut" the storm clouds, allowing sunlight to pierce through and illuminate the earth below.',
    stock: 8,
    imageUrl: '',
    price: 14000,
    damage: 608,
  ),
  WeaponModel(
    id: 4,
    elementId: 6,
    name: 'Jade Cutter',
    type: 'Sword',
    description:
        'A legendary jade sword from Liyue. Its blade gleams with a green radiance that seems to pulse with life.',
    stock: 3,
    imageUrl: '',
    price: 18000,
    damage: 542,
  ),
  WeaponModel(
    id: 5,
    elementId: 4,
    name: 'Amos\' Bow',
    type: 'Bow',
    description:
        'An extremely ancient bow that has retained its power despite millennia of aging. It is said to have been used by a legendary archer.',
    stock: 7,
    imageUrl: '',
    price: 13000,
    damage: 608,
  ),
  WeaponModel(
    id: 6,
    elementId: 7,
    name: 'Skyward Atlas',
    type: 'Catalyst',
    description:
        'A heavenly tome that captures the essence of the winds and clouds. Its pages shimmer with a celestial glow.',
    stock: 4,
    imageUrl: '',
    price: 16000,
    damage: 674,
  ),
  WeaponModel(
    id: 7,
    elementId: 1,
    name: 'Crimson Moon\'s Semblance',
    type: 'Polearm',
    description:
        'Forged from the remnants of a crimson moon, this polearm blazes with an inner fire that never dies.',
    stock: 2,
    imageUrl: '',
    price: 20000,
    damage: 674,
  ),
  WeaponModel(
    id: 8,
    elementId: 5,
    name: 'Verdant Memoria',
    type: 'Sword',
    description:
        'A sword entwined with living vines. It draws power from the Dendro element, growing stronger with each passing season.',
    stock: 6,
    imageUrl: '',
    price: 11000,
    damage: 510,
  ),
];

// ─── Dummy Artifacts ───
final List<ArtifactModel> dummyArtifacts = [
  ArtifactModel(
    id: 1,
    elementId: 1,
    name: 'Crimson Witch of Flames',
    setName: 'Crimson Witch of Flames',
    type: 'Flower of Life',
    description:
        'A flower touched by the witch who dreamt of burning away all the demons in the world. Its petals shimmer with residual heat.',
    stock: 20,
    imageUrl: '',
    price: 8000,
    primaryStat: 4780,
    secondaryStat: 15.2,
  ),
  ArtifactModel(
    id: 2,
    elementId: 2,
    name: 'Heart of Depth',
    setName: 'Heart of Depth',
    type: 'Feather of Homing',
    description:
        'A feather that glows with hydro energy. It was said to belong to an ancient creature from the ocean depths.',
    stock: 15,
    imageUrl: '',
    price: 7500,
    primaryStat: 311,
    secondaryStat: 12.8,
  ),
  ArtifactModel(
    id: 3,
    elementId: 3,
    name: 'Thundering Fury',
    setName: 'Thundering Fury',
    type: 'Sands of Eon',
    description:
        'An hourglass that crackles with residual electro energy. Time seems to slow in its presence.',
    stock: 12,
    imageUrl: '',
    price: 9000,
    primaryStat: 46.6,
    secondaryStat: 18.4,
  ),
  ArtifactModel(
    id: 4,
    elementId: 6,
    name: 'Viridescent Venerer',
    setName: 'Viridescent Venerer',
    type: 'Goblet of Eonothem',
    description:
        'A goblet blessed by the winds of old. Those who drink from it feel the freedom of the open sky.',
    stock: 10,
    imageUrl: '',
    price: 8500,
    primaryStat: 46.6,
    secondaryStat: 14.0,
  ),
  ArtifactModel(
    id: 5,
    elementId: 7,
    name: 'Archaic Petra',
    setName: 'Archaic Petra',
    type: 'Circlet of Logos',
    description:
        'A crown carved from ancient Geo crystal. Its wearer gains the wisdom of the earth itself.',
    stock: 8,
    imageUrl: '',
    price: 10000,
    primaryStat: 31.1,
    secondaryStat: 20.2,
  ),
  ArtifactModel(
    id: 6,
    elementId: 4,
    name: 'Blizzard Strayer',
    setName: 'Blizzard Strayer',
    type: 'Flower of Life',
    description:
        'A frozen flower that never wilts. It radiates a cold that can freeze even the warmest hearts.',
    stock: 18,
    imageUrl: '',
    price: 7800,
    primaryStat: 4780,
    secondaryStat: 16.6,
  ),
];

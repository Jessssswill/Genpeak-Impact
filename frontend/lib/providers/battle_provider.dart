import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enemy_model.dart';
import '../services/api_service.dart';

enum BattleState { idle, fighting, victory, defeat }

/// Elemental reaction result: display name, damage multiplier, and bonus label.
class ElementReaction {
  final String name;
  final double multiplier;
  final String bonus;
  const ElementReaction(this.name, this.multiplier, this.bonus);

  bool get hasReaction => name.isNotEmpty;
  bool get isAdvantage => multiplier > 1.0;
  bool get isDisadvantage => multiplier < 1.0;
}

const noReaction = ElementReaction('', 1.0, '');

/// Full Genshin Impact elemental reaction table (attacker+defender).
const Map<String, ElementReaction> _reactions = {
  // Vaporize — Pyro trigger ×2, Hydro trigger ×1.5
  'Pyro+Hydro':     ElementReaction('Vaporize',        2.00, '+100% DMG'),
  'Hydro+Pyro':     ElementReaction('Vaporize',        1.50, '+50% DMG'),
  // Melt — Pyro trigger ×2, Cryo trigger ×1.5
  'Pyro+Cryo':      ElementReaction('Melt',            2.00, '+100% DMG'),
  'Cryo+Pyro':      ElementReaction('Melt',            1.50, '+50% DMG'),
  // Overloaded
  'Pyro+Electro':   ElementReaction('Overloaded',      1.50, '+50% DMG'),
  'Electro+Pyro':   ElementReaction('Overloaded',      1.50, '+50% DMG'),
  // Burning
  'Pyro+Dendro':    ElementReaction('Burning',         1.25, '+25% DMG'),
  'Dendro+Pyro':    ElementReaction('Burning',         1.25, '+25% DMG'),
  // Electro-Charged
  'Electro+Hydro':  ElementReaction('Electro-Charged', 1.40, '+40% DMG'),
  'Hydro+Electro':  ElementReaction('Electro-Charged', 1.40, '+40% DMG'),
  // Superconduct
  'Cryo+Electro':   ElementReaction('Superconduct',    1.25, '+25% DMG'),
  'Electro+Cryo':   ElementReaction('Superconduct',    1.25, '+25% DMG'),
  // Frozen
  'Cryo+Hydro':     ElementReaction('Frozen',          1.50, '+50% DMG'),
  'Hydro+Cryo':     ElementReaction('Frozen',          1.50, '+50% DMG'),
  // Bloom
  'Hydro+Dendro':   ElementReaction('Bloom',           1.50, '+50% DMG'),
  'Dendro+Hydro':   ElementReaction('Bloom',           1.50, '+50% DMG'),
  // Quicken → Aggravate (Electro attacker) / Spread (Dendro attacker)
  'Electro+Dendro': ElementReaction('Aggravate',       1.25, '+25% DMG'),
  'Dendro+Electro': ElementReaction('Spread',          1.25, '+25% DMG'),
  // Swirl (Anemo amplifies any element)
  'Anemo+Pyro':     ElementReaction('Swirl',           1.15, '+15% DMG'),
  'Anemo+Hydro':    ElementReaction('Swirl',           1.15, '+15% DMG'),
  'Anemo+Cryo':     ElementReaction('Swirl',           1.15, '+15% DMG'),
  'Anemo+Electro':  ElementReaction('Swirl',           1.15, '+15% DMG'),
  'Anemo+Dendro':   ElementReaction('Swirl',           1.15, '+15% DMG'),
  // Crystallize (Geo — no bonus damage)
  'Geo+Pyro':       ElementReaction('Crystallize',     1.00, 'Neutral'),
  'Geo+Hydro':      ElementReaction('Crystallize',     1.00, 'Neutral'),
  'Geo+Cryo':       ElementReaction('Crystallize',     1.00, 'Neutral'),
  'Geo+Electro':    ElementReaction('Crystallize',     1.00, 'Neutral'),
  'Geo+Dendro':     ElementReaction('Crystallize',     1.00, 'Neutral'),
};

/// Returns the elemental reaction when [attacker] hits [defender].
/// Same element → resisted (-15%). No matching reaction → neutral (×1.0).
ElementReaction getElementReaction(String? attacker, String? defender) {
  if (attacker == null || defender == null) return noReaction;
  if (attacker == defender) return const ElementReaction('Resisted', 0.85, '-15% DMG');
  return _reactions['$attacker+$defender'] ?? noReaction;
}

/// Convenience wrapper: returns the damage multiplier only.
double elementMultiplier(String? attacker, String? defender) =>
    getElementReaction(attacker, defender).multiplier;

class BattleTurn {
  final int playerDamage;
  final bool playerCrit;
  final int enemyDamage;
  final bool enemyCrit;
  final int playerHpAfter;
  final int enemyHpAfter;

  const BattleTurn({
    required this.playerDamage,
    required this.playerCrit,
    required this.enemyDamage,
    required this.enemyCrit,
    required this.playerHpAfter,
    required this.enemyHpAfter,
  });
}

class BattleProvider extends ChangeNotifier {
  List<EnemyModel> _enemies = [];
  bool _isLoading = false;
  BattleState _battleState = BattleState.idle;
  EnemyModel? _currentEnemy;
  double _moneyEarned = 0;
  final List<BattleResultModel> _battleHistory = [];

  List<EnemyModel> get enemies => _enemies;
  bool get isLoading => _isLoading;
  BattleState get battleState => _battleState;
  EnemyModel? get currentEnemy => _currentEnemy;
  double get moneyEarned => _moneyEarned;
  List<BattleResultModel> get battleHistory => _battleHistory;

  Future<void> loadEnemies({bool force = false}) async {
    if (_enemies.isNotEmpty && !force) return;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/items/enemies', auth: false);
      if (res.success && res.data != null) {
        _enemies = (res.data as List).map((e) => EnemyModel.fromJson(e)).toList();
      } else {
        _enemies = dummyEnemies;
      }
    } catch (_) {
      _enemies = dummyEnemies;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEnemiesAdmin() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/admin/enemies');
      if (res.success && res.data != null) {
        _enemies = (res.data as List).map((e) => EnemyModel.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addEnemyApi(Map<String, dynamic> data) async {
    final res = await ApiService.post('/admin/enemies', data);
    if (res.success && res.data != null) {
      _enemies.add(EnemyModel.fromJson(res.data as Map<String, dynamic>));
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateEnemyApi(int id, Map<String, dynamic> data) async {
    final res = await ApiService.put('/admin/enemies/$id', data);
    if (res.success && res.data != null) {
      final index = _enemies.indexWhere((e) => e.id == id);
      if (index != -1) _enemies[index] = EnemyModel.fromJson(res.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteEnemyApi(int id) async {
    final res = await ApiService.delete('/admin/enemies/$id');
    if (res.success) {
      _enemies.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Turn-based battle simulation. Returns full result with turn log.
  Future<TurnBattleResult> startTurnBattle({
    required EnemyModel enemy,
    required int playerDamage,
    required int playerHp,
    required double playerCritChance,
    required double playerCritDamage,
    String? playerElement,
    String? enemyElement,
  }) async {
    _currentEnemy = enemy;
    _battleState = BattleState.fighting;
    notifyListeners();

    final random = Random();
    final reaction = getElementReaction(playerElement, enemyElement);
    final eleMult = reaction.multiplier;

    int currentPlayerHp = playerHp;
    int currentEnemyHp = enemy.hp;
    int totalPlayerDamageDealt = 0;
    int totalEnemyDamageDealt = 0;
    final turns = <BattleTurn>[];

    // Enemy crit stats based on difficulty
    final enemyCritChance = _enemyCritChance(enemy.difficulty);
    final enemyCritDamageMult = 1.5 + random.nextDouble(); // 150%–250%

    // Simulate up to 30 turns (to avoid infinite loops)
    for (int t = 0; t < 30; t++) {
      if (currentEnemyHp <= 0 || currentPlayerHp <= 0) break;

      final playerCrit = random.nextDouble() < (playerCritChance / 100);
      final playerCritMult = playerCrit ? (playerCritDamage / 100) : 1.0;
      final rawPlayerDmg = (playerDamage * eleMult * playerCritMult).round();
      // Small random variance ±10%
      final variance = 0.9 + random.nextDouble() * 0.2;
      final actualPlayerDmg = (rawPlayerDmg * variance).round().clamp(1, 999999);
      currentEnemyHp = (currentEnemyHp - actualPlayerDmg).clamp(0, enemy.hp);
      totalPlayerDamageDealt += actualPlayerDmg;

      if (currentEnemyHp <= 0) {
        turns.add(BattleTurn(
          playerDamage: actualPlayerDmg, playerCrit: playerCrit,
          enemyDamage: 0, enemyCrit: false,
          playerHpAfter: currentPlayerHp, enemyHpAfter: 0,
        ));
        break;
      }

      final enemyCrit = random.nextDouble() < enemyCritChance;
      final enemyCritMult = enemyCrit ? enemyCritDamageMult : 1.0;
      // Enemy advantage is inverse of player's element mult
      final enemyEleMult = elementMultiplier(enemyElement, playerElement);
      final rawEnemyDmg = (enemy.damage * enemyEleMult * enemyCritMult).round();
      final enemyVariance = 0.9 + random.nextDouble() * 0.2;
      final actualEnemyDmg = (rawEnemyDmg * enemyVariance).round().clamp(1, 999999);
      currentPlayerHp = (currentPlayerHp - actualEnemyDmg).clamp(0, playerHp);
      totalEnemyDamageDealt += actualEnemyDmg;

      turns.add(BattleTurn(
        playerDamage: actualPlayerDmg, playerCrit: playerCrit,
        enemyDamage: actualEnemyDmg, enemyCrit: enemyCrit,
        playerHpAfter: currentPlayerHp, enemyHpAfter: currentEnemyHp,
      ));
    }

    final won = currentEnemyHp <= 0;
    _moneyEarned = won ? enemy.estimatedReward * (0.8 + random.nextDouble() * 0.4) : 0;
    _battleState = won ? BattleState.victory : BattleState.defeat;

    _battleHistory.insert(0, BattleResultModel(
      battleId: _battleHistory.length + 1,
      userId: '',
      enemyId: enemy.id,
      enemyName: enemy.name,
      moneyEarned: _moneyEarned,
      won: won,
      battleDate: DateTime.now(),
      damageDealt: totalPlayerDamageDealt,
      damageTaken: totalEnemyDamageDealt,
      turnsCount: turns.length,
    ));

    notifyListeners();

    return TurnBattleResult(
      won: won,
      moneyEarned: _moneyEarned,
      enemyName: enemy.name,
      turns: turns,
      totalPlayerDamage: totalPlayerDamageDealt,
      totalEnemyDamage: totalEnemyDamageDealt,
      remainingEnemyHp: currentEnemyHp,
      remainingPlayerHp: currentPlayerHp,
      elementAdvantage: eleMult,
      reactionName: reaction.name,
      reactionBonus: reaction.bonus,
    );
  }

  double _enemyCritChance(String difficulty) {
    switch (difficulty) {
      case 'Easy':      return 0.05;
      case 'Medium':    return 0.10;
      case 'Hard':      return 0.15;
      case 'Legendary': return 0.20;
      default:          return 0.10;
    }
  }

  void resetBattle() {
    _battleState = BattleState.idle;
    _currentEnemy = null;
    _moneyEarned = 0;
    notifyListeners();
  }
}

class TurnBattleResult {
  final bool won;
  final double moneyEarned;
  final String enemyName;
  final List<BattleTurn> turns;
  final int totalPlayerDamage;
  final int totalEnemyDamage;
  final int remainingEnemyHp;
  final int remainingPlayerHp;
  final double elementAdvantage;
  final String reactionName;
  final String reactionBonus;

  const TurnBattleResult({
    required this.won,
    required this.moneyEarned,
    required this.enemyName,
    required this.turns,
    required this.totalPlayerDamage,
    required this.totalEnemyDamage,
    required this.remainingEnemyHp,
    required this.remainingPlayerHp,
    required this.elementAdvantage,
    required this.reactionName,
    required this.reactionBonus,
  });
}

// Legacy alias kept for any remaining callers
class BattleResult {
  final bool won;
  final double moneyEarned;
  final String enemyName;
  BattleResult({required this.won, required this.moneyEarned, required this.enemyName});
}

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  PlayerStatsModel _playerStats = dummyPlayerStats;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  ShopItem? _equippedWeapon;
  // One slot per artifact type (matches Genshin's 5-piece system)
  final Map<String, ArtifactModel?> _equippedArtifacts = {
    'Flower': null,   // +HP  (primaryStat = flat HP)
    'Feather': null,  // +ATK (primaryStat = flat ATK)
    'Sands': null,    // +ATK% (primaryStat = ATK%)
    'Goblet': null,   // +DMG bonus (primaryStat = DMG%)
    'Circlet': null,  // +CRIT Rate (primaryStat = CRIT%)
  };

  UserModel? get user => _user;
  PlayerStatsModel get playerStats => _playerStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isInitialized => _isInitialized;

  ShopItem? get equippedWeapon => _equippedWeapon;
  Map<String, ArtifactModel?> get equippedArtifacts => Map.unmodifiable(_equippedArtifacts);
  ArtifactModel? equippedArtifactInSlot(String type) => _equippedArtifacts[type];
  int get equippedArtifactCount => _equippedArtifacts.values.where((a) => a != null).length;

  // ── Effective stats (base + all equipped bonuses) ──────────────────────────

  /// HP = base + Flower mainStatValue (upgraded flat HP, falls back to primaryStat)
  int get effectiveHp {
    int hp = _playerStats.hp;
    final flower = _equippedArtifacts['Flower'];
    if (flower != null) hp += (flower.mainStatValue ?? flower.primaryStat).toInt();
    return hp;
  }

  /// ATK = base + weapon mainStatValue + Feather flat ATK + Sands ATK%
  int get effectiveDamage {
    int atk = _playerStats.damage;
    if (_equippedWeapon is WeaponModel) {
      final weapon = _equippedWeapon as WeaponModel;
      atk += weapon.mainStatValue?.round() ?? weapon.damage;
    }
    final feather = _equippedArtifacts['Feather'];
    if (feather != null) atk += (feather.mainStatValue ?? feather.primaryStat).toInt();
    final sands = _equippedArtifacts['Sands'];
    if (sands != null) {
      atk += (_playerStats.damage * (sands.mainStatValue ?? sands.primaryStat) / 100).toInt();
    }
    return atk;
  }

  /// CRIT Rate = base + Circlet mainStatValue (upgraded CRIT Rate %)
  double get effectiveCritRate {
    double cr = _playerStats.criticalChance;
    final circlet = _equippedArtifacts['Circlet'];
    if (circlet != null) cr += circlet.mainStatValue ?? circlet.primaryStat;
    return cr.clamp(0, 100);
  }

  /// CRIT DMG = base + Goblet mainStatValue (upgraded CRIT DMG %)
  double get effectiveCritDmg {
    double cd = _playerStats.criticalDamage;
    final goblet = _equippedArtifacts['Goblet'];
    if (goblet != null) cd += goblet.mainStatValue ?? goblet.primaryStat;
    return cd.clamp(0, 500);
  }

  void equipItem(ShopItem item) {
    if (item is WeaponModel) {
      _equippedWeapon = item;
    } else if (item is ArtifactModel) {
      _equippedArtifacts[item.type] = item;
    }
    notifyListeners();
  }

  void unequipItem(ShopItem item) {
    if (item is WeaponModel) {
      _equippedWeapon = null;
    } else if (item is ArtifactModel) {
      _equippedArtifacts[item.type] = null;
    }
    notifyListeners();
  }

  bool isEquipped(ShopItem item) {
    if (item is WeaponModel) return _equippedWeapon?.inventoryId == item.inventoryId;
    if (item is ArtifactModel) return _equippedArtifacts[item.type]?.inventoryId == item.inventoryId;
    return false;
  }

  /// Try to restore session on app start
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.getStoredUser();
    } catch (e) {
      _user = null;
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();

    // Sync real stats if a session was restored
    if (_user != null) {
      await loadPlayerStats();
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AuthService.login(email, password);

    if (result.success) {
      _user = result.user;
      _error = null;
      _isLoading = false;
      notifyListeners();
      // Sync real money + stats from server immediately after login
      await loadPlayerStats();
    } else {
      _error = result.message;
      _isLoading = false;
      notifyListeners();
    }

    return result.success;
  }

  /// Google OAuth login
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AuthService.loginWithGoogle();

    if (result.success) {
      _user = result.user;
      _error = null;
      _isLoading = false;
      notifyListeners();
      await loadPlayerStats();
    } else {
      _error = result.message;
      _isLoading = false;
      notifyListeners();
    }

    return result.success;
  }

  /// Register
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await AuthService.register(name, email, password);

    if (result.success) {
      _error = null;
    } else {
      _error = result.message;
    }

    _isLoading = false;
    notifyListeners();
    return result.success;
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  /// Demo login (for frontend-only testing)
  void loginDemo() {
    _user = UserModel(
      id: 'demo-user-001',
      email: 'traveler@genshin.com',
      name: 'Traveler',
      role: 'USER',
      token: 'demo-token-abc123xyz',
    );
    _playerStats = dummyPlayerStats;
    _error = null;
    notifyListeners();
  }

  /// Demo admin login
  void loginDemoAdmin() {
    _user = UserModel(
      id: 'demo-admin-001',
      email: 'admin@genshin.com',
      name: 'Administrator',
      role: 'ADMIN',
      token: 'demo-admin-token-abc123',
    );
    _playerStats = dummyPlayerStats;
    _error = null;
    notifyListeners();
  }

  /// Set money to an exact value synced from the server
  void setMoney(double amount) {
    _playerStats = PlayerStatsModel(
      id: _playerStats.id,
      userId: _playerStats.userId,
      hp: _playerStats.hp,
      damage: _playerStats.damage,
      criticalChance: _playerStats.criticalChance,
      criticalDamage: _playerStats.criticalDamage,
      money: amount,
    );
    notifyListeners();
  }

  /// Update money after purchase
  void deductMoney(double amount) {
    _playerStats = PlayerStatsModel(
      id: _playerStats.id,
      userId: _playerStats.userId,
      hp: _playerStats.hp,
      damage: _playerStats.damage,
      criticalChance: _playerStats.criticalChance,
      criticalDamage: _playerStats.criticalDamage,
      money: _playerStats.money - amount,
    );
    notifyListeners();
  }

  /// Add money after battle
  void addMoney(double amount) {
    _playerStats = PlayerStatsModel(
      id: _playerStats.id,
      userId: _playerStats.userId,
      hp: _playerStats.hp,
      damage: _playerStats.damage,
      criticalChance: _playerStats.criticalChance,
      criticalDamage: _playerStats.criticalDamage,
      money: _playerStats.money + amount,
    );
    notifyListeners();
  }

  /// Fetch real player stats from backend and replace local state
  Future<void> loadPlayerStats() async {
    try {
      final res = await ApiService.get('/inventory/player-stats');
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        _playerStats = PlayerStatsModel(
          id: d['playerStatsId'] ?? 0,
          userId: d['userId'] ?? '',
          hp: (d['hp'] ?? 0) as int,
          damage: (d['damage'] ?? 0) as int,
          criticalChance: (d['criticalChance'] ?? 0).toDouble(),
          criticalDamage: (d['criticalDamage'] ?? 0).toDouble(),
          money: (d['money'] ?? 0).toDouble(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadPlayerStats error: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Update display name locally (and optionally on backend)
  Future<bool> updateUsername(String newName) async {
    if (newName.trim().isEmpty) return false;
    try {
      final res = await ApiService.put('/auth/profile', {'name': newName.trim()});
      if (res.success) {
        _user = UserModel(
          id: _user!.id,
          email: _user!.email,
          name: newName.trim(),
          role: _user!.role,
          token: _user!.token,
        );
        notifyListeners();
        return true;
      }
    } catch (_) {}
    // Fallback: update locally if backend call fails
    if (_user != null) {
      _user = UserModel(
        id: _user!.id,
        email: _user!.email,
        name: newName.trim(),
        role: _user!.role,
        token: _user!.token,
      );
      notifyListeners();
      return true;
    }
    return false;
  }
}

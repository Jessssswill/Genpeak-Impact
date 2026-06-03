import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class InventoryProvider extends ChangeNotifier {
  final List<ShopItem> _ownedItems = [];
  bool _isLoading = false;
  bool _isUpgrading = false;
  String _filterType = 'all';
  int? _elementFilter;
  String? _lastUpgradeMessage;

  List<ShopItem> get ownedItems {
    if (_filterType == 'weapons') return _ownedItems.whereType<WeaponModel>().toList();
    if (_elementFilter != null) return _ownedItems.whereType<ArtifactModel>().where((i) => i.elementId == _elementFilter).toList();
    return _ownedItems;
  }

  List<ShopItem> get allItems => _ownedItems;
  bool get isLoading => _isLoading;
  String get filterType => _filterType;
  int? get elementFilter => _elementFilter;
  String? get lastUpgradeMessage => _lastUpgradeMessage;
  int get totalItems => _ownedItems.length;
  int get weaponCount => _ownedItems.whereType<WeaponModel>().length;
  int get artifactCount => _ownedItems.whereType<ArtifactModel>().length;
  int artifactCountForElement(int elementId) =>
      _ownedItems.whereType<ArtifactModel>().where((i) => i.elementId == elementId).length;

  void setFilter(String type) {
    _filterType = type;
    if (type == 'weapons') _elementFilter = null;
    notifyListeners();
  }

  void setElementFilter(int? elementId) {
    _elementFilter = elementId;
    _filterType = elementId != null ? 'element' : 'all';
    notifyListeners();
  }

  void addItem(ShopItem item) {
    _ownedItems.add(item);
    notifyListeners();
  }

  void removeItem(ShopItem item) {
    _ownedItems.removeWhere((i) => i.id == item.id && i.itemCategory == item.itemCategory);
    notifyListeners();
  }

  bool ownsItem(int itemId, String itemType) =>
      _ownedItems.any((i) => i.id == itemId && i.itemCategory == itemType);

  double get totalValue => _ownedItems.fold(0, (sum, item) => sum + item.price);

  Future<void> loadInventory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/inventory');
      if (res.success && res.data != null) {
        _ownedItems.clear();
        for (var itemJson in res.data) {
          if (itemJson['itemCategory'] == 'Weapon') {
            _ownedItems.add(WeaponModel.fromJson(itemJson));
          } else if (itemJson['itemCategory'] == 'Artifact') {
            _ownedItems.add(ArtifactModel.fromJson(itemJson));
          }
        }
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem(int inventoryId) async {
    final res = await ApiService.delete('/inventory/$inventoryId');
    if (res.success) {
      _ownedItems.removeWhere((i) => i.inventoryId == inventoryId);
      notifyListeners();
      return true;
    }
    return false;
  }

  int countCopies(ShopItem item) =>
      _ownedItems.where((i) => i.id == item.id && i.itemCategory == item.itemCategory).length;

  Future<double?> upgradeArtifact(int inventoryId) async {
    if (_isUpgrading) return null;
    _isUpgrading = true;
    _lastUpgradeMessage = null;
    try {
      final res = await ApiService.post('/inventory/$inventoryId/upgrade', {});
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final index = _ownedItems.indexWhere((i) => i.inventoryId == inventoryId);
        if (index != -1 && _ownedItems[index] is ArtifactModel) {
          final existing = _ownedItems[index] as ArtifactModel;
          List<SubstatModel>? newSubstats;
          if (data['substats'] != null && data['substats'] is List) {
            newSubstats = (data['substats'] as List)
                .map((e) => SubstatModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          _ownedItems[index] = ArtifactModel(
            id: existing.id, elementId: existing.elementId,
            name: existing.name, setName: existing.setName,
            type: existing.type, description: existing.description,
            stock: existing.stock, imageUrl: existing.imageUrl,
            price: existing.price, primaryStat: existing.primaryStat,
            secondaryStat: existing.secondaryStat,
            inventoryId: existing.inventoryId,
            level: _parseInt(data['level']) != 0 ? _parseInt(data['level']) : existing.level,
            reinforceLevel: _parseInt(data['reinforceLevel']),
            mainStatValue: _parseDouble(data['mainStatValue']) ?? existing.mainStatValue,
            substats: newSubstats ?? existing.substats,
          );
          notifyListeners();
        }
        return _parseDouble(data['money']);
      }
      _lastUpgradeMessage = res.message.isNotEmpty ? res.message : null;
      return null;
    } finally {
      _isUpgrading = false;
    }
  }

  Future<double?> upgradeWeapon(int inventoryId) async {
    if (_isUpgrading) return null;
    _isUpgrading = true;
    _lastUpgradeMessage = null;
    try {
      final res = await ApiService.post('/inventory/$inventoryId/upgrade-weapon', {});
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final index = _ownedItems.indexWhere((i) => i.inventoryId == inventoryId);
        if (index != -1 && _ownedItems[index] is WeaponModel) {
          final existing = _ownedItems[index] as WeaponModel;
          _ownedItems[index] = WeaponModel(
            id: existing.id, elementId: existing.elementId,
            name: existing.name, type: existing.type,
            description: existing.description, stock: existing.stock,
            imageUrl: existing.imageUrl, price: existing.price,
            damage: existing.damage,
            inventoryId: existing.inventoryId,
            level: _parseInt(data['level']) != 0 ? _parseInt(data['level']) : existing.level,
            reinforceLevel: existing.reinforceLevel,
            mainStatValue: _parseDouble(data['mainStatValue']) ?? existing.mainStatValue,
            substats: existing.substats,
          );
          notifyListeners();
        }
        return _parseDouble(data['money']);
      }
      _lastUpgradeMessage = res.message.isNotEmpty ? res.message : null;
      return null;
    } finally {
      _isUpgrading = false;
    }
  }

  Future<bool> reinforceItem(int inventoryId) async {
    final index = _ownedItems.indexWhere((i) => i.inventoryId == inventoryId);
    if (index == -1) return false;
    final item = _ownedItems[index];

    final copies = _ownedItems
        .where((i) => i.id == item.id && i.itemCategory == item.itemCategory && i.inventoryId != inventoryId)
        .toList();
    if (copies.length < 2) return false;

    final res = await ApiService.post('/inventory/$inventoryId/reinforce', {
      'consumeIds': [copies[0].inventoryId, copies[1].inventoryId],
    });

    if (res.success && res.data != null) {
      // Remove consumed copies
      _ownedItems.removeWhere(
          (i) => i.inventoryId == copies[0].inventoryId || i.inventoryId == copies[1].inventoryId);

      // Update reinforced item from server response
      final currentIndex = _ownedItems.indexWhere((i) => i.inventoryId == inventoryId);
      if (currentIndex != -1 && _ownedItems[currentIndex] is ArtifactModel) {
        final existing = _ownedItems[currentIndex] as ArtifactModel;
        final data = res.data as Map<String, dynamic>;
        _ownedItems[currentIndex] = ArtifactModel(
          id: existing.id, elementId: existing.elementId,
          name: existing.name, setName: existing.setName,
          type: existing.type, description: existing.description,
          stock: existing.stock, imageUrl: existing.imageUrl,
          price: existing.price, primaryStat: existing.primaryStat,
          secondaryStat: existing.secondaryStat,
          inventoryId: existing.inventoryId,
          level: existing.level,
          reinforceLevel: _parseInt(data['reinforceLevel']),
          mainStatValue: _parseDouble(data['mainStatValue']) ?? existing.mainStatValue,
          substats: existing.substats,
        );
      }
      notifyListeners();
      return true;
    }
    return false;
  }
}

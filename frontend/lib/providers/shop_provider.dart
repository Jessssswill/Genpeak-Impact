import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';

/// Display order for artifact pieces (matches in-game slots).
const List<String> kArtifactPieceTypeOrder = [
  'Flower',
  'Feather',
  'Sands',
  'Goblet',
  'Circlet',
];

class ShopProvider extends ChangeNotifier {
  List<WeaponModel> _weapons = [];
  List<ArtifactModel> _artifacts = [];
  List<ElementModel> _elements = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'weapons'; // 'weapons' or 'artifacts'
  int? _selectedElementFilter;
  String _searchQuery = '';

  // Getters
  List<WeaponModel> get weapons => _filteredWeapons;
  List<ArtifactModel> get artifacts => _filteredArtifacts;
  List<ElementModel> get elements => _elements;
  List<WeaponModel> get allWeapons => _weapons;
  List<ArtifactModel> get allArtifacts => _artifacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  int? get selectedElementFilter => _selectedElementFilter;
  String get searchQuery => _searchQuery;

  /// Currently displayed items (either weapons or artifacts)
  List<ShopItem> get currentItems {
    if (_selectedCategory == 'weapons') {
      return _filteredWeapons;
    }
    return _filteredArtifacts;
  }

  /// Get artifact sets grouped by name (for set-based display)
  List<ArtifactModel> get artifactSets {
    final Map<String, ArtifactModel> uniqueSets = {};
    for (final artifact in _artifacts) {
      if (!uniqueSets.containsKey(artifact.setName)) {
        uniqueSets[artifact.setName] = artifact;
      }
    }
    var sets = uniqueSets.values.toList();
    if (_selectedElementFilter != null) {
      sets = sets.where((a) => a.elementId == _selectedElementFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      sets = sets.where((a) => a.setName.toLowerCase().contains(query)).toList();
    }
    return sets;
  }

  /// Get all pieces for a specific artifact set (Flower -> Circlet).
  List<ArtifactModel> getArtifactsBySet(String setName) {
    final list = _artifacts.where((a) => a.setName == setName).toList();
    int slotRank(String type) {
      final i = kArtifactPieceTypeOrder.indexOf(type);
      return i >= 0 ? i : kArtifactPieceTypeOrder.length;
    }
    list.sort((a, b) {
      final bySlot = slotRank(a.type).compareTo(slotRank(b.type));
      if (bySlot != 0) return bySlot;
      return a.id.compareTo(b.id);
    });
    return list;
  }

  List<WeaponModel> get _filteredWeapons {
    var filtered = _weapons.toList();
    if (_selectedElementFilter != null) {
      filtered = filtered.where((w) => w.elementId == _selectedElementFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((w) => w.name.toLowerCase().contains(query) || w.type.toLowerCase().contains(query)).toList();
    }
    return filtered;
  }

  List<ArtifactModel> get _filteredArtifacts {
    var filtered = _artifacts.toList();
    if (_selectedElementFilter != null) {
      filtered = filtered.where((a) => a.elementId == _selectedElementFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((a) => a.name.toLowerCase().contains(query) || a.type.toLowerCase().contains(query)).toList();
    }
    return filtered;
  }

  /// Load items from the API
  Future<void> loadItems() async {
    if (_isLoading && _artifacts.isNotEmpty) return; // Prevent concurrent requests if we already have data

    // Always reload fresh from API (no in-memory cache guard)
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      
      final shopRes = await ApiService.get('/shop', auth: true);


      if (shopRes.success && shopRes.data != null) {
        final List items = shopRes.data;
        final List<WeaponModel> loadedWeapons = [];
        final List<ArtifactModel> loadedArtifacts = [];
        
        for (final item in items) {
          final type = item['itemType'] as String?;
          if (type == 'Weapon') {
            loadedWeapons.add(WeaponModel.fromJson(item));
          } else if (type == 'Artifact') {
            loadedArtifacts.add(ArtifactModel.fromJson(item));
          }
        }
        
        _weapons = loadedWeapons;
        _artifacts = loadedArtifacts;

        // Build element list from real item data (elementId + element type string)
        const canonicalOrder = [
          'Pyro', 'Hydro', 'Electro', 'Cryo', 'Dendro', 'Anemo', 'Geo'
        ];
        final Map<int, String> elementMap = {};
        for (final item in items) {
          final id = item['elementId'];
          final type = item['element'] as String?;
          if (id != null && type != null && type.isNotEmpty) {
            elementMap[id as int] = type;
          }
        }
        _elements = elementMap.entries
            .map((e) => ElementModel(
                  id: e.key,
                  name: e.value,
                  type: e.value,
                  imageUrl: '',
                ))
            .toList()
          ..sort((a, b) {
            final ai = canonicalOrder.indexOf(a.type);
            final bi = canonicalOrder.indexOf(b.type);
            if (ai == -1 && bi == -1) return a.id.compareTo(b.id);
            if (ai == -1) return 1;
            if (bi == -1) return -1;
            return ai.compareTo(bi);
          });
        if (_elements.isEmpty) _elements = dummyElements;
      } else {
        if (shopRes.statusCode == 401) {
          throw Exception('Session expired. Please tap the Profile tab below and Log Out.');
        }
        throw Exception(shopRes.message);
      }


      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load items. Please try logging in again. ($e)';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force reload from API
  Future<void> reloadItems() async {
    _weapons = [];
    _artifacts = [];
    _elements = [];
    await loadItems();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setElementFilter(int? elementId) {
    if (_selectedElementFilter == elementId) {
      _selectedElementFilter = null;
    } else {
      _selectedElementFilter = elementId;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedElementFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  ElementModel? getElement(int elementId) {
    try {
      return _elements.firstWhere((e) => e.id == elementId);
    } catch (_) {
      return null;
    }
  }

  WeaponModel? getWeapon(int id) {
    try {
      return _weapons.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  ArtifactModel? getArtifact(int id) {
    try {
      return _artifacts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void decreaseStock(ShopItem item) {
    if (item is WeaponModel) {
      final index = _weapons.indexWhere((w) => w.id == item.id);
      if (index != -1) _weapons[index] = _weapons[index].copyWith(stock: _weapons[index].stock - 1);
    } else if (item is ArtifactModel) {
      final index = _artifacts.indexWhere((a) => a.id == item.id);
      if (index != -1) _artifacts[index] = _artifacts[index].copyWith(stock: _artifacts[index].stock - 1);
    }
    notifyListeners();
  }

  /// CRUD via API — weapons
  Future<bool> addWeaponApi(Map<String, dynamic> data) async {
    data['itemType'] = 'Weapon';
    final res = await ApiService.post('/admin/shop/item', data);
    if (res.success) {
      _weapons.add(WeaponModel.fromJson(res.data));
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateWeaponApi(int id, Map<String, dynamic> data) async {
    data['itemType'] = 'Weapon';
    final res = await ApiService.put('/admin/shop/item/$id', data);
    if (res.success) {
      final index = _weapons.indexWhere((w) => w.id == id);
      if (index != -1) _weapons[index] = WeaponModel.fromJson(res.data);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteWeaponApi(int id) async {
    final res = await ApiService.delete('/admin/shop/item/$id', body: {'itemType': 'Weapon'});
    if (res.success) {
      _weapons.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Purchase API — returns success flag, backend message, and HTTP status code
  Future<({bool success, String message, int statusCode})> buyItemApi(ShopItem item) async {
    final res = await ApiService.post(
      '/shop/${item.id}',
      {'itemType': item is WeaponModel ? 'Weapon' : 'Artifact'},
    );
    return (success: res.success, message: res.message, statusCode: res.statusCode);
  }

  /// CRUD via API — artifacts
  Future<bool> addArtifactApi(Map<String, dynamic> data) async {
    data['itemType'] = 'Artifact';
    final res = await ApiService.post('/admin/shop/item', data);
    if (res.success) {
      _artifacts.add(ArtifactModel.fromJson(res.data));
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateArtifactApi(int id, Map<String, dynamic> data) async {
    data['itemType'] = 'Artifact';
    final res = await ApiService.put('/admin/shop/item/$id', data);
    if (res.success) {
      final index = _artifacts.indexWhere((a) => a.id == id);
      if (index != -1) _artifacts[index] = ArtifactModel.fromJson(res.data);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteArtifactApi(int id) async {
    final res = await ApiService.delete('/admin/shop/item/$id', body: {'itemType': 'Artifact'});
    if (res.success) {
      _artifacts.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Local-only add/update/delete kept for offline/demo mode
  void addWeapon(WeaponModel weapon) { _weapons.add(weapon); notifyListeners(); }
  void updateWeapon(WeaponModel weapon) {
    final i = _weapons.indexWhere((w) => w.id == weapon.id);
    if (i != -1) { _weapons[i] = weapon; notifyListeners(); }
  }
  void deleteWeapon(int id) { _weapons.removeWhere((w) => w.id == id); notifyListeners(); }
  void addArtifact(ArtifactModel artifact) { _artifacts.add(artifact); notifyListeners(); }
  void updateArtifact(ArtifactModel artifact) {
    final i = _artifacts.indexWhere((a) => a.id == artifact.id);
    if (i != -1) { _artifacts[i] = artifact; notifyListeners(); }
  }
  void deleteArtifact(int id) { _artifacts.removeWhere((a) => a.id == id); notifyListeners(); }
}

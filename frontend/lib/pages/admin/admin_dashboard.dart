import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/item_model.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/element_badge.dart';
import '../../services/api_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2518), AppColors.background]),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  const Expanded(child: Text('Admin Panel', style: TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.w700))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text('${shop.allWeapons.length + shop.allArtifacts.length} items', style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Tabs
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.divider)),
                        child: const TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: [Tab(text: 'Weapons'), Tab(text: 'Artifacts')],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(children: [
                        _ItemList(items: shop.allWeapons, isWeapon: true, shop: shop, onAdd: () => _openForm(context, isWeapon: true)),
                        _ItemList(items: shop.allArtifacts, isWeapon: false, shop: shop, onAdd: () => _openForm(context, isWeapon: false)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {required bool isWeapon, ShopItem? item}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormPage(isWeapon: isWeapon, existingItem: item)));
  }
}

class _ItemList extends StatelessWidget {
  final List<ShopItem> items;
  final bool isWeapon;
  final ShopProvider shop;
  final VoidCallback onAdd;
  const _ItemList({required this.items, required this.isWeapon, required this.shop, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('Add ${isWeapon ? "Weapon" : "Artifact"}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary, side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            final element = shop.getElement(item.elementId);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.cardBorder)),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: (element != null ? AppColors.getElementColor(element.type) : AppColors.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: item.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            ApiService.resolveImageUrl(item.imageUrl),
                            width: 44, height: 44, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              isWeapon ? Icons.gavel_rounded : Icons.diamond_rounded,
                              color: element != null ? AppColors.getElementColor(element.type) : AppColors.primary,
                              size: 22,
                            ),
                          ),
                        )
                      : Icon(isWeapon ? Icons.gavel_rounded : Icons.diamond_rounded, color: element != null ? AppColors.getElementColor(element.type) : AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text('${item.type} • Stock: ${item.stock}', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    if (element != null) ...[const SizedBox(width: 6), ElementBadge(elementType: element.type, compact: true, showLabel: false)],
                  ]),
                ])),
                // Edit
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormPage(isWeapon: isWeapon, existingItem: item))),
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                  onPressed: () => _confirmDelete(context, item),
                ),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  void _confirmDelete(BuildContext context, ShopItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('Delete Item', style: TextStyle(color: AppColors.danger)),
        content: Text('Are you sure you want to delete "${item.name}"?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final ok = isWeapon
                  ? await shop.deleteWeaponApi(item.id)
                  : await shop.deleteArtifactApi(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? '${item.name} deleted' : 'Failed to delete ${item.name}'),
                  backgroundColor: ok ? AppColors.danger : AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Item Create/Edit Form ───
class ItemFormPage extends StatefulWidget {
  final bool isWeapon;
  final ShopItem? existingItem;
  const ItemFormPage({super.key, required this.isWeapon, this.existingItem});

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _setNameCtrl, _typeCtrl, _descCtrl, _stockCtrl, _priceCtrl;
  late TextEditingController _damageCtrl, _primaryCtrl, _secondaryCtrl;
  int _selectedElement = 1;
  File? _pickedImage;
  String _existingImageUrl = '';
  bool get isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _setNameCtrl = TextEditingController(text: item is ArtifactModel ? item.setName : '');
    _typeCtrl = TextEditingController(text: item?.type ?? '');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _stockCtrl = TextEditingController(text: item?.stock.toString() ?? '');
    _priceCtrl = TextEditingController(text: item?.price.toStringAsFixed(0) ?? '');
    _existingImageUrl = item?.imageUrl ?? '';
    _selectedElement = item?.elementId ?? 1;

    if (widget.isWeapon) {
      _damageCtrl = TextEditingController(text: item is WeaponModel ? item.damage.toString() : '');
      _primaryCtrl = TextEditingController();
      _secondaryCtrl = TextEditingController();
    } else {
      _damageCtrl = TextEditingController();
      _primaryCtrl = TextEditingController(text: item is ArtifactModel ? item.primaryStat.toString() : '');
      _secondaryCtrl = TextEditingController(text: item is ArtifactModel ? item.secondaryStat.toString() : '');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _setNameCtrl.dispose(); _typeCtrl.dispose(); _descCtrl.dispose();
    _stockCtrl.dispose(); _priceCtrl.dispose();
    _damageCtrl.dispose(); _primaryCtrl.dispose(); _secondaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (picked != null && mounted) setState(() => _pickedImage = File(picked.path));
  }

  String _resolveImageUrl() {
    if (_pickedImage != null) {
      final bytes = _pickedImage!.readAsBytesSync();
      final ext = _pickedImage!.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    }
    return _existingImageUrl;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final shop = context.read<ShopProvider>();
    final imageUrl = _resolveImageUrl();
    bool ok = false;

    if (widget.isWeapon) {
      final payload = {
        'elementId': _selectedElement,
        'name': _nameCtrl.text.trim(),
        'type': _typeCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'stock': int.tryParse(_stockCtrl.text) ?? 0,
        'imageUrl': imageUrl,
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'damage': int.tryParse(_damageCtrl.text) ?? 0,
      };
      ok = isEditing
          ? await shop.updateWeaponApi(widget.existingItem!.id, payload)
          : await shop.addWeaponApi(payload);
    } else {
      final payload = {
        'elementId': _selectedElement,
        'name': _nameCtrl.text.trim(),
        'setName': _setNameCtrl.text.trim().isNotEmpty ? _setNameCtrl.text.trim() : _nameCtrl.text.trim(),
        'type': _typeCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'stock': int.tryParse(_stockCtrl.text) ?? 0,
        'imageUrl': imageUrl,
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'primaryStat': double.tryParse(_primaryCtrl.text) ?? 0,
        'secondaryStat': double.tryParse(_secondaryCtrl.text) ?? 0,
      };
      ok = isEditing
          ? await shop.updateArtifactApi(widget.existingItem!.id, payload)
          : await shop.addArtifactApi(payload);
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
        content: Text('${_nameCtrl.text} ${isEditing ? "updated" : "created"}!'),
        backgroundColor: AppColors.primaryDark,
      ));
    } else {
      messenger.showSnackBar(const SnackBar(
        content: Text('Failed to save item to backend'),
        backgroundColor: AppColors.warning,
      ));
    }
  }

  String? _required(String? v) => (v == null || v.isEmpty) ? 'This field is required' : null;
  String? _number(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (num.tryParse(v) == null) return 'Enter a valid number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2518), AppColors.background]),
        ),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                Text('${isEditing ? "Edit" : "Add"} ${widget.isWeapon ? "Weapon" : "Artifact"}', style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.w600)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    CustomTextField(label: 'Name', hint: 'Item name', controller: _nameCtrl, prefixIcon: Icons.label_outline, validator: _required),
                    const SizedBox(height: 14),
                    if (!widget.isWeapon) ...[
                      CustomTextField(label: 'Set Name', hint: 'Artifact Set Name', controller: _setNameCtrl, prefixIcon: Icons.collections_bookmark_outlined, validator: _required),
                      const SizedBox(height: 14),
                    ],
                    CustomTextField(label: 'Type', hint: widget.isWeapon ? 'Sword, Claymore, etc.' : 'Flower, Feather, etc.', controller: _typeCtrl, prefixIcon: Icons.category_outlined, validator: _required),
                    const SizedBox(height: 14),
                    CustomTextField(label: 'Description', hint: 'Item description', controller: _descCtrl, prefixIcon: Icons.description_outlined, maxLines: 3, validator: _required),
                    const SizedBox(height: 14),

                    // Element selector
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Element', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: shop.elements.map((el) {
                        final selected = _selectedElement == el.id;
                        final color = AppColors.getElementColor(el.type);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedElement = el.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? color.withValues(alpha: 0.2) : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.badge),
                              border: Border.all(color: selected ? color : AppColors.divider, width: selected ? 1.5 : 1),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Image.asset(elementAssetPath(el.type), width: 14, height: 14, fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => Icon(Icons.auto_awesome, size: 12, color: color)),
                              const SizedBox(width: 4),
                              Text(el.type, style: TextStyle(color: selected ? color : AppColors.textMuted, fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                            ]),
                          ),
                        );
                      }).toList()),
                    ]),
                    const SizedBox(height: 14),

                    Row(children: [
                      Expanded(child: CustomTextField(label: 'Stock', hint: '0', controller: _stockCtrl, prefixIcon: Icons.inventory_outlined, keyboardType: TextInputType.number, validator: _number)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(label: 'Price', hint: '0', controller: _priceCtrl, prefixIcon: Icons.monetization_on_outlined, keyboardType: TextInputType.number, validator: _number)),
                    ]),
                    const SizedBox(height: 14),

                    if (widget.isWeapon)
                      CustomTextField(label: 'Base Damage', hint: '0', controller: _damageCtrl, prefixIcon: Icons.flash_on_rounded, keyboardType: TextInputType.number, validator: _number)
                    else
                      Row(children: [
                        Expanded(child: CustomTextField(label: 'Primary Stat', hint: '0', controller: _primaryCtrl, keyboardType: TextInputType.number, validator: _number)),
                        const SizedBox(width: 12),
                        Expanded(child: CustomTextField(label: 'Secondary Stat', hint: '0', controller: _secondaryCtrl, keyboardType: TextInputType.number, validator: _number)),
                      ]),
                    const SizedBox(height: 14),

                    // Image picker
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Item Image', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: _pickedImage != null ? AppColors.secondary : AppColors.divider, width: _pickedImage != null ? 1.5 : 1),
                          ),
                          child: _pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.md - 1),
                                  child: Image.file(_pickedImage!, fit: BoxFit.contain),
                                )
                              : _existingImageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.md - 1),
                                      child: Image.network(_existingImageUrl, fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => _PickerPlaceholder()),
                                    )
                                  : _PickerPlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(_pickedImage != null ? '✓ Image selected' : 'Tap to choose image from device',
                          style: TextStyle(color: _pickedImage != null ? AppColors.success : AppColors.textMuted, fontSize: 11)),
                    ]),
                    const SizedBox(height: 24),

                    PrimaryButton(text: isEditing ? 'Update Item' : 'Create Item', onPressed: _save, icon: Icons.check_rounded, color: AppColors.secondary),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PickerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textMuted.withValues(alpha: 0.5)),
      const SizedBox(height: 6),
      Text('Choose Image', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ]);
  }
}

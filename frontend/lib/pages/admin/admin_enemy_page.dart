import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/enemy_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/element_badge.dart';
import '../../widgets/shared_ui.dart';

class AdminEnemyPage extends StatefulWidget {
  const AdminEnemyPage({super.key});

  @override
  State<AdminEnemyPage> createState() => _AdminEnemyPageState();
}

class _AdminEnemyPageState extends State<AdminEnemyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BattleProvider>().loadEnemiesAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final battle = context.watch<BattleProvider>();
    final shop = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                const Expanded(
                  child: Text('Enemies', style: TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('${battle.enemies.length} enemies', style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Enemy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: battle.isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: battle.enemies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final enemy = battle.enemies[index];
                        final element = shop.getElement(enemy.elementId);
                        final elementColor = element != null ? AppColors.getElementColor(element.type) : AppColors.pyro;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: elementColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: enemy.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: EnemyImageWidget(url: enemy.imageUrl, width: 44, height: 44, fit: BoxFit.cover,
                                          fallback: Icon(Icons.pest_control_rounded, color: elementColor, size: 22)),
                                    )
                                  : Icon(Icons.pest_control_rounded, color: elementColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text(enemy.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                if (element != null) ...[const SizedBox(width: 6), ElementBadge(elementType: element.type, compact: true, showLabel: false)],
                              ]),
                              const SizedBox(height: 4),
                              Row(children: [
                                Text(enemy.type, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                const SizedBox(width: 8),
                                Icon(Icons.favorite_rounded, size: 10, color: AppColors.success),
                                const SizedBox(width: 2),
                                Text('${enemy.hp}', style: const TextStyle(color: AppColors.success, fontSize: 11)),
                                const SizedBox(width: 8),
                                Icon(Icons.flash_on_rounded, size: 10, color: AppColors.danger),
                                const SizedBox(width: 2),
                                Text('${enemy.damage}', style: const TextStyle(color: AppColors.danger, fontSize: 11)),
                              ]),
                            ])),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                              onPressed: () => _openForm(context, enemy: enemy),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                              onPressed: () => _confirmDelete(context, enemy),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {EnemyModel? enemy}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EnemyFormPage(existingEnemy: enemy)));
  }

  void _confirmDelete(BuildContext context, EnemyModel enemy) {
    final battle = context.read<BattleProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('Delete Enemy', style: TextStyle(color: AppColors.danger)),
        content: Text('Delete "${enemy.name}"?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await battle.deleteEnemyApi(enemy.id);
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(SnackBar(
                content: Text(ok ? '${enemy.name} deleted' : 'Failed to delete'),
                backgroundColor: ok ? AppColors.danger : AppColors.warning,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Enemy Create/Edit Form ───────────────────────────────────────────────────

class EnemyFormPage extends StatefulWidget {
  final EnemyModel? existingEnemy;
  const EnemyFormPage({super.key, this.existingEnemy});

  @override
  State<EnemyFormPage> createState() => _EnemyFormPageState();
}

class _EnemyFormPageState extends State<EnemyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _typeCtrl, _hpCtrl, _damageCtrl;
  int _selectedElement = 1;
  File? _pickedImage;
  String _existingImageUrl = '';
  bool get isEditing => widget.existingEnemy != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEnemy;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _typeCtrl = TextEditingController(text: e?.type ?? '');
    _hpCtrl = TextEditingController(text: e?.hp.toString() ?? '');
    _damageCtrl = TextEditingController(text: e?.damage.toString() ?? '');
    _existingImageUrl = e?.imageUrl ?? '';
    _selectedElement = e?.elementId ?? 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _typeCtrl.dispose(); _hpCtrl.dispose();
    _damageCtrl.dispose();
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
    final battle = context.read<BattleProvider>();

    final payload = {
      'elementId': _selectedElement,
      'name': _nameCtrl.text.trim(),
      'type': _typeCtrl.text.trim(),
      'hp': int.tryParse(_hpCtrl.text) ?? 0,
      'damage': int.tryParse(_damageCtrl.text) ?? 0,
      'imageUrl': _resolveImageUrl(),
    };

    final ok = isEditing
        ? await battle.updateEnemyApi(widget.existingEnemy!.id, payload)
        : await battle.addEnemyApi(payload);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_nameCtrl.text} ${isEditing ? "updated" : "created"}!'),
        backgroundColor: AppColors.primaryDark,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save enemy'),
        backgroundColor: AppColors.warning,
      ));
    }
  }

  String? _required(String? v) => (v == null || v.isEmpty) ? 'Required' : null;
  String? _number(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (int.tryParse(v) == null) return 'Enter a whole number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1818), AppColors.background]),
        ),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                Text('${isEditing ? "Edit" : "Add"} Enemy', style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.w600)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    CustomTextField(label: 'Name', hint: 'Enemy name', controller: _nameCtrl, prefixIcon: Icons.pest_control_rounded, validator: _required),
                    const SizedBox(height: 14),
                    CustomTextField(label: 'Type', hint: 'Boss, Elite, Common', controller: _typeCtrl, prefixIcon: Icons.category_outlined, validator: _required),
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
                      Expanded(child: CustomTextField(label: 'HP', hint: '0', controller: _hpCtrl, prefixIcon: Icons.favorite_rounded, keyboardType: TextInputType.number, validator: _number)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(label: 'Damage', hint: '0', controller: _damageCtrl, prefixIcon: Icons.flash_on_rounded, keyboardType: TextInputType.number, validator: _number)),
                    ]),
                    const SizedBox(height: 14),

                    // Image picker
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Enemy Image', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
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
                                      child: EnemyImageWidget(url: _existingImageUrl, fit: BoxFit.contain,
                                          fallback: _EnemyPickerPlaceholder()),
                                    )
                                  : _EnemyPickerPlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(_pickedImage != null ? '✓ Image selected' : 'Tap to choose image from device',
                          style: TextStyle(color: _pickedImage != null ? AppColors.success : AppColors.textMuted, fontSize: 11)),
                    ]),
                    const SizedBox(height: 24),

                    PrimaryButton(text: isEditing ? 'Update Enemy' : 'Create Enemy', onPressed: _save, icon: Icons.check_rounded, color: AppColors.secondary),
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

class _EnemyPickerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textMuted.withValues(alpha: 0.5)),
      const SizedBox(height: 6),
      Text('Choose Image', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ]);
  }
}

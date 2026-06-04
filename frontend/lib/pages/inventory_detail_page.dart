import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/element_badge.dart';

class InventoryDetailPage extends StatefulWidget {
  final ShopItem item;
  const InventoryDetailPage({super.key, required this.item});

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  bool _upgrading = false;
  bool _reinforcing = false;

  @override
  void initState() {
    super.initState();
    // Always sync balance from server so the displayed Mora and upgrade
    // checks reflect the actual DB value, not a potentially stale local copy.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().loadPlayerStats();
    });
  }

  Future<void> _handleUpgrade() async {
    if (_upgrading) return;
    if (widget.item.inventoryId == null) {
      _showMsg('Item not ready yet — please go back and reopen.', true);
      return;
    }
    setState(() => _upgrading = true);
    try {
      final newMoney = await context
          .read<InventoryProvider>()
          .upgradeArtifact(widget.item.inventoryId!);
      if (!mounted) return;

      if (newMoney != null) {
        final auth = context.read<AuthProvider>();
        auth.setMoney(newMoney);

        final updatedItem =
            context.read<InventoryProvider>().allItems.firstWhere(
          (i) => i.inventoryId == widget.item.inventoryId,
          orElse: () => widget.item,
        );

        // Sync equipped reference so effective stats (ATK/HP/CR/CD) update live
        if (auth.isEquipped(updatedItem)) auth.equipItem(updatedItem);

        setState(() => _upgrading = false);
      } else {
        // Sync real server balance — UI may have been showing a stale amount
        context.read<AuthProvider>().loadPlayerStats();
        setState(() => _upgrading = false);
        final reason = context.read<InventoryProvider>().lastUpgradeMessage;
        _showMsg(reason ?? 'Failed to upgrade artifact.', true);
      }
    } catch (e) {
      if (mounted) setState(() => _upgrading = false);
      _showMsg('Upgrade error: $e', true);
    }
  }

  Future<void> _handleWeaponUpgrade() async {
    if (_upgrading) return;
    if (widget.item.inventoryId == null) {
      _showMsg('Item not ready yet — please go back and reopen.', true);
      return;
    }
    setState(() => _upgrading = true);
    try {
      final newMoney = await context
          .read<InventoryProvider>()
          .upgradeWeapon(widget.item.inventoryId!);
      if (!mounted) return;

      if (newMoney != null) {
        final auth = context.read<AuthProvider>();
        auth.setMoney(newMoney);

        final updatedItem =
            context.read<InventoryProvider>().allItems.firstWhere(
          (i) => i.inventoryId == widget.item.inventoryId,
          orElse: () => widget.item,
        );

        // Sync equipped reference so effective ATK updates live
        if (auth.isEquipped(updatedItem)) auth.equipItem(updatedItem);

        setState(() => _upgrading = false);
      } else {
        context.read<AuthProvider>().loadPlayerStats();
        setState(() => _upgrading = false);
        final reason = context.read<InventoryProvider>().lastUpgradeMessage;
        _showMsg(reason ?? 'Failed to upgrade weapon.', true);
      }
    } catch (e) {
      if (mounted) setState(() => _upgrading = false);
      _showMsg('Upgrade error: $e', true);
    }
  }

  Future<void> _handleReinforce(ShopItem item) async {
    if (_reinforcing) return;
    if (item.inventoryId == null) return;
    setState(() => _reinforcing = true);
    final ok = await context.read<InventoryProvider>().reinforceItem(item.inventoryId!);
    if (!mounted) return;
    setState(() => _reinforcing = false);

    if (ok) {
      // Sync equipped reference so effective stats update live after reinforce
      final auth = context.read<AuthProvider>();
      final updatedItem = context.read<InventoryProvider>().allItems.firstWhere(
        (i) => i.inventoryId == item.inventoryId,
        orElse: () => item,
      );
      if (auth.isEquipped(updatedItem)) auth.equipItem(updatedItem);
    }

    _showMsg(ok ? '${item.name} reinforced! Stats +25%' : 'Reinforce failed — need 3 copies', !ok);
  }

  void _handleEquip(ShopItem item) {
    final auth = context.read<AuthProvider>();
    if (auth.isEquipped(item)) {
      auth.unequipItem(item);
      _showMsg('${item.name} unequipped', false);
    } else {
      auth.equipItem(item);
      _showMsg('${item.name} equipped!', false);
    }
  }

  void _showMsg(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_outline_rounded : Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
      ]),
      backgroundColor: isError ? AppColors.danger : AppColors.primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  String _getMainStatName(String type, String? element) {
    switch (type) {
      case 'Flower':  return 'HP';
      case 'Feather': return 'ATK';
      case 'Sands':   return 'ATK%';
      case 'Goblet':  return 'CRIT DMG';
      case 'Circlet': return 'CRIT Rate';
      default:        return 'Primary Stat';
    }
  }


  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final item = inventory.allItems.firstWhere(
      (i) => i.inventoryId == widget.item.inventoryId,
      orElse: () => widget.item,
    );

    final shop = context.watch<ShopProvider>();
    final element = shop.getElement(item.elementId);
    final elementColor =
        element != null ? AppColors.getElementColor(element.type) : AppColors.primary;
    final isWeapon = item is WeaponModel;
    final equipped = auth.isEquipped(item);
    final canReinforce = inventory.countCopies(item) >= 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    if (element != null) ElementBadge(elementType: element.type),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: elementColor.withOpacity(0.08),
                            ),
                            child: Hero(
                              tag: 'item_image_${item.id}',
                              child: item.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => Icon(
                                        isWeapon
                                            ? Icons.gavel_rounded
                                            : Icons.diamond_rounded,
                                        size: 56,
                                        color: elementColor.withOpacity(0.5),
                                      ),
                                    )
                                  : Icon(
                                      isWeapon
                                          ? Icons.gavel_rounded
                                          : Icons.diamond_rounded,
                                      size: 56,
                                      color: elementColor.withOpacity(0.5),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name & type
                        Center(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            item.type,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (!isWeapon) ...[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Primary stat — shimmers when value changes
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getMainStatName(
                                              item.type, element?.type),
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.mainStatValue != null
                                              ? item.mainStatValue!
                                                  .toInt()
                                                  .toString()
                                              : '0',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (_) => const Icon(Icons.star_rounded,
                                            color: AppColors.rarity5, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Level — shimmers on upgrade
                                Row(children: [
                                  Text(
                                    'Lv. ${item.level}/20',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.reinforceLevel > 0) ...[
                                    const SizedBox(width: 8),
                                    ...List.generate(
                                      item.reinforceLevel,
                                      (_) => const Icon(Icons.star_rounded,
                                          color: AppColors.secondary, size: 13),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 14),

                                Divider(color: AppColors.divider, height: 1),
                                const SizedBox(height: 12),

                                // Substats
                                if (item.substats != null)
                                  ...item.substats!.map(
                                    (substat) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(children: [
                                        Text('• ',
                                            style: TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 14)),
                                        Text(substat.stat,
                                            style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13)),
                                        const SizedBox(width: 10),
                                        Text('+${substat.value}',
                                            style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      ]),
                                    ),
                                  ),
                                const SizedBox(height: 10),

                                // Set bonus
                                Text(
                                  (item as ArtifactModel).setName,
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '2-Piece: Elemental Mastery +80\n4-Piece: Increases damage by 40%.',
                                  style: TextStyle(
                                    color: AppColors.success
                                        .withOpacity(0.7),
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Weapon stats
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('ATK',
                                            style: TextStyle(
                                                color: AppColors.secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.mainStatValue?.round() ?? item.damage}',
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (_) => const Icon(Icons.star_rounded,
                                            color: AppColors.rarity5, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text('Lv. ${item.level}/90',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                if (item.reinforceLevel > 0) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text('Tier ',
                                          style: TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                      ...List.generate(
                                        item.reinforceLevel,
                                        (_) => const Icon(Icons.star_rounded,
                                            color: AppColors.secondary, size: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Description
                        Text('Description',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Equip / Unequip
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleEquip(item),
                            icon: Icon(equipped ? Icons.link_off_rounded : Icons.link_rounded, size: 16),
                            label: Text(equipped ? 'Unequip' : 'Equip'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: equipped ? AppColors.textMuted : AppColors.primary,
                              side: BorderSide(color: equipped ? AppColors.textMuted.withOpacity(0.3) : AppColors.primary.withOpacity(0.4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Enhance (artifacts only)
                        if (!isWeapon) ...[
                          GoldButton(
                            text: item.level >= 20
                                ? 'Max Level Reached'
                                : 'Enhance  (+1 level · 3,000 Mora)',
                            icon: Icons.auto_awesome,
                            isLoading: _upgrading,
                            onPressed: item.level < 20 ? _handleUpgrade : null,
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Upgrade (weapons only)
                        if (isWeapon) ...[
                          GoldButton(
                            text: item.level >= 90
                                ? 'Max Level Reached'
                                : 'Upgrade  (Lv.${item.level}→${item.level + 1} · ${((item.level ~/ 30) + 1) * 1000} Mora)',
                            icon: Icons.arrow_upward_rounded,
                            isLoading: _upgrading,
                            onPressed: item.level < 90 ? _handleWeaponUpgrade : null,
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Reinforce (artifacts only, when 3+ copies available)
                        if (!isWeapon && canReinforce)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _reinforcing ? null : () => _handleReinforce(item),
                              icon: _reinforcing
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.upgrade_rounded, size: 16),
                              label: const Text('Reinforce  (+25% mainStat · uses 2 copies)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.secondary,
                                side: BorderSide(color: AppColors.secondary.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

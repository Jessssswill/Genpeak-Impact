import 'dart:math' show sin, cos, pi;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class _InventoryDetailPageState extends State<InventoryDetailPage>
    with TickerProviderStateMixin {
  bool _upgrading = false;
  bool _reinforcing = false;
  bool _showFlash = false;

  // Increments on each successful upgrade; used as a ValueKey to re-trigger
  // flutter_animate effects on the stat number.
  int _upgradeKey = 0;

  // Drives the sparkle + scale burst effect
  late final AnimationController _burstCtrl;

  @override
  void initState() {
    super.initState();
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    // Always sync balance from server so the displayed Mora and upgrade
    // checks reflect the actual DB value, not a potentially stale local copy.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().loadPlayerStats();
    });
  }

  @override
  void dispose() {
    _burstCtrl.dispose();
    super.dispose();
  }

  // ── Upgrade flow ────────────────────────────────────────────────────────────

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

        setState(() {
          _upgrading = false;
          _upgradeKey++;
          _showFlash = true;
        });

        _burstCtrl.forward(from: 0);
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

        setState(() {
          _upgrading = false;
          _upgradeKey++;
          _showFlash = true;
        });

        _burstCtrl.forward(from: 0);
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

  // ── Burst helpers ────────────────────────────────────────────────────────────

  double _getImageScale() {
    final t = _burstCtrl.value;
    if (t <= 0.25) {
      // 0→0.25: scale up
      return 1.0 + Curves.easeOut.transform(t / 0.25) * 0.18;
    } else {
      // 0.25→1.0: spring back
      return 1.18 - Curves.elasticOut.transform((t - 0.25) / 0.75) * 0.18;
    }
  }

  List<BoxShadow> _getGlowShadow(Color color) {
    if (_burstCtrl.value == 0) return [];
    final t = _burstCtrl.value;
    final intensity = sin(t * pi); // peaks at t=0.5 then fades
    return [
      BoxShadow(
        color: AppColors.secondary.withValues(alpha: intensity * 0.55),
        blurRadius: 28 * intensity,
        spreadRadius: 8 * intensity,
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.25),
        blurRadius: 48 * intensity,
        spreadRadius: 4 * intensity,
      ),
    ];
  }

  List<Widget> _buildSparkles(Color color) {
    final t = _burstCtrl.value;
    const int num = 8;
    const double cx = 100; // center of the 200×200 SizedBox
    const double cy = 100;
    const double dist = 88.0;

    final posT = Curves.easeOut.transform((t / 0.5).clamp(0.0, 1.0));
    final fadeAlpha =
        (1.0 - Curves.easeIn.transform(((t - 0.3) / 0.7).clamp(0.0, 1.0)))
            .clamp(0.0, 1.0);

    if (fadeAlpha <= 0) return [];

    return List.generate(num, (i) {
      final angle = i * 2 * pi / num - pi / 2; // 0° = top
      final x = cx + cos(angle) * dist * posT;
      final y = cy + sin(angle) * dist * posT;
      final isEven = i.isEven;
      final sz = isEven ? 13.0 : 9.0;
      return Positioned(
        left: x - sz / 2,
        top: y - sz / 2,
        child: Opacity(
          opacity: fadeAlpha,
          child: Transform.rotate(
            angle: angle,
            child: Icon(
              isEven ? Icons.star_rounded : Icons.auto_awesome_rounded,
              color: isEven ? AppColors.secondary : color,
              size: sz,
            ),
          ),
        ),
      );
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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
          // ── Main content ────────────────────────────────────────────────
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
                        // ── Hero image with burst animation ──────────────
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _burstCtrl,
                                  builder: (ctx, child) => Transform.scale(
                                    scale: _getImageScale(),
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: elementColor.withValues(alpha: 0.08),
                                        boxShadow: _getGlowShadow(elementColor),
                                      ),
                                      child: item.imageUrl.isNotEmpty
                                          ? Image.network(
                                              item.imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, _, _) => Icon(
                                                isWeapon
                                                    ? Icons.gavel_rounded
                                                    : Icons.diamond_rounded,
                                                size: 56,
                                                color: elementColor
                                                    .withValues(alpha: 0.5),
                                              ),
                                            )
                                          : Icon(
                                              isWeapon
                                                  ? Icons.gavel_rounded
                                                  : Icons.diamond_rounded,
                                              size: 56,
                                              color: elementColor
                                                  .withValues(alpha: 0.5),
                                            ),
                                    ),
                                  ),
                                ),

                                // Sparkles overlay
                                AnimatedBuilder(
                                  animation: _burstCtrl,
                                  builder: (ctx, _) {
                                    if (_burstCtrl.value == 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Stack(
                                      children: _buildSparkles(elementColor),
                                    );
                                  },
                                ),
                              ],
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

                        // ── Stats card ────────────────────────────────────
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
                                        )
                                            .animate(
                                              key: ValueKey(
                                                  '${item.mainStatValue}_$_upgradeKey'),
                                            )
                                            .shimmer(
                                              delay: 150.ms,
                                              duration: 700.ms,
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.7),
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
                                  )
                                      .animate(
                                        key: ValueKey('lvl_$_upgradeKey'),
                                      )
                                      .shimmer(
                                        delay: 80.ms,
                                        duration: 600.ms,
                                        color: AppColors.secondary
                                            .withValues(alpha: 0.8),
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
                                        .withValues(alpha: 0.7),
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
                                        )
                                            .animate(
                                              key: ValueKey('watk_$_upgradeKey'),
                                            )
                                            .shimmer(
                                              delay: 150.ms,
                                              duration: 700.ms,
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.7),
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
                              side: BorderSide(color: equipped ? AppColors.textMuted.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.4)),
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
                                side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.4)),
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

          // ── Golden screen flash on enhance success ───────────────────────
          if (_showFlash)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: AppColors.secondary.withValues(alpha: 0.22),
                )
                    .animate(
                      onComplete: (_) =>
                          setState(() => _showFlash = false),
                    )
                    .fadeIn(duration: 60.ms)
                    .then()
                    .fadeOut(duration: 480.ms),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/element_badge.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/shared_ui.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key});
  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    // Always sync balance from server when opening the purchase screen so the
    // displayed Mora and the pre-flight check always reflect what the server has.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().loadPlayerStats();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  // One gentle page fade — no staggered slide, no per-section motion.
  Widget _fadeSlide(
    Widget child, {
    double start = 0,
    double end = 1,
    Offset begin = const Offset(0, 0.12),
  }) {
    return FadeTransition(opacity: _enterCtrl, child: child);
  }

  void _handlePurchase(ShopItem item) {
    final stats = context.read<AuthProvider>().playerStats;

    if (item.stock <= 0) {
      _showMessage('This item is out of stock.', isError: true);
      return;
    }
    if (stats.money < item.price) {
      _showMessage(
        'Not enough Mora. Need ${item.price.toStringAsFixed(0)}, have ${stats.money.toStringAsFixed(0)}.',
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => _PurchaseDialog(
        item: item,
        remaining: stats.money - item.price,
        onConfirm: () {
          Navigator.pop(ctx);
          _executePurchase(item);
        },
      ),
    );
  }

  Future<void> _executePurchase(ShopItem item) async {
    setState(() => _purchasing = true);
    final shop  = context.read<ShopProvider>();
    final auth  = context.read<AuthProvider>();
    final result = await shop.buyItemApi(item);
    if (!mounted) return;
    setState(() => _purchasing = false);

    if (result.success) {
      shop.decreaseStock(item);
      await Future.wait([
        context.read<InventoryProvider>().loadInventory(),
        auth.loadPlayerStats(),
      ]);
      if (!mounted) return;
      _showMessage('${item.name} added to your inventory!');
    } else if (result.statusCode == 401) {
      _showMessage('Session expired. Please log out and log in again.', isError: true);
      await auth.logout();
    } else {
      // Sync real balance from server so local display matches what server sees
      await auth.loadPlayerStats();
      if (!mounted) return;
      final msg = result.message.isNotEmpty ? result.message : 'Purchase failed. Please try again.';
      _showMessage(msg, isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 17,
        ),
        const SizedBox(width: 9),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
      ]),
      backgroundColor: isError ? AppColors.danger : AppColors.primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as ShopItem;
    final shop = context.watch<ShopProvider>();
    final element = shop.getElement(item.elementId);
    final elementColor =
        element != null ? AppColors.getElementColor(element.type) : AppColors.primary;
    final isWeapon = item is WeaponModel;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.45, 1.0],
            colors: [
              elementColor.withOpacity(0.12),
              AppColors.background.withOpacity(0.97),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary, size: 22),
                  ),
                  const Spacer(),
                  if (element != null) ElementBadge(elementType: element.type),
                  const SizedBox(width: 8),
                ]),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fadeSlide(
                        Center(
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  elementColor.withOpacity(0.18),
                                  elementColor.withOpacity(0.04),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.55, 1.0],
                              ),
                            ),
                            child: Center(
                              child: Hero(
                                tag: 'item_image_${item.id}',
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        width: 130,
                                        height: 130,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => Icon(
                                          isWeapon ? Icons.gavel_rounded : Icons.diamond_rounded,
                                          size: 68,
                                          color: elementColor.withOpacity(0.6),
                                        ),
                                      )
                                    : Icon(
                                        isWeapon ? Icons.gavel_rounded : Icons.diamond_rounded,
                                        size: 68,
                                        color: elementColor.withOpacity(0.6),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        start: 0.0,
                        end: 0.5,
                        begin: const Offset(0, -0.07),
                      ),
                      const SizedBox(height: 18),

                      _fadeSlide(
                        Center(
                          child: Column(children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.type.toUpperCase(),
                              style: TextStyle(
                                color: elementColor.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ]),
                        ),
                        start: 0.12,
                        end: 0.62,
                      ),
                      const SizedBox(height: 20),

                      _fadeSlide(
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.monetization_on_rounded,
                                    size: 17, color: AppColors.secondary),
                                const SizedBox(width: 5),
                                Text(
                                  item.price.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Container(width: 1, height: 14, color: AppColors.divider),
                                ),
                                Icon(
                                  item.stock > 0
                                      ? Icons.inventory_2_outlined
                                      : Icons.remove_shopping_cart_outlined,
                                  size: 14,
                                  color: item.stock > 0 ? AppColors.success : AppColors.danger,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item.stock > 0 ? '${item.stock} in stock' : 'Sold out',
                                  style: TextStyle(
                                    color: item.stock > 0 ? AppColors.success : AppColors.danger,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        start: 0.22,
                        end: 0.72,
                      ),
                      const SizedBox(height: 28),

                      _fadeSlide(
                        GlassmorphicContainer(
                          tier: GlassTier.subtle,
                          borderRadius: 16,
                          tintColor: elementColor,
                          borderColor: elementColor.withOpacity(0.2),
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.22),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          child: item is WeaponModel
                              ? _WeaponStats(item: item, elementColor: elementColor)
                              : _ArtifactStats(
                                  item: item as ArtifactModel,
                                  elementColor: elementColor,
                                  element: element,
                                ),
                        ),
                        start: 0.32,
                        end: 0.86,
                      ),
                      const SizedBox(height: 28),

                      _fadeSlide(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(
                              title: 'Description',
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.description,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.7,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        start: 0.50,
                        end: 1.0,
                      ),
                      const SizedBox(height: 32),

                      _fadeSlide(
                        Column(
                          children: [
                            GoldButton(
                              text: 'Purchase',
                              icon: Icons.shopping_bag_outlined,
                              isLoading: _purchasing,
                              onPressed: item.stock > 0 ? () => _handlePurchase(item) : null,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Balance: ${auth.playerStats.money.toStringAsFixed(0)} Mora',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        start: 0.62,
                        end: 1.0,
                        begin: const Offset(0, 0.18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeaponStats extends StatelessWidget {
  final WeaponModel item;
  final Color elementColor;
  const _WeaponStats({required this.item, required this.elementColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BASE ATK',
                  style: TextStyle(
                    color: elementColor.withOpacity(0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.damage}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (_) => const Icon(Icons.star_rounded, color: Color(0xFFFFB13F), size: 18),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(
                    'Lv. 1 / 20',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ArtifactStats extends StatelessWidget {
  final ArtifactModel item;
  final Color elementColor;
  final dynamic element;
  const _ArtifactStats({required this.item, required this.elementColor, required this.element});

  String _mainStatLabel() {
    switch (item.type) {
      case 'Flower':  return 'HP';
      case 'Feather': return 'ATK';
      case 'Sands':   return 'ATK%';
      case 'Goblet':  return '${element?.type ?? 'Elemental'} DMG Bonus';
      case 'Circlet': return 'CRIT DMG';
      default:        return 'Primary Stat';
    }
  }

  String _secondaryStatLabel() {
    switch (item.type) {
      case 'Flower':  return 'ATK%';
      case 'Feather': return 'ATK%';
      case 'Sands':   return 'CRIT Rate';
      case 'Goblet':  return 'CRIT Rate';
      case 'Circlet': return 'CRIT Rate';
      default:        return 'Bonus';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mainStatLabel().toUpperCase(),
                  style: TextStyle(
                    color: elementColor.withOpacity(0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.primaryStat.toInt()}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (_) => const Icon(Icons.star_rounded, color: Color(0xFFFFB13F), size: 18),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(
                    '+0',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Container(height: 1, color: Colors.white.withOpacity(0.08)),
        ),
        Row(
          children: [
            Container(width: 3, height: 14, color: elementColor.withOpacity(0.6)),
            const SizedBox(width: 10),
            Text(_secondaryStatLabel(), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 10),
            Text(
              '+${item.secondaryStat}%',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          item.setName,
          style: TextStyle(
            color: elementColor.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '2-Piece: Elemental Mastery +80\n4-Piece: Increases damage by 40%.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _PurchaseDialog extends StatefulWidget {
  final ShopItem item;
  final double remaining;
  final VoidCallback onConfirm;

  const _PurchaseDialog({
    required this.item,
    required this.remaining,
    required this.onConfirm,
  });

  @override
  State<_PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<_PurchaseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
    _scale = Tween(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GlassmorphicContainer(
              tier: GlassTier.prominent,
              borderRadius: 20,
              tintColor: AppColors.primary,
              borderColor: Colors.white.withOpacity(0.18),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.secondary, size: 22),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Confirm Purchase',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.item.name,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    // Price
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: AppColors.secondary, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        widget.item.price.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                      'Balance after: ${widget.remaining.toStringAsFixed(0)} Mora',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.secondaryDark],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: widget.onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Buy Now',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

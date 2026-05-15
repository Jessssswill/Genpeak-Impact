import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../providers/inventory_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/element_badge.dart';
import '../widgets/shared_ui.dart';
import 'inventory_detail_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final shop = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Inventory', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${inventory.totalItems} items collected', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ]),
                  ),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: AppColors.electro, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Row 1: All + Weapons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _FilterChip(
                  label: 'All',
                  count: inventory.allItems.length,
                  isSelected: inventory.filterType == 'all' && inventory.elementFilter == null,
                  onTap: () { inventory.setFilter('all'); inventory.setElementFilter(null); },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Weapons',
                  count: inventory.weaponCount,
                  isSelected: inventory.filterType == 'weapons',
                  onTap: () => inventory.setFilter('weapons'),
                  color: AppColors.primary,
                ),
              ]),
            ),
            const SizedBox(height: 8),

            // Row 2: Element chips (one per element that has artifacts in inventory)
            Builder(builder: (context) {
              final presentIds = inventory.allItems
                  .whereType<ArtifactModel>()
                  .map((a) => a.elementId)
                  .toSet();
              final elements = shop.elements
                  .where((el) => presentIds.contains(el.id))
                  .toList();
              if (elements.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 34,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: elements.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final el = elements[i];
                    final count = inventory.artifactCountForElement(el.id);
                    final isSelected = inventory.elementFilter == el.id;
                    final color = AppColors.getElementColor(el.type);
                    return GestureDetector(
                      onTap: () => inventory.setElementFilter(isSelected ? null : el.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.18) : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color.withValues(alpha: 0.5) : AppColors.cardBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Image.asset(elementAssetPath(el.type), width: 13, height: 13, fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Icon(Icons.auto_awesome, size: 11, color: color)),
                          const SizedBox(width: 5),
                          Text(el.type,
                              style: TextStyle(
                                color: isSelected ? color : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              )),
                          const SizedBox(width: 5),
                          Text('$count',
                              style: TextStyle(
                                color: isSelected ? color : AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              )),
                        ]),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 10),

            // Total value
            if (inventory.totalItems > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 8),
                    Text('Total Value', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const Spacer(),
                    Icon(Icons.monetization_on_rounded, color: AppColors.secondary, size: 14),
                    const SizedBox(width: 4),
                    Text(inventory.totalValue.toStringAsFixed(0), style: const TextStyle(color: AppColors.secondary, fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            const SizedBox(height: 10),

            // Items list
            Expanded(
              child: inventory.ownedItems.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No items yet', style: TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Visit the shop to start collecting!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ]),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: inventory.ownedItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = inventory.ownedItems[index];
                        final element = shop.getElement(item.elementId);
                        final isWeapon = item is WeaponModel;
                        final elementColor = element != null ? AppColors.getElementColor(element.type) : AppColors.primary;

                        final copies = inventory.countCopies(item);
                        final canReinforce = copies >= 3;
                        final weaponDamage = item is WeaponModel ? item.damage : 0;

                        return Dismissible(
                          key: Key('inv_${item.inventoryId}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                                title: Text('Delete Item', style: TextStyle(color: AppColors.danger)),
                                content: Text('Delete "${item.name}"? This cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          onDismissed: (_) async {
                            if (item.inventoryId != null) {
                              final ok = await inventory.deleteItem(item.inventoryId!);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(ok ? '${item.name} deleted' : 'Failed to delete'),
                                  backgroundColor: ok ? AppColors.danger : AppColors.warning,
                                ));
                              }
                            }
                          },
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryDetailPage(item: item))),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                border: Border.all(
                                  color: canReinforce ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.cardBorder,
                                  width: canReinforce ? 1.5 : 1,
                                ),
                              ),
                              child: Row(children: [
                                Stack(children: [
                                  Container(
                                    width: 46, height: 46,
                                    decoration: BoxDecoration(
                                      color: elementColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: item.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(item.imageUrl, width: 46, height: 46, fit: BoxFit.contain,
                                                errorBuilder: (_, _, _) => Icon(isWeapon ? Icons.gavel_rounded : Icons.diamond_rounded, color: elementColor, size: 20)),
                                          )
                                        : Icon(isWeapon ? Icons.gavel_rounded : Icons.diamond_rounded, color: elementColor, size: 20),
                                  ),
                                  if (copies > 1)
                                    Positioned(
                                      top: -2, right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: canReinforce ? AppColors.secondary : AppColors.textMuted,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text('×$copies', style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                ]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(children: [
                                      Expanded(child: Text(item.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      if (canReinforce)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                          child: const Text('REINFORCE', style: TextStyle(color: AppColors.secondary, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                        ),
                                    ]),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Text(item.type, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                      if (element != null) ...[
                                        const SizedBox(width: 8),
                                        ElementBadge(elementType: element.type, compact: true, showLabel: false),
                                      ],
                                    ]),
                                  ]),
                                ),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Row(children: [
                                    Image.asset('assets/images/currency/Item_Mora.webp', width: 12, height: 12,
                                        errorBuilder: (_, _, _) => const Icon(Icons.monetization_on_rounded, size: 12, color: AppColors.secondary)),
                                    const SizedBox(width: 3),
                                    Text(item.price.toStringAsFixed(0), style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                    isWeapon
                                        ? 'ATK $weaponDamage'
                                        : 'Lv.${item.level}',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                                  ),
                                ]),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({required this.label, required this.count, required this.isSelected, required this.onTap, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.35) : AppColors.cardBorder,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(color: isSelected ? color : AppColors.textMuted, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
          const SizedBox(width: 5),
          Text('$count', style: TextStyle(color: isSelected ? color : AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

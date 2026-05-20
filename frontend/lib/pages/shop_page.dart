import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../providers/shop_provider.dart';
import '../widgets/element_badge.dart';
import '../widgets/item_card.dart';
import '../widgets/glassmorphic_container.dart';
import 'artifact_set_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        context.read<ShopProvider>().setCategory(_tabCtrl.index == 0 ? 'weapons' : 'artifacts');
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketplace',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Weapons & artifact sets',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.primary.withOpacity(0.22)),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 19),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassmorphicContainer(
                tier: GlassTier.standard,
                borderRadius: 13,
                padding: EdgeInsets.zero,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => shop.setSearchQuery(v),
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted.withOpacity(0.7),
                      size: 19,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded, size: 17, color: AppColors.textMuted),
                            onPressed: () {
                              _searchCtrl.clear();
                              shop.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassmorphicContainer(
                tier: GlassTier.subtle,
                borderRadius: 12,
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  tabs: const [
                    Tab(
                      height: 34,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.gavel_rounded, size: 14),
                        SizedBox(width: 6),
                        Text('Weapons'),
                      ]),
                    ),
                    Tab(
                      height: 34,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.diamond_rounded, size: 14),
                        SizedBox(width: 6),
                        Text('Artifacts'),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: shop.elements.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final el = shop.elements[index];
                  final isSelected = shop.selectedElementFilter == el.id;
                  final color = AppColors.getElementColor(el.type);
                  return _ElementChip(
                    label: el.type,
                    color: color,
                    isSelected: isSelected,
                    onTap: () => shop.setElementFilter(el.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(width: 2.5, height: 11, color: AppColors.primary.withOpacity(0.6)),
                  const SizedBox(width: 7),
                  Text(
                    '${shop.selectedCategory == 'artifacts' ? shop.artifactSets.length : shop.currentItems.length}'
                    ' ${shop.selectedCategory == 'artifacts' ? 'sets' : 'items'} found',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.1),
                  ),
                  const Spacer(),
                  if (shop.searchQuery.isNotEmpty || shop.selectedElementFilter != null)
                    GestureDetector(
                      onTap: () {
                        shop.clearFilters();
                        _searchCtrl.clear();
                      },
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          color: AppColors.primary.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: _buildContent(shop),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ShopProvider shop) {
    if (shop.isLoading) return _buildShimmerGrid(key: const ValueKey('shimmer'));
    if (shop.error != null) return _buildError(shop, key: const ValueKey('error'));
    if (shop.selectedCategory == 'artifacts') {
      return _buildArtifactsByElement(shop, key: const ValueKey('artifacts'));
    }
    return _buildWeaponsGrid(shop, key: const ValueKey('weapons'));
  }

  Widget _buildWeaponsGrid(ShopProvider shop, {Key? key}) {
    final items = shop.currentItems;
    if (items.isEmpty) return _buildEmpty(shop);
    return GridView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final element = shop.getElement(item.elementId);
        final n = index.clamp(0, 8);
        return TweenAnimationBuilder<double>(
          key: ValueKey('w_${item.id}'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 360 + n * 55),
          curve: Curves.easeOutCubic,
          builder: (ctx, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
          ),
          child: ItemCard(
            item: item,
            elementType: element?.type,
            onTap: () => Navigator.pushNamed(context, '/item-detail', arguments: item),
          ),
        );
      },
    );
  }

  /// Artifacts tab — groups sets under elemental section headers.
  Widget _buildArtifactsByElement(ShopProvider shop, {Key? key}) {
    final allSets = shop.artifactSets;
    if (allSets.isEmpty) return _buildEmpty(shop);

    // Group by elementId
    final Map<int, List<ArtifactModel>> groups = {};
    for (final s in allSets) {
      (groups[s.elementId] ??= []).add(s);
    }

    // Build ordered ID list: known elements first (in canonical order), then any extras
    final orderedIds = <int>[];
    for (final e in shop.elements) {
      if (groups.containsKey(e.id)) orderedIds.add(e.id);
    }
    for (final id in groups.keys) {
      if (!orderedIds.contains(id)) orderedIds.add(id);
    }

    // Fallback element for IDs not found in shop.elements
    ElementModel elementFor(int id) {
      return shop.getElement(id) ??
          ElementModel(id: id, name: 'Unknown', type: 'Unknown', imageUrl: '');
    }

    return CustomScrollView(
      key: key,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        for (final elementId in orderedIds) ...[
          SliverToBoxAdapter(
            child: _ElementSectionHeader(
              element: elementFor(elementId),
              count: groups[elementId]!.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final set_ = groups[elementId]![index];
                  final n = index.clamp(0, 8);
                  return TweenAnimationBuilder<double>(
                    key: ValueKey('a_${set_.id}'),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 360 + n * 55),
                    curve: Curves.easeOutCubic,
                    builder: (ctx, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                          offset: Offset(0, 24 * (1 - v)), child: child),
                    ),
                    child: ItemCard(
                      item: set_,
                      elementType: shop.getElement(set_.elementId)?.type,
                      isSetCard: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtifactSetPage(
                              setName: set_.setName,
                              elementId: set_.elementId),
                        ),
                      ),
                    ),
                  );
                },
                childCount: groups[elementId]!.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildShimmerGrid({Key? key}) {
    return GridView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const _ShimmerCard(),
    );
  }

  Widget _buildEmpty(ShopProvider shop) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_rounded, size: 38, color: AppColors.textMuted.withOpacity(0.4)),
        const SizedBox(height: 12),
        Text('No items found', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            shop.clearFilters();
            _searchCtrl.clear();
          },
          child: const Text('Clear filters', style: TextStyle(color: AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _buildError(ShopProvider shop, {Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline_rounded, size: 38, color: AppColors.danger.withOpacity(0.8)),
          const SizedBox(height: 12),
          Text('Error Loading Items',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(shop.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => shop.reloadItems(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ElementChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ElementChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.18)
              : AppColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.45)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              elementAssetPath(label),
              width: 14, height: 14, fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(Icons.auto_awesome, size: 12, color: color),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElementSectionHeader extends StatelessWidget {
  final ElementModel element;
  final int count;

  const _ElementSectionHeader({required this.element, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getElementColor(element.type);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.45), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            elementAssetPath(element.type),
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                Icon(Icons.auto_awesome, size: 14, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            element.type,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.22)),
            ),
            child: Text(
              '$count set${count == 1 ? '' : 's'}',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(AppColors.surface, AppColors.surfaceLight, t * 0.65),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: Color.lerp(AppColors.cardBorder, AppColors.surfaceLight, t * 0.5)!,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLight.withOpacity(0.4 + t * 0.4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 9, width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withOpacity(0.5 + t * 0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        height: 8, width: 55,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withOpacity(0.35 + t * 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

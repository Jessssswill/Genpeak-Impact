import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/battle_provider.dart';
import 'equipment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadItems();
      context.read<BattleProvider>().loadEnemies();
    });
  }

  void _goToTab(int index) =>
      Navigator.pushReplacementNamed(context, '/main', arguments: index);

  void _openItem(ShopItem item) =>
      Navigator.pushNamed(context, '/item-detail', arguments: item);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = auth.playerStats;
    final inventory = context.watch<InventoryProvider>();
    final battles = context.watch<BattleProvider>();
    final shop = context.watch<ShopProvider>();
    final isAdmin = auth.isAdmin;

    final weapons = shop.allWeapons.take(8).toList();
    final artifacts = shop.allArtifacts.take(8).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            // ── Hero ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _Hero(
                name: auth.user?.name ?? 'Traveler',
                isAdmin: isAdmin,
                mora: stats.formattedMoney,
                onBrowse: () => _goToTab(1),
              ),
            ),

            const SizedBox(height: 24),

            if (!isAdmin) ...[
              // ── Featured weapons ──────────────────────────────────
              if (weapons.isNotEmpty) ...[
                _Header('Featured Weapons', onSeeAll: () {
                  shop.setCategory('weapons');
                  _goToTab(1);
                }),
                const SizedBox(height: 12),
                _ItemCarousel(
                  items: weapons,
                  shop: shop,
                  onTap: _openItem,
                ),
                const SizedBox(height: 24),
              ],

              // ── Popular artifacts ─────────────────────────────────
              if (artifacts.isNotEmpty) ...[
                _Header('Popular Artifacts', onSeeAll: () {
                  shop.setCategory('artifacts');
                  _goToTab(1);
                }),
                const SizedBox(height: 12),
                _ItemCarousel(
                  items: artifacts,
                  shop: shop,
                  onTap: _openItem,
                ),
                const SizedBox(height: 24),
              ],

              // ── Character ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header('Your Character'),
                    const SizedBox(height: 12),
                    _CharacterCard(
                      onManage: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EquipmentPage()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _CountsCard(
                      weapons: inventory.weaponCount,
                      artifacts: inventory.artifactCount,
                      battles: battles.battleHistory.length,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Quick actions ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header('Quick Actions'),
                  const SizedBox(height: 12),
                  if (isAdmin)
                    _ActionGrid(actions: [
                      _ActionData(CupertinoIcons.cube_box, 'Manage Items',
                          'Add, edit, delete', AppColors.secondary, () => _goToTab(1)),
                      _ActionData(CupertinoIcons.flame, 'Manage Enemies',
                          'Add, edit, delete', AppColors.pyro, () => _goToTab(2)),
                      _ActionData(CupertinoIcons.person_crop_circle, 'Profile',
                          'Settings & theme', AppColors.primary, () => _goToTab(3)),
                    ])
                  else
                    _ActionGrid(actions: [
                      _ActionData(CupertinoIcons.bag, 'Shop', 'Browse items',
                          AppColors.primary, () => _goToTab(1)),
                      _ActionData(CupertinoIcons.shield, 'Battle', 'Earn Mora',
                          AppColors.pyro, () => _goToTab(3)),
                      _ActionData(CupertinoIcons.archivebox, 'Inventory',
                          '${inventory.totalItems} items', AppColors.electro,
                          () => _goToTab(2)),
                      _ActionData(CupertinoIcons.person_crop_circle, 'Profile',
                          'Settings & theme', AppColors.secondary, () => _goToTab(4)),
                    ]),
                ],
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.02, duration: 350.ms, curve: Curves.easeOut),
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final String name;
  final bool isAdmin;
  final String mora;
  final VoidCallback onBrowse;
  const _Hero({
    required this.name,
    required this.isAdmin,
    required this.mora,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E3D3A), Color(0xFF091428)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 30, spreadRadius: -5),
        ],
      ),
      child: Stack(
        children: [
          // Decorative diamonds, top-right (subtle)
          Positioned(
            right: -16, top: -16,
            child: Transform.rotate(
              angle: 0.785398, // 45°
              child: Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.07), width: 1.5),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40, top: 22,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: AppColors.primary.withOpacity(0.14),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.55), fontSize: 12)),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isAdmin) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text('ADMIN',
                                      style: TextStyle(
                                          color: AppColors.secondaryLight,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Mora chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Image.asset('assets/images/currency/Item_Mora.webp',
                            width: 15, height: 15,
                            errorBuilder: (_, _, _) => const Icon(
                                CupertinoIcons.money_dollar,
                                size: 13, color: AppColors.secondary)),
                        const SizedBox(width: 5),
                        Text(mora,
                            style: const TextStyle(
                                color: AppColors.secondaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tagline + CTA
                Text(
                  isAdmin
                      ? 'Manage the Teyvat catalog'
                      : 'Discover legendary weapons & artifacts',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                if (!isAdmin)
                  GestureDetector(
                    onTap: onBrowse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: const [
                        Text('Browse Shop',
                            style: TextStyle(
                                color: Color(0xFF0E1A16),
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 5),
                        Icon(CupertinoIcons.arrow_right,
                            size: 14, color: Color(0xFF0E1A16)),
                      ]),
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

// ─── Section header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _Header(this.title, {this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: onSeeAll == null ? 0 : 20),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (onSeeAll != null)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: onSeeAll,
              child: Row(children: [
                Text('See all',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 2),
                Icon(CupertinoIcons.chevron_right, size: 12, color: AppColors.primary),
              ]),
            ),
          ),
      ],
    );
  }
}

// ─── Item carousel ────────────────────────────────────────────────────────────

class _ItemCarousel extends StatelessWidget {
  final List<ShopItem> items;
  final ShopProvider shop;
  final void Function(ShopItem) onTap;
  const _ItemCarousel({required this.items, required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          final el = shop.getElement(item.elementId);
          final accent = el != null
              ? AppColors.getElementColor(el.type)
              : AppColors.primary;
          return _ItemCard(item: item, accent: accent, onTap: () => onTap(item));
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ShopItem item;
  final Color accent;
  final VoidCallback onTap;
  const _ItemCard({required this.item, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 108,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.20), accent.withOpacity(0.04)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
              ),
              child: item.imageUrl.isEmpty
                  ? Icon(CupertinoIcons.cube, size: 30, color: accent.withOpacity(0.5))
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        httpHeaders: const {'Bypass-Tunnel-Reminder': 'true'},
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) =>
                            Icon(CupertinoIcons.cube, size: 30, color: accent.withOpacity(0.5)),
                        placeholder: (_, _) => const SizedBox.shrink(),
                      ),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    Image.asset('assets/images/currency/Item_Mora.webp',
                        width: 13, height: 13,
                        errorBuilder: (_, _, _) => Icon(CupertinoIcons.money_dollar,
                            size: 12, color: AppColors.secondary)),
                    const SizedBox(width: 4),
                    Text(
                      _formatPrice(item.price),
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(num price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return '${price.toInt()}';
  }
}

// ─── Character card ───────────────────────────────────────────────────────────

class _CharacterCard extends StatelessWidget {
  final VoidCallback onManage;
  const _CharacterCard({required this.onManage});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final shop = context.watch<ShopProvider>();
    final weapon = auth.equippedWeapon;
    final weaponEl = weapon != null ? shop.getElement(weapon.elementId) : null;
    final accent =
        weaponEl != null ? AppColors.getElementColor(weaponEl.type) : AppColors.primary;

    return GestureDetector(
      onTap: onManage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    weapon != null ? CupertinoIcons.bolt_fill : CupertinoIcons.person,
                    color: accent, size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weapon?.name ?? 'No weapon equipped',
                        style: TextStyle(
                          color: weapon != null ? AppColors.textPrimary : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text('${auth.equippedArtifactCount}/5 artifacts equipped',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniStat('HP', '${auth.effectiveHp}', AppColors.success),
                _MiniStat('ATK', '${auth.effectiveDamage}', AppColors.danger),
                _MiniStat('CRIT', '${auth.effectiveCritRate.toStringAsFixed(0)}%',
                    AppColors.info),
                const Spacer(),
                Row(children: [
                  Text('Manage',
                      style: TextStyle(
                          color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 3),
                  Icon(CupertinoIcons.chevron_right, size: 13, color: accent),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 9.5)),
        ],
      ),
    );
  }
}

// ─── Collection counts ────────────────────────────────────────────────────────

class _CountsCard extends StatelessWidget {
  final int weapons, artifacts, battles;
  const _CountsCard(
      {required this.weapons, required this.artifacts, required this.battles});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _cell(CupertinoIcons.hammer, '$weapons', 'Weapons', AppColors.primary),
          _divider(),
          _cell(CupertinoIcons.star_fill, '$artifacts', 'Artifacts', AppColors.electro),
          _divider(),
          _cell(CupertinoIcons.shield_fill, '$battles', 'Battles', AppColors.pyro),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: AppColors.divider);

  Widget _cell(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 7),
        Text(value,
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ]),
    );
  }
}

// ─── Quick actions ────────────────────────────────────────────────────────────

class _ActionData {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(this.icon, this.label, this.subtitle, this.color, this.onTap);
}

class _ActionGrid extends StatelessWidget {
  final List<_ActionData> actions;
  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: actions.map((a) => _ActionCard(a)).toList(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _ActionData a;
  const _ActionCard(this.a);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: a.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(a.icon, color: a.color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(a.label,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 1),
                  Text(a.subtitle,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

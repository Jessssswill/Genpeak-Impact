import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/element_badge.dart';

// ── Slot metadata ─────────────────────────────────────────────────────────────

class _SlotInfo {
  final String type;
  final IconData icon;
  final bool isWeapon;
  const _SlotInfo(this.type, this.icon, {this.isWeapon = false});
}

const _weaponSlot = _SlotInfo('Weapon', Icons.gavel_rounded, isWeapon: true);
const _artifactSlots = [
  _SlotInfo('Flower',  Icons.local_florist_rounded),
  _SlotInfo('Feather', Icons.air_rounded),
  _SlotInfo('Sands',   Icons.hourglass_bottom_rounded),
  _SlotInfo('Goblet',  Icons.wine_bar_rounded),
  _SlotInfo('Circlet', Icons.hdr_strong_rounded),
];

// ── Main page ─────────────────────────────────────────────────────────────────

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});
  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage>
    with SingleTickerProviderStateMixin {
  double _rotation = 0.0;
  late final AnimationController _breatheCtrl;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  void _openPicker(BuildContext context, _SlotInfo slot) {
    final auth = context.read<AuthProvider>();
    final inventory = context.read<InventoryProvider>();
    final List<ShopItem> items = slot.isWeapon
        ? inventory.allItems.whereType<WeaponModel>().toList()
        : inventory.allItems
            .whereType<ArtifactModel>()
            .where((a) => a.type == slot.type)
            .toList();

    final currentItem = slot.isWeapon
        ? auth.equippedWeapon
        : auth.equippedArtifactInSlot(slot.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ItemPickerSheet(
        slot: slot,
        items: items,
        currentItem: currentItem,
        onEquip: (item) {
          auth.equipItem(item);
          Navigator.pop(context);
        },
        onUnequip: currentItem == null
            ? null
            : () {
                auth.unequipItem(currentItem);
                Navigator.pop(context);
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final shop = context.watch<ShopProvider>();

    final weapon = auth.equippedWeapon;
    final weaponEl = weapon != null ? shop.getElement(weapon.elementId) : null;
    final glowColor = weaponEl != null
        ? AppColors.getElementColor(weaponEl.type)
        : AppColors.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF081428), AppColors.background],
            stops: const [0.0, 0.65],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 20, 0),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  ),
                  Text('Equipment',
                      style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${auth.equippedArtifactCount}/5',
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),

              // ── Main equipment area ───────────────────────────────────────
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background particle glow
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _breatheCtrl,
                        builder: (_, __) => CustomPaint(
                          painter: _BackgroundGlowPainter(
                            color: glowColor,
                            intensity: _breatheCtrl.value,
                          ),
                        ),
                      ),
                    ),

                    // Character silhouette — full height, draggable
                    Positioned(
                      left: 62,
                      right: 80,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate: (d) {
                          setState(() {
                            _rotation += d.delta.dx * 0.012;
                            _rotation = _rotation.clamp(-pi / 2.8, pi / 2.8);
                          });
                        },
                        child: AnimatedBuilder(
                          animation: _breatheCtrl,
                          builder: (_, __) => CustomPaint(
                            painter: _CharacterPainter(
                              rotation: _rotation,
                              glow: glowColor,
                              breathe: _breatheCtrl.value,
                              hasWeapon: weapon != null,
                              weaponGlow: weaponEl != null
                                  ? AppColors.getElementColor(weaponEl.type)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Drag hint
                    Positioned(
                      bottom: 12,
                      child: AnimatedOpacity(
                        opacity: _rotation.abs() < 0.08 ? 0.45 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.swipe_rounded, size: 13,
                              color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('Drag to rotate',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        ]),
                      ),
                    ),

                    // ── Weapon slot (LEFT) ────────────────────────────────
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _SlotButton(
                          slot: _weaponSlot,
                          item: auth.equippedWeapon,
                          element: weaponEl,
                          onTap: () => _openPicker(context, _weaponSlot),
                        ),
                      ),
                    ),

                    // ── Artifact slots (RIGHT) ────────────────────────────
                    Positioned(
                      right: 6,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _artifactSlots.map((slot) {
                          final artifact = auth.equippedArtifactInSlot(slot.type);
                          final el = artifact != null
                              ? shop.getElement(artifact.elementId)
                              : null;
                          return _SlotButton(
                            slot: slot,
                            item: artifact,
                            element: el,
                            onTap: () => _openPicker(context, slot),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats bar ─────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem('HP', '${auth.effectiveHp}',
                        Icons.favorite_rounded, AppColors.success),
                    _vDivider(),
                    _StatItem('ATK', '${auth.effectiveDamage}',
                        Icons.flash_on_rounded, AppColors.danger),
                    _vDivider(),
                    _StatItem(
                        'CR',
                        '${auth.effectiveCritRate.toStringAsFixed(1)}%',
                        Icons.gps_fixed_rounded,
                        AppColors.info),
                    _vDivider(),
                    _StatItem(
                        'CD',
                        '${auth.effectiveCritDmg.toStringAsFixed(0)}%',
                        Icons.bolt_rounded,
                        AppColors.electro),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 30, color: AppColors.divider);
}

// ── Equipment slot button ─────────────────────────────────────────────────────

class _SlotButton extends StatelessWidget {
  final _SlotInfo slot;
  final ShopItem? item;
  final ElementModel? element;
  final VoidCallback onTap;
  const _SlotButton({required this.slot, this.item, this.element, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final equipped = item != null;
    final elColor = element != null
        ? AppColors.getElementColor(element!.type)
        : (equipped ? AppColors.primary : AppColors.textMuted);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 62,
        height: 68,
        decoration: BoxDecoration(
          color: equipped
              ? elColor.withValues(alpha: 0.14)
              : AppColors.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: equipped ? elColor.withValues(alpha: 0.55) : AppColors.divider,
            width: equipped ? 1.5 : 1,
          ),
          boxShadow: equipped
              ? [BoxShadow(color: elColor.withValues(alpha: 0.3), blurRadius: 10)]
              : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (equipped && item!.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item!.imageUrl,
                width: 34, height: 34, fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(slot.icon, size: 24, color: elColor),
              ),
            )
          else
            Icon(
              slot.icon,
              size: 24,
              color: equipped
                  ? elColor
                  : AppColors.textMuted.withValues(alpha: 0.35),
            ),
          const SizedBox(height: 4),
          if (equipped && element != null)
            Image.asset(
              elementAssetPath(element!.type),
              width: 12, height: 12, fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(),
            )
          else
            Text(
              slot.type,
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: equipped ? 0.7 : 0.35),
                fontSize: 7.5,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ]),
      ),
    );
  }
}

// ── Stat display ──────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(height: 3),
      Text(value,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700)),
      Text(label,
          style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
    ]);
  }
}

// ── Item picker bottom sheet ───────────────────────────────────────────────────

class _ItemPickerSheet extends StatelessWidget {
  final _SlotInfo slot;
  final List<ShopItem> items;
  final ShopItem? currentItem;
  final ValueChanged<ShopItem> onEquip;
  final VoidCallback? onUnequip;
  const _ItemPickerSheet({
    required this.slot,
    required this.items,
    this.currentItem,
    required this.onEquip,
    this.onUnequip,
  });

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(children: [
        // Handle bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 12, 0),
          child: Row(children: [
            Icon(slot.icon, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              slot.isWeapon ? 'Select Weapon' : 'Select ${slot.type}',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (onUnequip != null)
              TextButton(
                onPressed: onUnequip,
                child: Text('Unequip',
                    style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
          ]),
        ),
        const SizedBox(height: 6),
        Divider(color: AppColors.divider, height: 1),
        // List
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 36,
                        color: AppColors.textMuted.withValues(alpha: 0.3)),
                    const SizedBox(height: 10),
                    Text(
                      slot.isWeapon
                          ? 'No weapons in inventory'
                          : 'No ${slot.type} artifacts in inventory',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text('Buy from the Shop first',
                        style: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.6),
                            fontSize: 11)),
                  ]))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final el = shop.getElement(item.elementId);
                    final elColor = el != null
                        ? AppColors.getElementColor(el.type)
                        : AppColors.primary;
                    final isCurrent =
                        currentItem?.inventoryId == item.inventoryId;
                    return GestureDetector(
                      onTap: () => onEquip(item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? elColor.withValues(alpha: 0.1)
                              : AppColors.surfaceCard,
                          borderRadius:
                              BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: isCurrent
                                ? elColor.withValues(alpha: 0.45)
                                : AppColors.cardBorder,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: elColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: item.imageUrl.isNotEmpty
                                ? Image.network(item.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Icon(
                                        slot.icon, color: elColor, size: 22))
                                : Icon(slot.icon, color: elColor, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(item.name,
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Row(children: [
                                Text(item.type,
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10)),
                                if (el != null) ...[
                                  const SizedBox(width: 4),
                                  ElementBadge(
                                      elementType: el.type,
                                      compact: true,
                                      showLabel: false),
                                ],
                                const SizedBox(width: 6),
                                if (item is WeaponModel)
                                  Text('ATK +${item.damage}',
                                      style: TextStyle(
                                          color: AppColors.danger,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600))
                                else if (item is ArtifactModel)
                                  Text(
                                      _statLabel(item.type, item.primaryStat),
                                      style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                              ]),
                            ]),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: elColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text('Equipped',
                                  style: TextStyle(
                                      color: elColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            )
                          else
                            Icon(Icons.add_circle_outline_rounded,
                                size: 20,
                                color: AppColors.textMuted.withValues(alpha: 0.4)),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  String _statLabel(String type, double primary) {
    switch (type) {
      case 'Flower':  return 'HP +${primary.toInt()}';
      case 'Feather': return 'ATK +${primary.toInt()}';
      case 'Sands':   return 'ATK +${primary.toStringAsFixed(0)}%';
      case 'Goblet':  return 'DMG +${primary.toStringAsFixed(0)}%';
      case 'Circlet': return 'CR +${primary.toStringAsFixed(0)}%';
      default:        return '+${primary.toStringAsFixed(0)}';
    }
  }
}

// ── Character CustomPainter ───────────────────────────────────────────────────

class _CharacterPainter extends CustomPainter {
  final double rotation;
  final Color glow;
  final double breathe;
  final bool hasWeapon;
  final Color weaponGlow;

  const _CharacterPainter({
    required this.rotation,
    required this.glow,
    required this.breathe,
    this.hasWeapon = false,
    required this.weaponGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final squish = cos(rotation);
    final breathY = sin(breathe * pi) * 3.0;

    // Apply perspective squish + breathing
    canvas.save();
    canvas.translate(cx, 0);
    canvas.scale(squish, 1.0);
    canvas.translate(-cx, 0);
    canvas.translate(0, -breathY);

    _drawGroundShadow(canvas, cx, size.height);
    if (hasWeapon) _drawWeapon(canvas, cx, size.height);
    _drawBody(canvas, cx, size.height);

    canvas.restore();
  }

  void _drawGroundShadow(Canvas canvas, double cx, double h) {
    final paint = Paint()
      ..shader = RadialGradient(colors: [
        glow.withValues(alpha: 0.22),
        Colors.transparent,
      ]).createShader(Rect.fromCenter(
          center: Offset(cx, h * 0.96), width: 100, height: 28));
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, h * 0.96), width: 100, height: 24),
        paint);
  }

  void _drawWeapon(Canvas canvas, double cx, double h) {
    final s = h / 340.0;
    final glowP = Paint()
      ..color = weaponGlow.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    final darkP = Paint()..color = const Color(0xFF1A2535);
    final edgeP = Paint()
      ..color = weaponGlow.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final wx = cx + 40 * s;
    final top = h * 0.22;
    final bot = h * 0.75;

    // Blade
    final blade = Path()
      ..moveTo(wx - 3 * s, top)
      ..lineTo(wx + 5 * s, top + 8 * s)
      ..lineTo(wx + 3 * s, bot)
      ..lineTo(wx - 4 * s, bot - 3 * s)
      ..close();
    canvas.drawPath(blade, glowP);
    canvas.drawPath(blade, darkP);
    canvas.drawPath(blade, edgeP);

    // Guard
    final guard = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(wx + 1 * s, top + 38 * s),
            width: 18 * s,
            height: 5 * s),
        Radius.circular(2 * s));
    canvas.drawRRect(guard, darkP);
    canvas.drawRRect(guard, edgeP);

    // Hilt
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(wx + 1 * s, top + 53 * s),
                width: 7 * s,
                height: 24 * s),
            Radius.circular(3 * s)),
        darkP);
  }

  void _drawBody(Canvas canvas, double cx, double h) {
    final s = h / 340.0;

    // Outer glow
    final glowP = Paint()
      ..color = glow.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    // Fill silhouette
    final fillP = Paint()..color = const Color(0xFF0D1520);

    // Edge highlight
    final edgeP = Paint()
      ..color = glow.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final body = _buildPath(cx, h, s);
    canvas.drawPath(body, glowP);
    canvas.drawPath(body, fillP);
    canvas.drawPath(body, edgeP);

    _drawFace(canvas, cx, h, s);
  }

  Path _buildPath(double cx, double h, double s) {
    final path = Path();

    // ── Hair / head ───────────────────────────────────────────────────────────
    final hcy = h * 0.118; // head center Y
    final hr = 21 * s;     // head radius

    // Hair spikes
    path.moveTo(cx - 15 * s, hcy - hr + 4 * s);
    path.quadraticBezierTo(
        cx - 13 * s, hcy - hr - 20 * s, cx - 3 * s, hcy - hr - 11 * s);
    path.quadraticBezierTo(
        cx + 1 * s, hcy - hr - 28 * s, cx + 9 * s, hcy - hr - 12 * s);
    path.quadraticBezierTo(
        cx + 16 * s, hcy - hr - 18 * s, cx + 17 * s, hcy - hr + 5 * s);
    path.arcToPoint(Offset(cx - 15 * s, hcy - hr + 4 * s),
        radius: Radius.circular(hr * 1.1), clockwise: false);
    path.close();

    // Head oval
    path.addOval(Rect.fromCircle(center: Offset(cx, hcy), radius: hr));

    // Neck
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5.5 * s, hcy + hr - 5 * s, 11 * s, 14 * s),
        Radius.circular(3 * s)));

    // ── Torso ─────────────────────────────────────────────────────────────────
    final ct = hcy + hr + 7 * s; // chest top
    final cb = ct + 52 * s;      // chest bottom

    path.moveTo(cx - 26 * s, ct);
    path.quadraticBezierTo(cx - 32 * s, ct + 12 * s, cx - 30 * s, ct + 28 * s);
    path.lineTo(cx - 19 * s, cb);
    path.lineTo(cx + 19 * s, cb);
    path.quadraticBezierTo(cx + 30 * s, ct + 28 * s, cx + 26 * s, ct);
    path.close();

    // ── Arms ──────────────────────────────────────────────────────────────────
    // Left arm
    path.moveTo(cx - 26 * s, ct + 3 * s);
    path.quadraticBezierTo(
        cx - 42 * s, ct + 24 * s, cx - 35 * s, ct + 52 * s);
    path.lineTo(cx - 27 * s, ct + 50 * s);
    path.quadraticBezierTo(
        cx - 32 * s, ct + 24 * s, cx - 18 * s, ct + 3 * s);
    path.close();
    path.addOval(Rect.fromCenter(
        center: Offset(cx - 31 * s, ct + 55 * s),
        width: 12 * s, height: 10 * s));

    // Right arm
    path.moveTo(cx + 26 * s, ct + 3 * s);
    path.quadraticBezierTo(
        cx + 40 * s, ct + 22 * s, cx + 38 * s, ct + 50 * s);
    path.lineTo(cx + 30 * s, ct + 48 * s);
    path.quadraticBezierTo(
        cx + 30 * s, ct + 22 * s, cx + 18 * s, ct + 3 * s);
    path.close();
    path.addOval(Rect.fromCenter(
        center: Offset(cx + 34 * s, ct + 53 * s),
        width: 12 * s, height: 10 * s));

    // ── Belt ──────────────────────────────────────────────────────────────────
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 16 * s, cb - 2 * s, 32 * s, 9 * s),
        Radius.circular(4 * s)));

    // ── Lower garment ─────────────────────────────────────────────────────────
    final st = cb + 6 * s;
    path.moveTo(cx - 16 * s, st);
    path.lineTo(cx + 16 * s, st);
    path.quadraticBezierTo(
        cx + 28 * s, st + 22 * s, cx + 25 * s, st + 50 * s);
    path.lineTo(cx - 25 * s, st + 50 * s);
    path.quadraticBezierTo(
        cx - 28 * s, st + 22 * s, cx - 16 * s, st);
    path.close();

    // ── Legs ─────────────────────────────────────────────────────────────────
    final lt = st + 46 * s;
    // Left
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 20 * s, lt, 15 * s, 58 * s),
        Radius.circular(6 * s)));
    // Right
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 5 * s, lt, 15 * s, 58 * s),
        Radius.circular(6 * s)));
    // Left foot
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 24 * s, lt + 52 * s, 20 * s, 10 * s),
        Radius.circular(5 * s)));
    // Right foot
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 4 * s, lt + 52 * s, 20 * s, 10 * s),
        Radius.circular(5 * s)));

    return path;
  }

  void _drawFace(Canvas canvas, double cx, double h, double s) {
    final hcy = h * 0.118;

    // Eyes — glowing dots
    final eyeP = Paint()
      ..color = glow.withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final pupilP = Paint()..color = glow;

    for (final ex in [-7.5 * s, 7.5 * s]) {
      canvas.drawCircle(Offset(cx + ex, hcy + 1 * s), 2.8 * s, eyeP);
      canvas.drawCircle(Offset(cx + ex, hcy + 1 * s), 1.5 * s, pupilP);
    }
  }

  @override
  bool shouldRepaint(_CharacterPainter old) =>
      old.rotation != rotation ||
      old.glow != glow ||
      old.breathe != breathe ||
      old.hasWeapon != hasWeapon;
}

// ── Background glow ───────────────────────────────────────────────────────────

class _BackgroundGlowPainter extends CustomPainter {
  final Color color;
  final double intensity;
  const _BackgroundGlowPainter({required this.color, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final alpha = 0.04 + intensity * 0.07;
    final paint = Paint()
      ..shader = RadialGradient(
              colors: [color.withValues(alpha: alpha), Colors.transparent])
          .createShader(Rect.fromCenter(
              center: Offset(cx, cy),
              width: size.width * 1.4,
              height: size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_BackgroundGlowPainter old) =>
      old.intensity != intensity || old.color != color;
}

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/battle_provider.dart';
import '../widgets/stat_bar.dart';
import '../widgets/shared_ui.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = auth.playerStats;
    final inventory = context.watch<InventoryProvider>();
    final battles = context.watch<BattleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner — gradient card
              _WelcomeBanner(
                name: auth.user?.name ?? 'Traveler',
                isAdmin: auth.isAdmin,
                mora: stats.formattedMoney,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.15, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 20),

              // Player Stats
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: 'Player Stats', icon: CupertinoIcons.chart_bar, color: AppColors.primary),
                    const SizedBox(height: 16),
                    StatBar(label: 'HP', value: '${auth.effectiveHp}', progress: (auth.effectiveHp / 50000).clamp(0.0, 1.0), color: AppColors.success, icon: CupertinoIcons.heart_fill),
                    const SizedBox(height: 12),
                    StatBar(label: 'ATK', value: '${auth.effectiveDamage}', progress: (auth.effectiveDamage / 10000).clamp(0.0, 1.0), color: AppColors.danger, icon: CupertinoIcons.bolt),
                    const SizedBox(height: 12),
                    StatBar(label: 'CRIT Rate', value: '${auth.effectiveCritRate.toStringAsFixed(1)}%', progress: (auth.effectiveCritRate / 100).clamp(0.0, 1.0), color: AppColors.info, icon: CupertinoIcons.scope),
                    const SizedBox(height: 12),
                    StatBar(label: 'CRIT DMG', value: '${auth.effectiveCritDmg.toStringAsFixed(0)}%', progress: (auth.effectiveCritDmg / 500).clamp(0.0, 1.0), color: AppColors.electro, icon: CupertinoIcons.bolt_fill),
                  ],
                ),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),

              // Quick Stats row — colored gradient cards
              Row(
                children: [
                  Expanded(child: _StatCard(icon: CupertinoIcons.hammer, value: '${inventory.weaponCount}', label: 'Weapons', color: AppColors.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(icon: CupertinoIcons.star_fill, value: '${inventory.artifactCount}', label: 'Artifacts', color: AppColors.electro)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(icon: CupertinoIcons.shield, value: '${battles.battleHistory.length}', label: 'Battles', color: AppColors.pyro)),
                ],
              )
                  .animate(delay: 180.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 22),

              if (!auth.isAdmin) ...[
                SectionTitle(title: 'Character', icon: CupertinoIcons.person, color: AppColors.secondary),
                const SizedBox(height: 12),
                _CharacterCard(
                  onManage: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EquipmentPage()),
                  ),
                )
                    .animate(delay: 240.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 22),
              ],

              // Quick Actions
              SectionTitle(title: 'Quick Actions', icon: CupertinoIcons.square_grid_2x2),
              const SizedBox(height: 12),
              if (auth.isAdmin) ...[
                Row(
                  children: [
                    Expanded(child: _ActionCard(icon: CupertinoIcons.cube_box, label: 'Manage Items', subtitle: 'Add, edit, delete', color: AppColors.secondary, onTap: () => _navigateToTab(1))),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionCard(icon: CupertinoIcons.flame, label: 'Manage Enemies', subtitle: 'Add, edit, delete', color: AppColors.pyro, onTap: () => _navigateToTab(2))),
                  ],
                ),
                const SizedBox(height: 10),
                _ActionCard(icon: CupertinoIcons.person_crop_circle, label: 'Profile', subtitle: 'Settings & theme', color: AppColors.primary, onTap: () => _navigateToTab(3)),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _ActionCard(icon: CupertinoIcons.bag, label: 'Shop', subtitle: 'Browse items', color: AppColors.primary, onTap: () => _navigateToTab(1))),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionCard(icon: CupertinoIcons.shield, label: 'Battle', subtitle: 'Earn Mora', color: AppColors.pyro, onTap: () => _navigateToTab(3))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _ActionCard(icon: CupertinoIcons.archivebox, label: 'Inventory', subtitle: '${inventory.totalItems} items', color: AppColors.electro, onTap: () => _navigateToTab(2))),
                    const SizedBox(width: 10),
                    Expanded(child: _ActionCard(icon: CupertinoIcons.person_crop_circle, label: 'Profile', subtitle: 'Settings & theme', color: AppColors.secondary, onTap: () => _navigateToTab(4))),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    Navigator.pushReplacementNamed(context, '/main', arguments: index);
  }
}

// Premium gradient welcome banner
class _WelcomeBanner extends StatelessWidget {
  final String name;
  final bool isAdmin;
  final String mora;
  const _WelcomeBanner({required this.name, required this.isAdmin, required this.mora});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.18),
            AppColors.secondary.withOpacity(0.10),
            AppColors.surfaceCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 3),
                Row(children: [
                  Flexible(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.textPrimary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(color: AppColors.secondary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(CupertinoIcons.location, size: 11, color: AppColors.primary.withOpacity(0.6)),
                  const SizedBox(width: 3),
                  Text(
                    'Teyvat Marketplace',
                    style: TextStyle(color: AppColors.primary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MoraBadge(amount: mora),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatefulWidget {
  final VoidCallback onManage;
  const _CharacterCard({required this.onManage});
  @override
  State<_CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<_CharacterCard> with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final shop = context.watch<ShopProvider>();
    final weapon = auth.equippedWeapon;
    final weaponEl = weapon != null ? shop.getElement(weapon.elementId) : null;
    final glowColor = weaponEl != null ? AppColors.getElementColor(weaponEl.type) : AppColors.primary;

    return GestureDetector(
      onTap: widget.onManage,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 158,
          child: Row(children: [
            SizedBox(
              width: 110,
              child: AnimatedBuilder(
                animation: _breathe,
                builder: (_, _) => CustomPaint(
                  painter: _MiniCharacterPainter(glow: glowColor, breathe: _breathe.value, hasWeapon: weapon != null),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CHARACTER', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                    const SizedBox(height: 10),
                    _EquipRow(icon: CupertinoIcons.hammer, label: weapon?.name ?? 'No weapon', color: weapon != null ? AppColors.primary : AppColors.textMuted, isEmpty: weapon == null),
                    const SizedBox(height: 7),
                    _EquipRow(icon: CupertinoIcons.star_fill, label: '${auth.equippedArtifactCount}/5 Artifacts', color: auth.equippedArtifactCount > 0 ? AppColors.electro : AppColors.textMuted, isEmpty: auth.equippedArtifactCount == 0),
                    const Spacer(),
                    Row(children: [
                      _MiniStat('HP', '${auth.effectiveHp}', AppColors.success),
                      const SizedBox(width: 12),
                      _MiniStat('ATK', '${auth.effectiveDamage}', AppColors.danger),
                      const SizedBox(width: 12),
                      _MiniStat('CR', '${auth.effectiveCritRate.toStringAsFixed(0)}%', AppColors.info),
                    ]),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onManage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: BorderSide(color: AppColors.secondary.withOpacity(0.45)),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Manage Equipment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _EquipRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isEmpty;
  const _EquipRow({required this.icon, required this.label, required this.color, required this.isEmpty});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: isEmpty ? AppColors.textMuted.withOpacity(0.5) : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
    ]);
  }
}

class _MiniCharacterPainter extends CustomPainter {
  final Color glow;
  final double breathe;
  final bool hasWeapon;
  const _MiniCharacterPainter({required this.glow, required this.breathe, this.hasWeapon = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final s = size.height / 340.0;
    final breathY = sin(breathe * pi) * 2.0;

    canvas.save();
    canvas.translate(0, -breathY);

    final glowP = Paint()..color = glow.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    final fillP = Paint()..color = const Color(0xFF0D1520);
    final edgeP = Paint()..color = glow.withOpacity(0.45)..style = PaintingStyle.stroke..strokeWidth = 1.2;

    final path = _buildPath(cx, size.height, s);
    canvas.drawPath(path, glowP);
    canvas.drawPath(path, fillP);
    canvas.drawPath(path, edgeP);

    final eyeP = Paint()..color = glow.withOpacity(0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final hcy = size.height * 0.118;
    for (final ex in [-7.5 * s, 7.5 * s]) {
      canvas.drawCircle(Offset(cx + ex, hcy + 1 * s), 2.5 * s, eyeP);
      canvas.drawCircle(Offset(cx + ex, hcy + 1 * s), 1.2 * s, Paint()..color = glow);
    }

    canvas.restore();
  }

  Path _buildPath(double cx, double h, double s) {
    final path = Path();
    final hcy = h * 0.118;
    final hr = 21 * s;

    path.moveTo(cx - 15 * s, hcy - hr + 4 * s);
    path.quadraticBezierTo(cx - 13 * s, hcy - hr - 20 * s, cx - 3 * s, hcy - hr - 11 * s);
    path.quadraticBezierTo(cx + 1 * s, hcy - hr - 28 * s, cx + 9 * s, hcy - hr - 12 * s);
    path.quadraticBezierTo(cx + 16 * s, hcy - hr - 18 * s, cx + 17 * s, hcy - hr + 5 * s);
    path.arcToPoint(Offset(cx - 15 * s, hcy - hr + 4 * s), radius: Radius.circular(hr * 1.1), clockwise: false);
    path.close();

    path.addOval(Rect.fromCircle(center: Offset(cx, hcy), radius: hr));
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 5.5 * s, hcy + hr - 5 * s, 11 * s, 14 * s), Radius.circular(3 * s)));

    final ct = hcy + hr + 7 * s;
    final cb = ct + 52 * s;

    path.moveTo(cx - 26 * s, ct);
    path.quadraticBezierTo(cx - 32 * s, ct + 12 * s, cx - 30 * s, ct + 28 * s);
    path.lineTo(cx - 19 * s, cb);
    path.lineTo(cx + 19 * s, cb);
    path.quadraticBezierTo(cx + 30 * s, ct + 28 * s, cx + 26 * s, ct);
    path.close();

    path.moveTo(cx - 26 * s, ct + 3 * s);
    path.quadraticBezierTo(cx - 42 * s, ct + 24 * s, cx - 35 * s, ct + 52 * s);
    path.lineTo(cx - 27 * s, ct + 50 * s);
    path.quadraticBezierTo(cx - 32 * s, ct + 24 * s, cx - 18 * s, ct + 3 * s);
    path.close();
    path.addOval(Rect.fromCenter(center: Offset(cx - 31 * s, ct + 55 * s), width: 12 * s, height: 10 * s));

    path.moveTo(cx + 26 * s, ct + 3 * s);
    path.quadraticBezierTo(cx + 40 * s, ct + 22 * s, cx + 38 * s, ct + 50 * s);
    path.lineTo(cx + 30 * s, ct + 48 * s);
    path.quadraticBezierTo(cx + 30 * s, ct + 22 * s, cx + 18 * s, ct + 3 * s);
    path.close();
    path.addOval(Rect.fromCenter(center: Offset(cx + 34 * s, ct + 53 * s), width: 12 * s, height: 10 * s));

    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 16 * s, cb - 2 * s, 32 * s, 9 * s), Radius.circular(4 * s)));

    final st = cb + 6 * s;
    path.moveTo(cx - 16 * s, st);
    path.lineTo(cx + 16 * s, st);
    path.quadraticBezierTo(cx + 28 * s, st + 22 * s, cx + 25 * s, st + 50 * s);
    path.lineTo(cx - 25 * s, st + 50 * s);
    path.quadraticBezierTo(cx - 28 * s, st + 22 * s, cx - 16 * s, st);
    path.close();

    final lt = st + 46 * s;
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 20 * s, lt, 15 * s, 58 * s), Radius.circular(6 * s)));
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 5 * s, lt, 15 * s, 58 * s), Radius.circular(6 * s)));
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 24 * s, lt + 52 * s, 20 * s, 10 * s), Radius.circular(5 * s)));
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 4 * s, lt + 52 * s, 20 * s, 10 * s), Radius.circular(5 * s)));

    return path;
  }

  @override
  bool shouldRepaint(_MiniCharacterPainter old) => old.glow != glow || old.breathe != breathe || old.hasWeapon != hasWeapon;
}

// Stat card with gradient background
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.14), color.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [color, color.withOpacity(0.65)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    );
  }
}

// Action card with accent bar
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          // Left accent bar
          Container(
            width: 3,
            height: 38,
            margin: const EdgeInsets.only(left: 0, right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.25)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
          ),
          Icon(CupertinoIcons.arrow_right, color: AppColors.textMuted.withOpacity(0.35), size: 15),
        ]),
      ),
    );
  }
}

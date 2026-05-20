import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/enemy_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../providers/battle_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/element_badge.dart';
import '../widgets/shared_ui.dart';

// halaman pilih musuh

class BattlePage extends StatelessWidget {
  const BattlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final battle = context.watch<BattleProvider>();
    final auth   = context.watch<AuthProvider>();
    final shop   = context.watch<ShopProvider>();

    // ambil element player dari senjata yang dipake
    final weapon   = auth.equippedWeapon;
    final weaponEl = weapon != null ? shop.getElement(weapon.elementId) : null;
    final playerElement = weaponEl?.type;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Battle Arena',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Defeat enemies to earn Mora',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ])),
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder)),
                  child: const Icon(Icons.local_fire_department_rounded, color: AppColors.pyro, size: 18),
                ),
              ]),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PlayerPowerPanel(auth: auth, playerElement: playerElement),
            ),
            const SizedBox(height: 14),

            if (battle.battleHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    _BattleStat(
                        label: 'Battles',
                        value: '${battle.battleHistory.length}',
                        icon: Icons.shield_rounded,
                        color: AppColors.pyro),
                    Container(width: 1, height: 28, color: AppColors.divider),
                    _BattleStat(
                        label: 'Wins',
                        value: '${battle.battleHistory.where((b) => b.won).length}',
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.secondary),
                    Container(width: 1, height: 28, color: AppColors.divider),
                    _BattleStat(
                        label: 'Mora Won',
                        value: _formatMora(battle.battleHistory.fold(0.0, (s, b) => s + b.moneyEarned)),
                        icon: Icons.monetization_on_rounded,
                        color: AppColors.secondary),
                  ]),
                ),
              ),
            if (battle.battleHistory.isNotEmpty) const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionTitle(
                  title: 'Enemies',
                  subtitle: '${battle.enemies.length} foes',
                  icon: Icons.pest_control_rounded,
                  color: AppColors.pyro),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: battle.isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: battle.enemies.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final enemy = battle.enemies[index];
                        final element = shop.getElement(enemy.elementId);
                        final elementColor = element != null
                            ? AppColors.getElementColor(element.type)
                            : AppColors.pyro;
                        final reaction = getElementReaction(playerElement, element?.type);
                        return _EnemyCard(
                          enemy: enemy,
                          elementType: element?.type,
                          elementColor: elementColor,
                          playerAtk: auth.effectiveDamage,
                          playerHp: auth.effectiveHp,
                          reaction: reaction,
                          onFight: () => _startBattle(context, enemy, element?.type),
                        ).animate(delay: (index * 40).ms)
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.15, duration: 350.ms, curve: Curves.easeOutCubic);
                      },
                    ),
            ),

            if (battle.battleHistory.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: SectionTitle(
                    title: 'Recent Battles', icon: Icons.history_rounded, color: AppColors.primary),
              ),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  itemCount: battle.battleHistory.take(10).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) =>
                      _HistoryChip(result: battle.battleHistory[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startBattle(BuildContext context, EnemyModel enemy, String? enemyElement) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BattleArenaPage(enemy: enemy, enemyElement: enemyElement)),
    );
  }

  String _formatMora(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _PlayerPowerPanel extends StatelessWidget {
  final AuthProvider auth;
  final String? playerElement;
  const _PlayerPowerPanel({required this.auth, this.playerElement});

  @override
  Widget build(BuildContext context) {
    final hasWeapon = auth.equippedWeapon != null;
    final artifactCount = auth.equippedArtifactCount;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Label row
        Row(children: [
          Icon(Icons.person_pin_rounded, size: 13, color: AppColors.secondary),
          const SizedBox(width: 5),
          Text('YOUR POWER',
              style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const Spacer(),
          if (playerElement != null)
            ElementBadge(elementType: playerElement!, compact: true, showLabel: false),
          if (!hasWeapon)
            Text('  No weapon equipped',
                style: TextStyle(color: AppColors.warning, fontSize: 9, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 10),
        // Stats row
        Row(children: [
          _PowerStat('HP',  '${auth.effectiveHp}',                    AppColors.success,  Icons.favorite_rounded),
          _vDivider(),
          _PowerStat('ATK', '${auth.effectiveDamage}',                 AppColors.danger,   Icons.flash_on_rounded),
          _vDivider(),
          _PowerStat('CR',  '${auth.effectiveCritRate.toStringAsFixed(1)}%', AppColors.info,    Icons.gps_fixed_rounded),
          _vDivider(),
          _PowerStat('CD',  '${auth.effectiveCritDmg.toStringAsFixed(0)}%',  AppColors.electro, Icons.bolt_rounded),
        ]),
        const SizedBox(height: 10),
        // Equipment indicator row
        Row(children: [
          _EquipBadge(icon: Icons.gavel_rounded, label: hasWeapon ? (auth.equippedWeapon!.name) : 'No Weapon', equipped: hasWeapon, color: AppColors.primary),
          const SizedBox(width: 8),
          _EquipBadge(icon: Icons.diamond_rounded, label: '$artifactCount/5 Artifacts', equipped: artifactCount > 0, color: AppColors.electro),
        ]),
      ]),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 26, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 2));
}

class _PowerStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _PowerStat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
      ]),
    );
  }
}

class _EquipBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool equipped;
  final Color color;
  const _EquipBadge({required this.icon, required this.label, required this.equipped, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: equipped ? color.withOpacity(0.1) : AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: equipped ? color.withOpacity(0.3) : AppColors.divider,
          ),
        ),
        child: Row(children: [
          Icon(icon, size: 11, color: equipped ? color : AppColors.textMuted),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: equipped ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }
}

class _EnemyCard extends StatelessWidget {
  final EnemyModel enemy;
  final String? elementType;
  final Color elementColor;
  final int playerAtk, playerHp;
  final ElementReaction reaction;
  final VoidCallback onFight;

  const _EnemyCard({
    required this.enemy,
    this.elementType,
    required this.elementColor,
    required this.playerAtk,
    required this.playerHp,
    required this.reaction,
    required this.onFight,
  });

  // Matchup rating based on player stats vs enemy
  _Matchup _calcMatchup() {
    final effectiveAtk = playerAtk * reaction.multiplier;
    final turnsToKill = (enemy.hp / effectiveAtk).ceil().clamp(1, 999);
    final turnsToSurvive = (playerHp / enemy.damage.clamp(1, 999999)).ceil().clamp(1, 999);

    String label;
    Color color;
    double ratio = turnsToSurvive / turnsToKill;

    if (turnsToKill <= 2) {
      label = 'SWEEP'; color = AppColors.success;
    } else if (ratio >= 2.5) {
      label = 'EASY'; color = AppColors.success;
    } else if (ratio >= 1.2) {
      label = 'EVEN'; color = AppColors.warning;
    } else if (ratio >= 0.7) {
      label = 'TOUGH'; color = AppColors.pyro;
    } else {
      label = 'RISKY'; color = AppColors.danger;
    }

    return _Matchup(
      label: label,
      color: color,
      turnsToKill: turnsToKill,
      turnsToSurvive: turnsToSurvive,
      powerRatio: ratio.clamp(0.0, 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchup = _calcMatchup();
    final hasAdvantage = reaction.isAdvantage;
    final hasDisadvantage = reaction.isDisadvantage;

    return GestureDetector(
      onTap: onFight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: hasAdvantage
                ? AppColors.success.withOpacity(0.35)
                : hasDisadvantage
                    ? AppColors.warning.withOpacity(0.35)
                    : AppColors.cardBorder,
            width: (hasAdvantage || hasDisadvantage) ? 1.5 : 1.0,
          ),
          boxShadow: hasAdvantage
              ? [BoxShadow(color: AppColors.success.withOpacity(0.08), blurRadius: 8)]
              : null,
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
            child: Row(children: [
              // Enemy icon
              Stack(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: elementColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: enemy.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: EnemyImageWidget(
                            url: enemy.imageUrl,
                            width: 52, height: 52, fit: BoxFit.cover,
                            fallback: Icon(Icons.pest_control_rounded, color: elementColor, size: 26),
                          ),
                        )
                      : Icon(Icons.pest_control_rounded, color: elementColor, size: 26),
                ),
                // Advantage indicator
                if (hasAdvantage || hasDisadvantage)
                  Positioned(top: -2, right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: hasAdvantage ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasAdvantage ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 8, color: Colors.white,
                      ),
                    ),
                  ),
              ]),
              const SizedBox(width: 12),

              // Name + stats
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(enemy.name,
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                  // Matchup chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: matchup.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: matchup.color.withOpacity(0.35)),
                    ),
                    child: Text(matchup.label,
                        style: TextStyle(
                            color: matchup.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                  ),
                ]),
                const SizedBox(height: 6),
                // HP / DMG / Reward
                Row(children: [
                  Icon(Icons.favorite_rounded, size: 11, color: AppColors.success),
                  const SizedBox(width: 3),
                  Text('${enemy.hp}',
                      style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  Icon(Icons.flash_on_rounded, size: 11, color: AppColors.danger),
                  const SizedBox(width: 3),
                  Text('${enemy.damage}',
                      style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  if (elementType != null)
                    ElementBadge(elementType: elementType!, compact: true, showLabel: false),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: _diffColor(enemy.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(enemy.difficulty,
                        style: TextStyle(
                            color: _diffColor(enemy.difficulty), fontSize: 9, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 4),
                // Reward
                Row(children: [
                  Image.asset('assets/images/currency/Item_Mora.webp', width: 11, height: 11,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.monetization_on_rounded, size: 11, color: AppColors.secondary)),
                  const SizedBox(width: 3),
                  Text('~${enemy.estimatedReward.toStringAsFixed(0)} Mora',
                      style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w500)),
                ]),
              ])),

              const SizedBox(width: 8),
              Icon(Icons.play_arrow_rounded, color: elementColor.withOpacity(0.7), size: 22),
            ]),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Element reaction hint
              if (reaction.hasReaction)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Icon(
                      hasAdvantage ? Icons.bolt_rounded : Icons.shield_outlined,
                      size: 11,
                      color: hasAdvantage ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reaction.name} · ${reaction.bonus}',
                      style: TextStyle(
                          color: hasAdvantage ? AppColors.success : AppColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
              // Power ratio bar
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('~${matchup.turnsToKill} turns to kill',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                      Text('survives ~${matchup.turnsToSurvive} hits',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (matchup.powerRatio / 4.0).clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(matchup.color),
                      ),
                    ),
                  ]),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Easy':      return AppColors.success;
      case 'Medium':    return AppColors.warning;
      case 'Hard':      return AppColors.pyro;
      case 'Legendary': return AppColors.electro;
      default:          return AppColors.textMuted;
    }
  }
}

class _Matchup {
  final String label;
  final Color color;
  final int turnsToKill, turnsToSurvive;
  final double powerRatio;
  const _Matchup({
    required this.label,
    required this.color,
    required this.turnsToKill,
    required this.turnsToSurvive,
    required this.powerRatio,
  });
}

class _BattleStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _BattleStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
    ]));
  }
}

class _HistoryChip extends StatelessWidget {
  final BattleResultModel result;
  const _HistoryChip({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.won ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(result.won ? Icons.emoji_events_rounded : Icons.close_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(result.won ? 'Victory' : 'Defeat',
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 3),
        Text(result.enemyName,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w500),
            maxLines: 1),
        if (result.won)
          Text('+${result.moneyEarned.toStringAsFixed(0)} Mora',
              style: TextStyle(color: AppColors.secondary, fontSize: 9)),
      ]),
    );
  }
}

// arena pertarungan

enum _BattlePhase { idle, playerAttack, enemyAttack, result }

class BattleArenaPage extends StatefulWidget {
  final EnemyModel enemy;
  final String? enemyElement;
  const BattleArenaPage({super.key, required this.enemy, this.enemyElement});

  @override
  State<BattleArenaPage> createState() => _BattleArenaPageState();
}

class _BattleArenaPageState extends State<BattleArenaPage>
    with TickerProviderStateMixin {
  late int _playerHp;
  late int _playerMaxHp;
  late int _enemyHp;
  int _turnCount = 0;
  int _totalPlayerDamage = 0;
  int _totalEnemyDamage = 0;
  _BattlePhase _phase = _BattlePhase.idle;
  bool _done = false;
  String? _playerElement;
  double _elementMult = 1.0;
  ElementReaction _reaction = noReaction;
  String _lastLog = 'Choose your action!';
  int? _lastPlayerDmg;
  bool _lastPlayerCrit = false;
  int? _lastEnemyDmg;
  bool _lastEnemyCrit = false;
  TurnBattleResult? _finalResult;

  // Heavy Strike cooldown (0 = ready)
  int _heavyCooldown = 0;

  late AnimationController _shakeCtrl;
  late AnimationController _playerShakeCtrl;
  late AnimationController _flashCtrl;
  late Animation<double> _shake;
  late Animation<double> _playerShake;
  late Animation<double> _flash;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final shop = context.read<ShopProvider>();
    _playerMaxHp = auth.effectiveHp.clamp(100, 99999);
    _playerHp = _playerMaxHp;
    _enemyHp = widget.enemy.hp;

    final weapon = auth.equippedWeapon;
    if (weapon != null) {
      final el = shop.getElement(weapon.elementId);
      _playerElement = el?.type;
    }
    _reaction = getElementReaction(_playerElement, widget.enemyElement);
    _elementMult = _reaction.multiplier;

    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _playerShakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _shake = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut));
    _playerShake = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _playerShakeCtrl, curve: Curves.elasticOut));
    _flash = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _playerShakeCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  Future<void> _attack({bool heavy = false}) async {
    if (_done || _phase != _BattlePhase.idle) return;
    if (heavy && _heavyCooldown > 0) return;

    final auth = context.read<AuthProvider>();
    final random = Random();

    setState(() {
      _phase = _BattlePhase.playerAttack;
      _lastPlayerDmg = null;
      _lastEnemyDmg = null;
    });

    // Player damage calc
    final baseDmg = auth.effectiveDamage;
    final heavyMult = heavy ? 1.85 : 1.0;
    final critChance = auth.effectiveCritRate / 100;
    final critDmg = auth.effectiveCritDmg / 100;
    final isCrit = random.nextDouble() < critChance;
    final critMult = isCrit ? critDmg : 1.0;
    final variance = 0.9 + random.nextDouble() * 0.2;
    final dmgDealt = (baseDmg * _elementMult * critMult * heavyMult * variance)
        .round()
        .clamp(1, 999999);

    _enemyHp = (_enemyHp - dmgDealt).clamp(0, widget.enemy.hp);
    _totalPlayerDamage += dmgDealt;
    _lastPlayerDmg = dmgDealt;
    _lastPlayerCrit = isCrit;
    _turnCount++;

    if (heavy) _heavyCooldown = 2;

    final advantageText = _reaction.hasReaction && _reaction.name != 'Crystallize'
        ? ' · ${_reaction.name}!'
        : '';
    final heavyText = heavy ? '[Heavy] ' : '';

    setState(() {
      _lastLog = isCrit
          ? '${heavyText}CRITICAL HIT! $dmgDealt dmg$advantageText'
          : '${heavyText}You dealt $dmgDealt dmg$advantageText';
    });

    _shakeCtrl.forward(from: 0);
    _flashCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 650));

    if (_enemyHp <= 0) {
      await _finish(true, auth);
      return;
    }

    setState(() => _phase = _BattlePhase.enemyAttack);
    await Future.delayed(const Duration(milliseconds: 300));

    // Enemy attack
    final enemyCritChance = _enemyCritRate(widget.enemy.difficulty);
    final enemyCritDmgMult = 1.5 + random.nextDouble();
    final enemyCrit = random.nextDouble() < enemyCritChance;
    final enemyCritMult = enemyCrit ? enemyCritDmgMult : 1.0;
    final enemyEleMult = elementMultiplier(widget.enemyElement, _playerElement);
    final enemyVariance = 0.9 + random.nextDouble() * 0.2;
    final enemyDmg = (widget.enemy.damage * enemyEleMult * enemyCritMult * enemyVariance)
        .round()
        .clamp(1, 999999);

    _playerHp = (_playerHp - enemyDmg).clamp(0, _playerMaxHp);
    _totalEnemyDamage += enemyDmg;
    _lastEnemyDmg = enemyDmg;
    _lastEnemyCrit = enemyCrit;

    setState(() {
      _lastLog = enemyCrit
          ? '${widget.enemy.name} CRIT you for $enemyDmg!'
          : '${widget.enemy.name} hit you for $enemyDmg';
    });

    _playerShakeCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 650));

    if (_playerHp <= 0) {
      await _finish(false, auth);
      return;
    }

    // End of turn: reduce cooldown
    if (_heavyCooldown > 0) _heavyCooldown--;

    setState(() {
      _phase = _BattlePhase.idle;
      _lastLog = _heavyCooldown == 0 && _turnCount > 1
          ? 'Heavy Strike ready!'
          : 'Your turn!';
    });
  }

  Future<void> _finish(bool won, AuthProvider auth) async {
    final random = Random();
    final moneyEarned =
        won ? widget.enemy.estimatedReward * (0.8 + random.nextDouble() * 0.4) : 0.0;
    final battle = context.read<BattleProvider>();

    if (won) {
      await _persistBattleReward(auth, moneyEarned);
    }
    battle.resetBattle();

    _finalResult = TurnBattleResult(
      won: won,
      moneyEarned: moneyEarned,
      enemyName: widget.enemy.name,
      turns: [],
      totalPlayerDamage: _totalPlayerDamage,
      totalEnemyDamage: _totalEnemyDamage,
      remainingEnemyHp: _enemyHp,
      remainingPlayerHp: _playerHp,
      elementAdvantage: _elementMult,
      reactionName: _reaction.name,
      reactionBonus: _reaction.bonus,
    );

    battle.battleHistory.insert(
      0,
      BattleResultModel(
        battleId: battle.battleHistory.length + 1,
        userId: '',
        enemyId: widget.enemy.id,
        enemyName: widget.enemy.name,
        moneyEarned: moneyEarned,
        won: won,
        battleDate: DateTime.now(),
        damageDealt: _totalPlayerDamage,
        damageTaken: _totalEnemyDamage,
        turnsCount: _turnCount,
      ),
    );

    setState(() {
      _done = true;
      _phase = _BattlePhase.result;
    });
  }

  Future<void> _persistBattleReward(AuthProvider auth, double amount) async {
    try {
      final res = await ApiService.post('/inventory/battle-reward', {'amount': amount});
      if (res.success && res.data != null) {
        // pakai total dari server biar sinkron
        final serverMoney = (res.data['money'] as num).toDouble();
        auth.setMoney(serverMoney);
      } else {
        auth.addMoney(amount);
      }
    } catch (_) {
      // error network - tambah local dulu, rekonsiliasi next login
      auth.addMoney(amount);
    }
  }


  double _enemyCritRate(String diff) {
    switch (diff) {
      case 'Easy':      return 0.05;
      case 'Medium':    return 0.10;
      case 'Hard':      return 0.15;
      case 'Legendary': return 0.20;
      default:          return 0.10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth         = context.watch<AuthProvider>();
    final shop         = context.watch<ShopProvider>();
    final enemyElement = shop.getElement(widget.enemy.elementId);
    final elementColor = enemyElement != null
        ? AppColors.getElementColor(enemyElement.type)
        : AppColors.pyro;
    final playerElementColor =
        _playerElement != null ? AppColors.getElementColor(_playerElement!) : AppColors.primary;

    if (_phase == _BattlePhase.result && _finalResult != null) {
      return _ResultScreen(
          result: _finalResult!, enemy: widget.enemy, onClose: () => Navigator.pop(context));
    }

    final heavyReady = _heavyCooldown == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // Background gradient tint from enemy element
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [elementColor.withOpacity(0.14), AppColors.background],
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.enemy.name,
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    if (enemyElement != null)
                      ElementBadge(elementType: enemyElement.type, compact: true),
                  ]),
                ),
                // Turn counter + difficulty
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: Text('Turn $_turnCount',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _diffColor(widget.enemy.difficulty).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(widget.enemy.difficulty,
                        style: TextStyle(
                            color: _diffColor(widget.enemy.difficulty),
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Icon(Icons.favorite_rounded, size: 11, color: AppColors.danger),
                    const SizedBox(width: 4),
                    Text('Enemy HP',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ]),
                  Text('${_enemyHp.clamp(0, 99999)} / ${widget.enemy.hp}',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ]),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: (_enemyHp / widget.enemy.hp).clamp(0.0, 1.0),
                    minHeight: 9,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(elementColor),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            Expanded(
              flex: 3,
              child: AnimatedBuilder(
                animation: _shake,
                builder: (_, child) => Transform.translate(
                  offset: Offset(sin(_shake.value * pi * 6) * 8, 0),
                  child: child,
                ),
                child: Center(
                  child: SizedBox(
                    width: 210,
                    height: 210,
                    child: AnimatedBuilder(
                      animation: _flash,
                      builder: (_, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          child!,
                          // hit flash dibatasi ke lingkaran
                          if (_flash.value > 0)
                            Opacity(
                              opacity: (1 - _flash.value) * 0.42,
                              child: Container(
                                width: 152,
                                height: 152,
                                decoration: const BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  elementColor.withOpacity(0.26),
                                  elementColor.withOpacity(0.08),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.52, 1.0],
                              ),
                            ),
                          ),
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: elementColor.withOpacity(0.20),
                                width: 1.0,
                              ),
                            ),
                          ),
                          Container(
                            width: 152,
                            height: 152,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceCard.withOpacity(0.35),
                              border: Border.all(
                                color: elementColor.withOpacity(0.50),
                                width: 2.0,
                              ),
                            ),
                          ),
                          if (enemyElement != null)
                            Opacity(
                              opacity: 0.07,
                              child: SizedBox(
                                width: 90,
                                height: 90,
                                child: Image.asset(
                                  elementAssetPath(enemyElement.type),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const SizedBox(),
                                ),
                              ),
                            ),
                          if (widget.enemy.imageUrl.isNotEmpty)
                            ClipOval(
                              child: EnemyImageWidget(
                                url: widget.enemy.imageUrl,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                                fallback: Icon(Icons.pest_control_rounded,
                                    color: elementColor, size: 60),
                              ),
                            )
                          else
                            Icon(Icons.pest_control_rounded,
                                color: elementColor, size: 60),
                          if (_lastPlayerDmg != null)
                            Positioned(
                              top: 8, right: 8,
                              child: _DamageNumber(
                                value: _lastPlayerDmg!,
                                isCrit: _lastPlayerCrit,
                                color: AppColors.danger,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withOpacity(0.85),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(_lastLog,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                // HP bar
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Text(auth.user?.name ?? 'Traveler',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    if (_playerElement != null) ...[
                      const SizedBox(width: 6),
                      ElementBadge(elementType: _playerElement!, compact: true, showLabel: false),
                    ],
                  ]),
                  Text('$_playerHp / $_playerMaxHp',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ]),
                const SizedBox(height: 5),
                AnimatedBuilder(
                  animation: _playerShake,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(sin(_playerShake.value * pi * 6) * 4, 0),
                    child: child,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: (_playerHp / _playerMaxHp).clamp(0.0, 1.0),
                      minHeight: 9,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        _playerHp / _playerMaxHp > 0.5
                            ? AppColors.success
                            : _playerHp / _playerMaxHp > 0.25
                                ? AppColors.warning
                                : AppColors.danger,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Enemy damage number
                if (_lastEnemyDmg != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _DamageNumber(
                        value: _lastEnemyDmg!, isCrit: _lastEnemyCrit, color: AppColors.danger),
                  ),

                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Center(child: _StatStrip('ATK', '${auth.effectiveDamage}', AppColors.danger, Icons.flash_on_rounded))),
                      Container(width: 1, height: 22, color: AppColors.divider),
                      Expanded(child: Center(child: _StatStrip('HEAVY', '${(auth.effectiveDamage * 1.85).round()}', AppColors.pyro, Icons.local_fire_department_rounded))),
                      Container(width: 1, height: 22, color: AppColors.divider),
                      Expanded(child: Center(child: _StatStrip('CR', '${auth.effectiveCritRate.toStringAsFixed(1)}%', AppColors.info, Icons.gps_fixed_rounded))),
                      Container(width: 1, height: 22, color: AppColors.divider),
                      Expanded(child: Center(child: _StatStrip('CD', '${auth.effectiveCritDmg.toStringAsFixed(0)}%', AppColors.electro, Icons.bolt_rounded))),
                      if (_reaction.hasReaction) ...[
                        Container(width: 1, height: 22, color: AppColors.divider),
                        Expanded(child: Center(child: _StatStrip(
                          _reaction.name.length > 7 ? _reaction.name.substring(0, 7) : _reaction.name,
                          _reaction.bonus,
                          _reaction.isAdvantage ? AppColors.success : AppColors.warning,
                          _reaction.isAdvantage ? Icons.arrow_upward_rounded : Icons.shield_outlined,
                        ))),
                      ],
                    ],
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Row(children: [
                // Normal Attack
                Expanded(
                  flex: 5,
                  child: GestureDetector(
                    onTap: _phase == _BattlePhase.idle ? () => _attack() : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 54,
                      decoration: BoxDecoration(
                        color: _phase == _BattlePhase.idle
                            ? playerElementColor
                            : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        boxShadow: _phase == _BattlePhase.idle
                            ? [BoxShadow(
                                color: playerElementColor.withOpacity(0.4),
                                blurRadius: 14, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Center(
                        child: _phase == _BattlePhase.idle
                            ? Column(mainAxisSize: MainAxisSize.min, children: [
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(Icons.flash_on_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  const Text('ATTACK',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1)),
                                ]),
                                Text('~${auth.effectiveDamage} dmg',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7), fontSize: 9)),
                              ])
                            : Row(mainAxisSize: MainAxisSize.min, children: [
                                SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.textMuted)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _phase == _BattlePhase.playerAttack
                                        ? 'Attacking...'
                                        : 'Enemy turn...',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Heavy Strike
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: (_phase == _BattlePhase.idle && heavyReady)
                        ? () => _attack(heavy: true)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 54,
                      decoration: BoxDecoration(
                        color: heavyReady && _phase == _BattlePhase.idle
                            ? AppColors.pyro
                            : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        border: Border.all(
                          color: heavyReady
                              ? AppColors.pyro.withOpacity(0.6)
                              : AppColors.cardBorder,
                        ),
                        boxShadow: heavyReady && _phase == _BattlePhase.idle
                            ? [BoxShadow(
                                color: AppColors.pyro.withOpacity(0.4),
                                blurRadius: 14, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Center(
                        child: heavyReady
                            ? Column(mainAxisSize: MainAxisSize.min, children: [
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.local_fire_department_rounded,
                                      color: _phase == _BattlePhase.idle
                                          ? Colors.white
                                          : AppColors.textMuted,
                                      size: 16),
                                  const SizedBox(width: 5),
                                  Text('HEAVY',
                                      style: TextStyle(
                                          color: _phase == _BattlePhase.idle
                                              ? Colors.white
                                              : AppColors.textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800)),
                                ]),
                                Text('×1.85 · CD:2',
                                    style: TextStyle(
                                        color: (_phase == _BattlePhase.idle
                                                ? Colors.white
                                                : AppColors.textMuted)
                                            .withOpacity(0.7),
                                        fontSize: 9)),
                              ])
                            : Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.hourglass_top_rounded,
                                    color: AppColors.textMuted.withOpacity(0.5), size: 16),
                                const SizedBox(height: 2),
                                Text('CD: $_heavyCooldown',
                                    style: TextStyle(
                                        color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                              ]),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Easy':      return AppColors.success;
      case 'Medium':    return AppColors.warning;
      case 'Hard':      return AppColors.pyro;
      case 'Legendary': return AppColors.electro;
      default:          return AppColors.textMuted;
    }
  }
}

class _StatStrip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatStrip(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 8, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _DamageNumber extends StatelessWidget {
  final int value;
  final bool isCrit;
  final Color color;
  const _DamageNumber({required this.value, required this.isCrit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      isCrit ? '$value CRIT!' : '-$value',
      style: TextStyle(
        color: isCrit ? AppColors.secondary : color,
        fontSize: isCrit ? 20 : 15,
        fontWeight: FontWeight.w800,
        shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 5)],
      ),
    );
  }
}

// layar hasil battle

class _ResultScreen extends StatelessWidget {
  final TurnBattleResult result;
  final EnemyModel enemy;
  final VoidCallback onClose;
  const _ResultScreen({required this.result, required this.enemy, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final won   = result.won;
    final color = won ? AppColors.secondary : AppColors.danger;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.15), AppColors.background],
              ),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(children: [
              // Icon
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(won ? Icons.emoji_events_rounded : Icons.close_rounded,
                    size: 44, color: color),
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),

              Text(won ? 'Victory!' : 'Defeat',
                  style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('vs ${enemy.name}', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 32),

              // Battle summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(children: [
                  Text('Battle Summary',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _StatRow(label: 'Damage Dealt', value: '${result.totalPlayerDamage}',
                      color: AppColors.danger, icon: Icons.flash_on_rounded),
                  const SizedBox(height: 10),
                  _StatRow(label: 'Damage Taken', value: '${result.totalEnemyDamage}',
                      color: AppColors.warning, icon: Icons.shield_outlined),
                  const SizedBox(height: 10),
                  _StatRow(label: 'Remaining Enemy HP', value: '${result.remainingEnemyHp}',
                      color: AppColors.success, icon: Icons.favorite_rounded),
                  const SizedBox(height: 10),
                  _StatRow(
                    label: 'Reaction',
                    value: result.reactionName.isNotEmpty
                        ? '${result.reactionName} ${result.reactionBonus}'
                        : 'Neutral',
                    color: result.elementAdvantage > 1.0
                        ? AppColors.success
                        : result.elementAdvantage < 1.0
                            ? AppColors.warning
                            : AppColors.textMuted,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  if (won) ...[
                    const SizedBox(height: 16),
                    Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.asset('assets/images/currency/Item_Mora.webp',
                          width: 22, height: 22,
                          errorBuilder: (_, _, _) => const Icon(
                              Icons.monetization_on_rounded, color: AppColors.secondary, size: 22)),
                      const SizedBox(width: 8),
                      Text('+${result.moneyEarned.toStringAsFixed(0)} Mora',
                          style: TextStyle(
                              color: AppColors.secondary, fontSize: 24, fontWeight: FontWeight.w800)),
                    ]),
                  ],
                ]),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button)),
                  ),
                  child: Text(won ? 'Continue' : 'Try Again',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatRow({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const Spacer(),
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    ]);
  }
}

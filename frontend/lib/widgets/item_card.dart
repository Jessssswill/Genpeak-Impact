import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import 'element_badge.dart';

class ItemCard extends StatefulWidget {
  final ShopItem item;
  final String? elementType;
  final VoidCallback? onTap;
  final bool isSetCard;

  const ItemCard({
    super.key,
    required this.item,
    this.elementType,
    this.onTap,
    this.isSetCard = false,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isWeapon = widget.item is WeaponModel;
    final elementColor = widget.elementType != null
        ? AppColors.getElementColor(widget.elementType!)
        : AppColors.primary;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: _pressed
                  ? elementColor.withValues(alpha: 0.35)
                  : elementColor.withValues(alpha: 0.18),
            ),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: elementColor.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image section ──
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 1.0],
                        colors: [
                          elementColor.withValues(alpha: 0.14),
                          AppColors.surface,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Image / fallback icon
                        Center(
                          child: widget.item.imageUrl.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.network(
                                    widget.item.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Icon(
                                      isWeapon
                                          ? Icons.gavel_rounded
                                          : Icons.diamond_rounded,
                                      size: 34,
                                      color: elementColor.withValues(alpha: 0.45),
                                    ),
                                    loadingBuilder:
                                        (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: elementColor
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  isWeapon
                                      ? Icons.gavel_rounded
                                      : Icons.diamond_rounded,
                                  size: 34,
                                  color: elementColor.withValues(alpha: 0.45),
                                ),
                        ),

                        // Element badge — top left
                        if (widget.elementType != null)
                          Positioned(
                            top: 7,
                            left: 7,
                            child: ElementBadge(
                              elementType: widget.elementType!,
                              compact: true,
                              showLabel: false,
                            ),
                          ),

                        // Stock badge — top right
                        Positioned(
                          top: 7,
                          right: 7,
                          child: _StockPill(stock: widget.item.stock),
                        ),
                      ],
                    ),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(),
                      )
                      .shimmer(
                        duration: 1400.ms,
                        color: elementColor.withValues(alpha: 0.18),
                        angle: 0.4,
                      )
                      .then(delay: 2600.ms),
                ),

                // ── Info section ──
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: elementColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name + type
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isSetCard
                                  ? widget.item.setName
                                  : widget.item.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.item.type,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),

                        // Price
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_rounded,
                              size: 12,
                              color: AppColors.secondary.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _formatPrice(widget.item.price),
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return price.toStringAsFixed(0);
  }
}

class _StockPill extends StatelessWidget {
  final int stock;
  const _StockPill({required this.stock});

  @override
  Widget build(BuildContext context) {
    final inStock = stock > 0;
    final color = inStock ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        inStock ? '×$stock' : 'Sold',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

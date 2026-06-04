import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final accent = widget.elementType != null
        ? AppColors.getElementColor(widget.elementType!)
        : AppColors.primary;
    final fallbackIcon = isWeapon ? CupertinoIcons.bolt_fill : CupertinoIcons.star_fill;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image area ──────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent.withOpacity(0.18),
                          accent.withOpacity(0.04),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Hero(
                            tag: 'item_image_${widget.item.id}',
                            child: widget.item.imageUrl.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.item.imageUrl,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, _, _) => Icon(fallbackIcon,
                                          size: 32, color: accent.withOpacity(0.4)),
                                      placeholder: (_, _) => const SizedBox.shrink(),
                                    ),
                                  )
                                : Icon(fallbackIcon,
                                    size: 32, color: accent.withOpacity(0.4)),
                          ),
                        ),
                        if (widget.elementType != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: ElementBadge(
                              elementType: widget.elementType!,
                              compact: true,
                              showLabel: false,
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _StockPill(stock: widget.item.stock),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Info area ───────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/currency/Item_Mora.webp',
                              width: 13,
                              height: 13,
                              errorBuilder: (_, _, _) => Icon(
                                CupertinoIcons.money_dollar,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatPrice(widget.item.price),
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        inStock ? '×$stock' : 'Sold',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}


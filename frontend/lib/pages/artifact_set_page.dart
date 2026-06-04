import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../providers/shop_provider.dart';

class ArtifactSetPage extends StatefulWidget {
  final String setName;
  final int elementId;

  const ArtifactSetPage({
    super.key,
    required this.setName,
    required this.elementId,
  });

  @override
  State<ArtifactSetPage> createState() => _ArtifactSetPageState();
}

class _ArtifactSetPageState extends State<ArtifactSetPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final pieces = shop.getArtifactsBySet(widget.setName);
    final element = shop.getElement(widget.elementId);
    final elementColor = element != null
        ? AppColors.getElementColor(element.type)
        : AppColors.primary;

    final headerAnim = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: headerAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.15),
                  end: Offset.zero,
                ).animate(headerAnim),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 10, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        elementColor.withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.setName,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(children: [
                              Text(
                                element?.type ?? '',
                                style: TextStyle(
                                  color: elementColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${pieces.length} pieces',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      // Element color dot accent
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: elementColor.withOpacity(0.7),
                          boxShadow: [
                            BoxShadow(
                              color: elementColor.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: pieces.isEmpty
                  ? Center(
                      child: Text('No pieces found',
                          style: TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: pieces.length,
                      itemBuilder: (context, index) {
                        final piece = pieces[index];
                        return _PieceCard(
                          key: ValueKey('piece_${piece.id}'),
                          piece: piece,
                          elementColor: elementColor,
                          onTap: () => Navigator.pushNamed(
                              context, '/item-detail', arguments: piece),
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

class _PieceCard extends StatefulWidget {
  final ShopItem piece;
  final Color elementColor;
  final VoidCallback onTap;

  const _PieceCard({
    super.key,
    required this.piece,
    required this.elementColor,
    required this.onTap,
  });

  @override
  State<_PieceCard> createState() => _PieceCardState();
}

class _PieceCardState extends State<_PieceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _pressed ? AppColors.surfaceLight : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: _pressed
                  ? widget.elementColor.withOpacity(0.32)
                  : AppColors.cardBorder,
            ),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.elementColor.withOpacity(0.08),
                  border: Border.all(
                    color: widget.elementColor.withOpacity(0.16),
                  ),
                ),
                child: widget.piece.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.piece.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.diamond_rounded,
                            size: 30,
                            color: widget.elementColor.withOpacity(0.4),
                          ),
                          loadingBuilder: (_, child, p) {
                            if (p == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: widget.elementColor,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.diamond_rounded, size: 30,
                        color: widget.elementColor.withOpacity(0.4)),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.piece.type,
                      style: TextStyle(
                        color: widget.elementColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.piece.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.monetization_on_rounded,
                          size: 13, color: AppColors.secondary.withOpacity(0.8)),
                      const SizedBox(width: 3),
                      Text(
                        _formatPrice(widget.piece.price),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.piece.stock > 0 ? '×${widget.piece.stock}' : 'Sold',
                        style: TextStyle(
                          color: widget.piece.stock > 0
                              ? AppColors.success
                              : AppColors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: widget.elementColor.withOpacity(0.4),
                size: 18,
              ),
            ],
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

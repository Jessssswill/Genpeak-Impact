import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';

/// Returns the local asset path for an element type
String elementAssetPath(String type) {
  final name = type[0].toUpperCase() + type.substring(1).toLowerCase();
  return 'assets/images/elements/Element_$name.webp';
}

/// Element badge pill showing element image and name
class ElementBadge extends StatelessWidget {
  final String elementType;
  final bool compact;
  final bool showLabel;

  const ElementBadge({
    super.key,
    required this.elementType,
    this.compact = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getElementColor(elementType);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            elementAssetPath(elementType),
            width: compact ? 13 : 16,
            height: compact ? 13 : 16,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(Icons.auto_awesome, size: compact ? 12 : 14, color: color),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              elementType,
              style: TextStyle(
                color: color,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Element filter chip for the shop — uses image icon
class ElementFilterChip extends StatelessWidget {
  final ElementModel element;
  final bool isSelected;
  final VoidCallback onTap;

  const ElementFilterChip({
    super.key,
    required this.element,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getElementColor(element.type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.badge),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              elementAssetPath(element.type),
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(Icons.auto_awesome, size: 16, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              element.type,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

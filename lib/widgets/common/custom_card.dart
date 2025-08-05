import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool hasShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = backgroundColor ??
        (isDark ? AppTheme.darkCardColor : AppTheme.lightCardColor);

    final double cardElevation =
        hasShadow ? (elevation ?? AppTheme.smallElevation) : 0.0;

    final BorderRadius cardBorderRadius = borderRadius ?? AppTheme.mediumRadius;

    final Widget cardWidget = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.mediumPadding),
      margin: margin ?? const EdgeInsets.all(AppTheme.smallPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: cardBorderRadius,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: cardElevation * 3,
                  offset: Offset(0, cardElevation),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

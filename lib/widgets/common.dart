import 'package:flutter/material.dart';

import '../theme.dart';

/// Rounded surface card used across screens.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 32,
    this.color = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
}

/// Big gradient CTA ("START MY PATH", "SAVE · +10 XP").
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool glow;
  const GradientButton(
      {super.key, required this.label, this.onPressed, this.glow = true});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: glow && enabled ? AppColors.glow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  label.toUpperCase(),
                  style: heading(15, color: AppColors.bg)
                      .copyWith(letterSpacing: 0.45),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple pressable wrapper with ripple and rounded clip.
class Pressable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final Color color;
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    required this.borderRadius,
    this.color = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, onLongPress: onLongPress, child: child),
      );
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const ScreenHeader(
      {super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: heading(28)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                      style: body(14, color: AppColors.neutral700)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

/// Standard scrollable page padding (leaves room for the bottom nav).
class ScreenScroll extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final double bottom;
  const ScreenScroll(
      {super.key, required this.children, this.gap = 16, this.bottom = 130});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(SizedBox(height: gap));
      items.add(children[i]);
    }
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          22, 12, 22, bottom + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }
}

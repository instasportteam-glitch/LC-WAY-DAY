import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';

class BottomNav extends StatelessWidget {
  final VoidCallback onAdd;
  const BottomNav({super.key, required this.onAdd});

  static const _lift = 22.0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final inset = MediaQuery.of(context).padding.bottom;
    final bottomPad = inset > 0 ? inset + 6 : 18.0;
    final barH = 10 + 56 + bottomPad;

    Widget item(AppScreen target, IconData icon, String label) {
      final active = s.screen == target;
      final color = active ? AppColors.accent700 : AppColors.neutral600;
      return Expanded(
        child: InkResponse(
          onTap: () => s.go(target),
          radius: 36,
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 3),
                Text(label,
                    style: body(11, color: color, weight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: barH + _lift,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barH,
            child: Container(
              padding: EdgeInsets.fromLTRB(12, 10, 12, bottomPad),
              decoration: BoxDecoration(
                color: AppColors.deep,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: AppColors.shadowMd,
              ),
              child: Row(
                children: [
                  item(AppScreen.path, Icons.map_outlined, 'Path'),
                  item(AppScreen.tasks, Icons.checklist_rounded, 'Tasks'),
                  const SizedBox(width: 72),
                  item(AppScreen.journal, Icons.menu_book_rounded, 'Journal'),
                  item(AppScreen.stats, Icons.bar_chart_rounded, 'Stats'),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: AddButton(onTap: onAdd, size: 56)),
          ),
        ],
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  const AddButton({super.key, required this.onTap, this.size = 56});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradient,
          boxShadow: AppColors.glow,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: const Icon(Icons.add_rounded, size: 30, color: AppColors.bg),
          ),
        ),
      );
}

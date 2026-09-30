import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  static const _offsets = [0.0, 70.0, 100.0, 60.0, -10.0, -80.0, -100.0, -50.0];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final trait = s.trait;
    final greeting = s.name.isEmpty ? 'Hi there' : 'Hi, ${s.name}';

    return ScreenScroll(
      gap: 18,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: body(14, color: AppColors.neutral700)),
                  const SizedBox(height: 2),
                  Text(trait.name, style: heading(28)),
                ],
              ),
            ),
            Tooltip(
              message: 'Change trait',
              child: Pressable(
                onTap: s.restart,
                borderRadius: BorderRadius.circular(26),
                color: trait.color,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(
                    child: Text(trait.letter,
                        style: heading(22, color: AppColors.bg, height: 1)),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Level card
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${s.level}',
                            style: body(12,
                                color: AppColors.neutral700,
                                weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(s.levelName, style: heading(18, height: 1.2)),
                      ],
                    ),
                  ),
                  Text('${s.xpInLevel}/100 XP',
                      style: body(13, color: AppColors.neutral700)),
                ],
              ),
              const SizedBox(height: 10),
              ProgressBar(
                  value: s.xpInLevel / 100, color: trait.color, height: 12),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 16, color: AppColors.accent800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${s.streak}-day streak · ${s.doneToday} of ${trait.tasks.length} tasks today',
                      style: body(13, color: AppColors.accent800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Winding path
        _PathNodes(offsets: _offsets),
      ],
    );
  }
}

class _PathNodes extends StatelessWidget {
  final List<double> offsets;
  const _PathNodes({required this.offsets});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final trait = s.trait;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Decorative glows
        const Positioned(
          top: 120,
          left: -120,
          child: _Glow(size: 260, color: AppColors.accent, alpha: 0.30),
        ),
        const Positioned(
          top: 420,
          right: -90,
          child: _Glow(size: 200, color: AppColors.accent2, alpha: 0.26),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Column(
            children: [
              for (var i = 0; i < levels.length; i++)
                Transform.translate(
                  offset: Offset(offsets[i], 0),
                  child: _Node(
                    index: i,
                    level: s.level,
                    color: trait.color,
                    onTap: () {
                      final n = i + 1;
                      if (n <= s.level) {
                        s.go(AppScreen.tasks);
                      } else {
                        s.flash('Unlocks at level $n');
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  final int index;
  final int level;
  final Color color;
  final VoidCallback onTap;
  const _Node(
      {required this.index,
      required this.level,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = index + 1;
    final done = n < level;
    final cur = n == level;
    final locked = n > level;
    final size = cur ? 78.0 : 62.0;
    final bg = done
        ? color
        : cur
            ? AppColors.accent100
            : AppColors.neutral200;
    final fg = done
        ? AppColors.bg
        : cur
            ? AppColors.accent800
            : AppColors.neutral500;

    Widget inner;
    if (done) {
      inner = Icon(Icons.check_rounded, size: 30, color: fg);
    } else if (cur) {
      inner = Text('$n', style: heading(20, color: fg, height: 1));
    } else {
      inner = Icon(Icons.lock_outline_rounded, size: 22, color: fg);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: cur ? Border.all(color: AppColors.accent, width: 4) : null,
              boxShadow: cur ? AppColors.glow : null,
            ),
            child: inner,
          ),
        ),
        const SizedBox(height: 6),
        Text(levels[index],
            style: body(12,
                weight: FontWeight.w700,
                color: locked ? AppColors.neutral600 : AppColors.text)),
        const SizedBox(height: 6),
        if (index < levels.length - 1)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                _Dot(),
                SizedBox(height: 5),
                _Dot(),
              ],
            ),
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
            color: AppColors.neutral400, shape: BoxShape.circle),
      );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double alpha;
  const _Glow({required this.size, required this.color, required this.alpha});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
              stops: const [0, 0.7],
            ),
          ),
        ),
      );
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const ProgressBar(
      {super.key, required this.value, required this.color, this.height = 10});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: height,
          color: AppColors.neutral100,
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
                end: value < 0 ? 0.0 : (value > 1 ? 1.0 : value)),
            duration: const Duration(milliseconds: 400),
            builder: (_, v, __) => FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      );
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'path_screen.dart' show ProgressBar;

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final trait = s.trait;
    final week = s.weekXp;
    final todayIdx = DateTime.now().weekday - 1;
    final maxDay = math.max(70, week.reduce(math.max));

    return ScreenScroll(
      children: [
        Text('Analytics', style: heading(28)),

        // Level ring
        SurfaceCard(
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CustomPaint(
                  painter: _RingPainter(
                      value: s.xpInLevel / 100, color: trait.color),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${s.level}', style: heading(22, height: 1)),
                        Text('level',
                            style: body(10, color: AppColors.neutral700)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${s.xp} XP total', style: heading(18)),
                    const SizedBox(height: 4),
                    Text(
                      s.atSummit
                          ? 'Summit reached — keep going!'
                          : '${s.xpLeft} XP to level ${s.level + 1}',
                      style: body(13, color: AppColors.neutral700),
                    ),
                    const SizedBox(height: 4),
                    Text('${s.streak}-day streak',
                        style: body(13, color: AppColors.accent800)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Week bars
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This week', style: heading(17)),
              const SizedBox(height: 14),
              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _Bar(
                            label: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                            xp: week[i],
                            fraction: week[i] / maxDay,
                            highlight: i == todayIdx,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Facets
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trait facets', style: heading(17)),
              for (final (name, base) in trait.facets) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text(name, style: body(13))),
                    Text('${s.facetPct(base)}%',
                        style: body(13, color: AppColors.neutral700)),
                  ],
                ),
                const SizedBox(height: 6),
                ProgressBar(value: s.facetPct(base) / 100, color: trait.color),
              ],
            ],
          ),
        ),

        Center(
          child: TextButton(
            onPressed: () => _confirmReset(context),
            child: Text('Reset progress',
                style: body(13, color: AppColors.neutral600)),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final s = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Reset all progress?', style: heading(20)),
        content: Text('XP, tasks and journal entries will be deleted.',
            style: body(14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: body(14, color: AppColors.neutral700))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Reset', style: body(14, color: AppColors.accent))),
        ],
      ),
    );
    if (ok == true) await s.resetAll();
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int xp;
  final double fraction;
  final bool highlight;
  const _Bar(
      {required this.label,
      required this.xp,
      required this.fraction,
      required this.highlight});

  @override
  Widget build(BuildContext context) {
    final f = fraction.isNaN ? 0.0 : math.min(1.0, math.max(0.04, fraction));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Tooltip(
              message: '$xp XP',
              child: FractionallySizedBox(
                heightFactor: f,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 28),
                  decoration: BoxDecoration(
                    gradient: highlight
                        ? const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF34E75A), Color(0xFFA3EF45)])
                        : null,
                    color: highlight ? null : AppColors.accent300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: body(11,
                weight: FontWeight.w700,
                color: highlight ? AppColors.accent700 : AppColors.neutral700)),
      ],
    );
  }
}

/// Conic "progress ring" from the design.
class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  _RingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c, r, Paint()..color = AppColors.neutral100);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, true,
        Paint()..color = color);
    canvas.drawCircle(c, 36, Paint()..color = AppColors.surface);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}

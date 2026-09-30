import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final trait = s.trait;
    return ScreenScroll(
      children: [
        ScreenHeader(
          title: 'Today’s tasks',
          subtitle: 'Small steps toward ${trait.name}',
        ),
        for (var i = 0; i < trait.tasks.length; i++)
          _TaskTile(index: i),
        SurfaceCard(
          radius: 28,
          color: AppColors.accent2_100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EVENT OF THE WEEK',
                  style: body(11,
                      color: AppColors.accent2_800,
                      weight: FontWeight.w700,
                      letterSpacing: 1.1)),
              const SizedBox(height: 6),
              Text(trait.event,
                  style: heading(17, color: AppColors.accent2_900, height: 1.25)),
              const SizedBox(height: 6),
              Text('+60 XP · until Sunday',
                  style: body(13, color: AppColors.accent2_800)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final int index;
  const _TaskTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.trait.tasks[index];
    final d = s.isTaskDone(index);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: d ? 0.75 : 1,
      child: Pressable(
        onTap: () => s.toggleTask(index),
        borderRadius: BorderRadius.circular(28),
        color: d ? AppColors.accent2_100 : AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: d ? AppColors.accent2_600 : Colors.transparent,
                  border: Border.all(
                    width: 2.5,
                    color: d ? AppColors.accent2_600 : AppColors.neutral500,
                  ),
                ),
                child: d
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: AppColors.bg)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: heading(16, height: 1.25).copyWith(
                          decoration: d ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.text,
                        )),
                    const SizedBox(height: 4),
                    Text(t.hint,
                        style: body(13, color: AppColors.neutral700)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('+${t.xp} XP',
                    style: body(11,
                        color: AppColors.accent800, weight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

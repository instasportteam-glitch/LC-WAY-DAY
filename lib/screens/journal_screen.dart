import 'dart:io';

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import '../widgets/entry_sheet.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String formatEntryDate(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) {
    final mins = now.difference(d).inMinutes;
    return mins < 2 ? 'Just now' : 'Today';
  }
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return _weekdays[d.weekday - 1];
  return '${d.day} ${_months[d.month - 1]}';
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ScreenScroll(
      children: [
        ScreenHeader(
          title: 'Journal',
          subtitle: 'Notes, events and photos',
          trailing: AddButton(onTap: () => showEntrySheet(context), size: 46),
        ),
        if (s.entries.isEmpty)
          SurfaceCard(
            radius: 28,
            child: Column(
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 36, color: AppColors.neutral600),
                const SizedBox(height: 10),
                Text('No entries yet', style: heading(17)),
                const SizedBox(height: 4),
                Text('Tap + to write what went well today.',
                    textAlign: TextAlign.center,
                    style: body(13, color: AppColors.neutral700)),
              ],
            ),
          ),
        for (final e in s.entries) _EntryCard(entry: e),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;
  const _EntryCard({required this.entry});

  (Color, Color) get _tagColors => switch (entry.type) {
        'event' => (AppColors.accent2_100, AppColors.accent2_800),
        'photo' => (AppColors.neutral100, AppColors.neutral800),
        _ => (AppColors.accent100, AppColors.accent800),
      };

  Future<void> _confirmDelete(BuildContext context) async {
    final s = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete entry?', style: heading(20)),
        content: Text('This can’t be undone.', style: body(14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: body(14, color: AppColors.neutral700))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: body(14, color: AppColors.accent))),
        ],
      ),
    );
    if (ok == true) s.deleteEntry(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final (tagBg, tagFg) = _tagColors;
    return Pressable(
      onLongPress: () => _confirmDelete(context),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(entryTypeLabel(entry.type),
                      style: body(11, color: tagFg, weight: FontWeight.w700)),
                ),
                const Spacer(),
                Text(formatEntryDate(entry.createdAt),
                    style: body(12, color: AppColors.neutral700)),
              ],
            ),
            if (entry.type == 'photo') ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: entry.photoPath == null
                      ? const StripedPlaceholder(label: 'user photo')
                      : Image.file(
                          File(entry.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const StripedPlaceholder(label: 'photo not found'),
                        ),
                ),
              ),
            ],
            if (entry.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(entry.text, style: body(15, height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import 'common.dart';

Future<void> showEntrySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.neutral900.withValues(alpha: 0.45),
    builder: (_) => const EntrySheet(),
  );
}

class EntrySheet extends StatefulWidget {
  const EntrySheet({super.key});

  @override
  State<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<EntrySheet> {
  final _ctrl = TextEditingController();
  String _type = 'note';
  String? _photoPath;
  bool _picking = false;

  bool get _canSave =>
      _ctrl.text.trim().isNotEmpty || (_type == 'photo' && _photoPath != null);

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
      if (file == null) return;
      // Copy into app documents so the photo survives temp-dir cleanup.
      final dir = await getApplicationDocumentsDirectory();
      final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
      final dest =
          '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(file.path).copy(dest);
      if (mounted) setState(() => _photoPath = dest);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Could not open photos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _save() {
    if (!_canSave) return;
    AppScope.of(context).addEntry(
      type: _type,
      text: _ctrl.text,
      photoPath: _type == 'photo' ? _photoPath : null,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final safe = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        padding: EdgeInsets.fromLTRB(22, 22, 22, 22 + (keyboard > 0 ? 0 : safe)),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          boxShadow: AppColors.shadowLg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('New entry', style: heading(22))),
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(22),
                    color: AppColors.surface,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.close_rounded,
                          size: 20, color: AppColors.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final (k, label) in entryTypes) ...[
                    if (k != entryTypes.first.$1) const SizedBox(width: 8),
                    Expanded(
                      child: Pressable(
                        onTap: () => setState(() => _type = k),
                        borderRadius: BorderRadius.circular(999),
                        color: _type == k ? AppColors.accent2 : AppColors.surface,
                        child: SizedBox(
                          height: 44,
                          child: Center(
                            child: Text(label,
                                style: heading(14,
                                    color: _type == k
                                        ? AppColors.bg
                                        : AppColors.text)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _ctrl,
                autofocus: false,
                minLines: 4,
                maxLines: 6,
                style: body(15),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: 'What went well today?',
                  hintStyle: body(15, color: AppColors.neutral600),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              if (_type == 'photo') ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      height: _photoPath == null ? 90 : 160,
                      child: _photoPath == null
                          ? StripedPlaceholder(
                              label: _picking
                                  ? 'opening photos…'
                                  : 'tap to choose a photo')
                          : Image.file(File(_photoPath!), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              GradientButton(
                label: 'Save · +10 XP',
                glow: false,
                onPressed: _canSave ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diagonal-striped placeholder from the design ("user photo").
class StripedPlaceholder extends StatelessWidget {
  final String label;
  const StripedPlaceholder({super.key, required this.label});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _StripesPainter(),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.neutral800)),
        ),
      );
}

class _StripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.neutral200);
    final p = Paint()
      ..color = AppColors.neutral300
      ..strokeWidth = 7;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (double x = -size.height; x < size.width + size.height; x += 14) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

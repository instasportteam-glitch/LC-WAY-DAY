import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_name.text.isEmpty) _name.text = AppScope.of(context).name;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ScreenScroll(
      gap: 18,
      bottom: 28,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PERSONALITY PATH',
                style: body(11,
                    color: AppColors.accent700,
                    weight: FontWeight.w700,
                    letterSpacing: 1.1)),
            const SizedBox(height: 6),
            Text('Who do you want to become?',
                style: heading(34, height: 1.1)),
            const SizedBox(height: 6),
            Text(
              'Pick one trait from the Big Five model. We’ll build a path of small steps toward it.',
              style: body(15, color: AppColors.neutral700, height: 1.45),
            ),
          ],
        ),
        TextField(
          controller: _name,
          style: body(15),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Your name (optional)',
            hintStyle: body(15, color: AppColors.neutral600),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        Column(
          children: [
            for (final t in traits.values) ...[
              _TraitCard(
                trait: t,
                selected: s.picked == t.key,
                onTap: () => s.pick(t.key),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
        GradientButton(
          label: 'Start my path',
          onPressed: () {
            FocusScope.of(context).unfocus();
            s.setName(_name.text);
            s.startPath();
          },
        ),
      ],
    );
  }
}

class _TraitCard extends StatelessWidget {
  final Trait trait;
  final bool selected;
  final VoidCallback onTap;
  const _TraitCard(
      {required this.trait, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.neutral100 : AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
            color: selected ? trait.color : Colors.transparent, width: 2),
      ),
      child: Pressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: trait.color, shape: BoxShape.circle),
                child: Text(trait.letter,
                    style: heading(20, color: AppColors.bg, height: 1)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trait.name, style: heading(17, height: 1.2)),
                    const SizedBox(height: 2),
                    Text(trait.desc,
                        style: body(13, color: AppColors.neutral700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

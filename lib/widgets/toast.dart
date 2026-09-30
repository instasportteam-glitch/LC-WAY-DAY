import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';

class ToastOverlay extends StatelessWidget {
  const ToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final top = MediaQuery.of(context).padding.top + 10;
    final msg = s.toast;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, -0.4), end: Offset.zero)
                    .animate(a),
                child: child,
              ),
            ),
            child: msg == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(msg),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accent2_700,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.shadowMd,
                    ),
                    child: Text(msg,
                        style: body(14,
                            color: AppColors.accent2_100,
                            weight: FontWeight.w700)),
                  ),
          ),
        ),
      ),
    );
  }
}

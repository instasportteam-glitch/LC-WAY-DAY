import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/journal_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/path_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/tasks_screen.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/entry_sheet.dart';
import 'widgets/toast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  final state = AppState();
  await state.load();
  runApp(PersonalityPathApp(state: state));
}

class PersonalityPathApp extends StatelessWidget {
  final AppState state;
  const PersonalityPathApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Personality Path',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const RootShell(),
      ),
    );
  }
}

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final onboarding = s.screen == AppScreen.onboarding;

    final Widget page = switch (s.screen) {
      AppScreen.onboarding => const OnboardingScreen(),
      AppScreen.path => const PathScreen(),
      AppScreen.tasks => const TasksScreen(),
      AppScreen.journal => const JournalScreen(),
      AppScreen.stats => const StatsScreen(),
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: onboarding,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              // Fill the whole screen so pages don't shrink to their content.
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                alignment: Alignment.topCenter,
                children: [...previous, if (current != null) current],
              ),
              child: KeyedSubtree(key: ValueKey(s.screen), child: page),
            ),
          ),
          if (!onboarding)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNav(onAdd: () => showEntrySheet(context)),
            ),
          const ToastOverlay(),
        ],
      ),
    );
  }
}

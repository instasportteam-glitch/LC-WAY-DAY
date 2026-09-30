import 'dart:async';
import 'dart:convert';

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

enum AppScreen { onboarding, path, tasks, journal, stats }

class JournalEntry {
  final String id;
  final String type; // note | event | photo
  final String text;
  final DateTime createdAt;
  final String? photoPath;

  JournalEntry({
    required this.id,
    required this.type,
    required this.text,
    required this.createdAt,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'photoPath': photoPath,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] as String,
        type: j['type'] as String,
        text: j['text'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        photoPath: j['photoPath'] as String?,
      );
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// All app state + persistence (SharedPreferences, JSON).
class AppState extends ChangeNotifier {
  static const _storageKey = 'personality_path_state_v1';

  SharedPreferences? _prefs;

  AppScreen screen = AppScreen.onboarding;
  String name = '';
  String? traitKey; // chosen trait
  String picked = 'O'; // selection on onboarding
  int xp = 0;

  /// dayKey -> set of completed task ids ("O0", "C2", ...)
  final Map<String, Set<String>> doneByDay = {};

  /// dayKey -> XP earned that day
  final Map<String, int> xpByDay = {};

  final List<JournalEntry> entries = [];

  String? toast;
  Timer? _toastTimer;

  // ---------- derived ----------
  Trait get trait => traits[traitKey ?? picked]!;
  int get level => math.min(levels.length, xp ~/ 100 + 1);
  bool get isMaxLevel => xp >= levels.length * 100;
  int get xpInLevel => isMaxLevel ? 100 : xp % 100;
  String get levelName => levels[level - 1];
  int get xpLeft => 100 - xpInLevel;
  bool get atSummit => level == levels.length;

  String get todayKey => dayKey(DateTime.now());
  Set<String> get _todayDone => doneByDay[todayKey] ?? <String>{};

  bool isTaskDone(int i) => _todayDone.contains('${trait.key}$i');
  int get doneToday =>
      List.generate(trait.tasks.length, (i) => i).where(isTaskDone).length;

  /// Consecutive days with any XP, ending today (or yesterday if today empty).
  int get streak {
    var d = DateTime.now();
    if ((xpByDay[dayKey(d)] ?? 0) <= 0) {
      d = d.subtract(const Duration(days: 1));
    }
    var count = 0;
    while ((xpByDay[dayKey(d)] ?? 0) > 0) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// XP for each day of the current week (Mon..Sun).
  List<int> get weekXp {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return List.generate(
        7, (i) => xpByDay[dayKey(monday.add(Duration(days: i)))] ?? 0);
  }

  int facetPct(int base) => math.min(100, base + xp ~/ 40);

  // ---------- actions ----------
  void go(AppScreen s) {
    screen = s;
    notifyListeners();
  }

  void pick(String key) {
    picked = key;
    notifyListeners();
  }

  void setName(String v) {
    name = v.trim();
    _save();
  }

  void startPath() {
    traitKey = picked;
    screen = AppScreen.path;
    _save();
    notifyListeners();
  }

  void restart() {
    picked = traitKey ?? picked;
    screen = AppScreen.onboarding;
    notifyListeners();
  }

  void _addXp(int amount) {
    xp = math.max(0, xp + amount);
    final k = todayKey;
    xpByDay[k] = math.max(0, (xpByDay[k] ?? 0) + amount);
  }

  void toggleTask(int i) {
    final id = '${trait.key}$i';
    final set = doneByDay.putIfAbsent(todayKey, () => <String>{});
    final t = trait.tasks[i];
    if (set.contains(id)) {
      set.remove(id);
      _addXp(-t.xp);
    } else {
      set.add(id);
      _addXp(t.xp);
      flash('+${t.xp} XP · nice work!');
    }
    _save();
    notifyListeners();
  }

  void addEntry({required String type, required String text, String? photoPath}) {
    entries.insert(
      0,
      JournalEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        text: text.trim(),
        createdAt: DateTime.now(),
        photoPath: photoPath,
      ),
    );
    _addXp(10);
    screen = AppScreen.journal;
    flash('+10 XP · entry saved');
    _save();
    notifyListeners();
  }

  void deleteEntry(String id) {
    entries.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  void flash(String msg) {
    _toastTimer?.cancel();
    toast = msg;
    notifyListeners();
    _toastTimer = Timer(const Duration(milliseconds: 1600), () {
      toast = null;
      notifyListeners();
    });
  }

  Future<void> resetAll() async {
    name = '';
    traitKey = null;
    picked = 'O';
    xp = 0;
    doneByDay.clear();
    xpByDay.clear();
    entries.clear();
    screen = AppScreen.onboarding;
    await _prefs?.remove(_storageKey);
    notifyListeners();
  }

  // ---------- persistence ----------
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        name = j['name'] as String? ?? '';
        traitKey = j['traitKey'] as String?;
        if (traitKey != null && !traits.containsKey(traitKey)) traitKey = null;
        picked = traitKey ?? 'O';
        xp = j['xp'] as int? ?? 0;
        (j['doneByDay'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
          doneByDay[k] = (v as List).map((e) => e as String).toSet();
        });
        (j['xpByDay'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
          xpByDay[k] = v as int;
        });
        entries.addAll((j['entries'] as List? ?? [])
            .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)));
      } catch (e) {
        debugPrint('Failed to load state: $e');
      }
    }
    screen = traitKey == null ? AppScreen.onboarding : AppScreen.path;
    notifyListeners();
  }

  void _save() {
    final p = _prefs;
    if (p == null) return;
    p.setString(
      _storageKey,
      jsonEncode({
        'name': name,
        'traitKey': traitKey,
        'xp': xp,
        'doneByDay': doneByDay.map((k, v) => MapEntry(k, v.toList())),
        'xpByDay': xpByDay,
        'entries': entries.map((e) => e.toJson()).toList(),
      }),
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}

/// Makes AppState available to the widget tree without extra packages.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

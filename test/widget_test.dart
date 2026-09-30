import 'package:flutter_test/flutter_test.dart';
import 'package:lcumyway/data.dart';
import 'package:lcumyway/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('all five Big Five traits have 4 tasks and 3 facets', () {
    expect(traits.length, 5);
    for (final t in traits.values) {
      expect(t.tasks.length, 4);
      expect(t.facets.length, 3);
    }
  });

  test('completing a task adds XP and levels up at 100', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load();
    s.pick('O');
    s.startPath();
    expect(s.level, 1);
    for (var i = 0; i < 4; i++) {
      s.toggleTask(i); // 20 + 25 + 15 + 10 = 70
    }
    expect(s.xp, 70);
    expect(s.doneToday, 4);
    s.addEntry(type: 'note', text: 'hello');
    s.addEntry(type: 'note', text: 'world');
    s.addEntry(type: 'note', text: '!');
    expect(s.xp, 100);
    expect(s.level, 2);
    expect(s.streak, 1);
    s.toggleTask(0); // undo
    expect(s.xp, 80);
    s.dispose();
  });
}

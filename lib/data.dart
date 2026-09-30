import 'package:flutter/material.dart';

import 'theme.dart';

class TaskDef {
  final String title;
  final String hint;
  final int xp;
  const TaskDef(this.title, this.hint, this.xp);
}

class Trait {
  final String key;
  final String letter;
  final String name;
  final String desc;
  final Color color;
  final String event;
  final List<(String, int)> facets;
  final List<TaskDef> tasks;
  const Trait({
    required this.key,
    required this.letter,
    required this.name,
    required this.desc,
    required this.color,
    required this.event,
    required this.facets,
    required this.tasks,
  });
}

const traits = <String, Trait>{
  'O': Trait(
    key: 'O',
    letter: 'O',
    name: 'Openness',
    desc: 'Curiosity, creativity, new experiences',
    color: AppColors.accent,
    event: 'Go to an exhibition or a concert in an unfamiliar genre',
    facets: [('Imagination', 62), ('Curiosity', 48), ('Aesthetics', 35)],
    tasks: [
      TaskDef('Take a new route home', 'Notice three details you haven’t seen before', 20),
      TaskDef('15 minutes of drawing or writing', 'No goal, just the process', 25),
      TaskDef('Read an article on an unfamiliar topic', 'Write one thought in your journal', 15),
      TaskDef('Listen to an album in a new genre', 'What clicked and what didn’t?', 10),
    ],
  ),
  'C': Trait(
    key: 'C',
    letter: 'C',
    name: 'Conscientiousness',
    desc: 'Order, goals, self-discipline',
    color: AppColors.accent2,
    event: 'Finish one thing you’ve been putting off',
    facets: [('Organization', 55), ('Drive', 41), ('Self-control', 30)],
    tasks: [
      TaskDef('Plan tomorrow', 'Three main things, no more', 15),
      TaskDef('Sort out one drawer or folder', '10 minutes of order', 20),
      TaskDef('Do the hardest task first', 'Before lunch, no distractions', 25),
      TaskDef('Note what you got done', 'A short evening recap', 10),
    ],
  ),
  'E': Trait(
    key: 'E',
    letter: 'E',
    name: 'Extraversion',
    desc: 'Energy, connection, boldness',
    color: AppColors.accent500,
    event: 'Invite friends to a meetup you organize yourself',
    facets: [('Sociability', 58), ('Energy', 44), ('Confidence', 33)],
    tasks: [
      TaskDef('Start a chat with a stranger', 'A compliment or a question is enough', 25),
      TaskDef('Call a friend instead of texting', 'Even just 5 minutes', 15),
      TaskDef('Speak up first in a meeting', 'One idea, out loud', 20),
      TaskDef('Walk somewhere busy', 'Notice the energy around you', 10),
    ],
  ),
  'A': Trait(
    key: 'A',
    letter: 'A',
    name: 'Agreeableness',
    desc: 'Empathy, care, trust',
    color: AppColors.accent2_500,
    event: 'Do a good deed anonymously',
    facets: [('Empathy', 60), ('Trust', 42), ('Generosity', 38)],
    tasks: [
      TaskDef('Say a sincere thank-you', 'Be specific about what for', 15),
      TaskDef('Listen without interrupting', 'In your next conversation', 20),
      TaskDef('Help a coworker or neighbor', 'Even with something small', 25),
      TaskDef('Send a warm message', 'To someone you haven’t talked to in a while', 10),
    ],
  ),
  'N': Trait(
    key: 'N',
    letter: 'S',
    name: 'Emotional Stability',
    desc: 'Calm, resilience, balance',
    color: AppColors.neutral600,
    event: 'Spend an evening without screens',
    facets: [('Calm', 50), ('Resilience', 40), ('Mindfulness', 36)],
    tasks: [
      TaskDef('5 minutes of 4-7-8 breathing', 'In the morning or before bed', 15),
      TaskDef('Write down what worries you', 'Plus one small step toward it', 20),
      TaskDef('A walk without your phone', '20 minutes of quiet', 25),
      TaskDef('Three good things today', 'Before bed, in your journal', 10),
    ],
  ),
};

const levels = [
  'First step',
  'Habit',
  'Rhythm',
  'Depth',
  'Courage',
  'Mastery',
  'Mentor',
  'Summit',
];

const entryTypes = [('note', 'Note'), ('event', 'Event'), ('photo', 'Photo')];

String entryTypeLabel(String type) =>
    entryTypes.firstWhere((t) => t.$1 == type, orElse: () => entryTypes.first).$2;

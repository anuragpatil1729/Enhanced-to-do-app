import 'subtask.dart';
import '../utils/enums.dart';

class Todo {
  String id;
  String title;
  String? description;
  DateTime? dueDate;
  Priority priority;
  bool done;
  List<Subtask> subtasks;
  DateTime createdAt;
  String category; // new: Work / Personal / Other
  Reminder reminder; // new: At time, 5 min before, etc.

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = Priority.medium,
    this.done = false,
    this.subtasks = const [],
    DateTime? createdAt,
    this.category = 'General',
    this.reminder = Reminder.atTime,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority.index,
    'done': done,
    'subtasks': subtasks.map((s) => s.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'category': category,
    'reminder': reminder.index,
  };

  factory Todo.fromMap(Map<String, dynamic> m) => Todo(
    id: m['id'],
    title: m['title'],
    description: m['description'],
    dueDate:
    m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
    priority: Priority.values[m['priority'] ?? 1],
    done: m['done'] ?? false,
    subtasks: (m['subtasks'] as List?)
        ?.map((x) => Subtask.fromMap(Map<String, dynamic>.from(x)))
        .toList() ??
        [],
    createdAt: m['createdAt'] != null
        ? DateTime.parse(m['createdAt'])
        : DateTime.now(),
    category: m['category'] ?? 'General',
    reminder: Reminder.values[m['reminder'] ?? 0],
  );
}

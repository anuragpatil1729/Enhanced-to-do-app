import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';

class TodoProvider extends ChangeNotifier {
  static const _key = 'enhanced_todos_v1';
  static const _backupKey = 'enhanced_todos_backup_v1';
  final SharedPreferences prefs;
  List<Todo> _todos = [];
  bool isDark = false;

  // UI state
  String search = '';
  FilterMode filter = FilterMode.all;
  SortMode sortMode = SortMode.byDueDate;
  String activeCategory = 'All';

  TodoProvider(this.prefs) {
    _load();
    isDark = prefs.getBool('pref_dark') ?? false;
  }

  // getters
  List<Todo> get todos => List.unmodifiable(_todos);

  List<String> get categories {
    final set = <String>{'All'};
    for (var t in _todos) set.add(t.category);
    return set.toList();
  }

  List<Todo> get overdueTodos => visibleTodos.where((t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && !t.done).toList();
  List<Todo> get todayTodos => visibleTodos.where((t) => t.dueDate != null && isToday(t.dueDate) && !t.done).toList();
  List<Todo> get upcomingTodos => visibleTodos.where((t) => t.dueDate != null && t.dueDate!.isAfter(DateTime.now()) && !isToday(t.dueDate) && !t.done).toList();

  // visibletodos uses search, filter, category, sort
  List<Todo> get visibleTodos {
    var list = _todos.toList();

    // category filter
    if (activeCategory != 'All') {
      list = list.where((t) => t.category == activeCategory).toList();
    }

    // search
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              (t.description?.toLowerCase().contains(q) ?? false) ||
              t.subtasks.any((s) => s.title.toLowerCase().contains(q)))
          .toList();
    }

    // filter
    switch (filter) {
      case FilterMode.all:
        break;
      case FilterMode.active:
        list = list.where((t) => !t.done).toList();
        break;
      case FilterMode.completed:
        list = list.where((t) => t.done).toList();
        break;
      case FilterMode.overdue:
        list = list
            .where((t) =>
                t.dueDate != null &&
                t.dueDate!.isBefore(DateTime.now()) &&
                !t.done)
            .toList();
        break;
    }

    // sort
    switch (sortMode) {
      case SortMode.byDueDate:
        list.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null)
            return b.createdAt.compareTo(a.createdAt);
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortMode.byPriority:
        list.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortMode.byCreated:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return list;
  }

  // persistence
  void _load() {
    final raw = prefs.getString(_key);
    if (raw != null) {
      final arr = jsonDecode(raw) as List<dynamic>;
      _todos =
          arr.map((e) => Todo.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final raw = jsonEncode(_todos.map((t) => t.toMap()).toList());
    await prefs.setString(_key, raw);
  }

  // backup snapshot
  void backupNow() {
    final ts = DateTime.now().toIso8601String();
    final snapshot = jsonEncode(
        {'timestamp': ts, 'data': _todos.map((t) => t.toMap()).toList()});
    List<String> list = prefs.getStringList(_backupKey) ?? [];
    list.add(snapshot);
    prefs.setStringList(_backupKey, list);
    notifyListeners();
  }

  List<Map<String, dynamic>> getBackups() {
    final list = prefs.getStringList(_backupKey) ?? [];
    return list
        .map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map))
        .toList();
  }

  void restoreBackupAt(int index) {
    final list = prefs.getStringList(_backupKey) ?? [];
    if (index < 0 || index >= list.length) return;
    final decoded = jsonDecode(list[index]) as Map<String, dynamic>;
    final arr = decoded['data'] as List<dynamic>;
    _todos =
        arr.map((e) => Todo.fromMap(Map<String, dynamic>.from(e))).toList();
    _save();
    notifyListeners();
  }

  // CRUD
  void addTodo(Todo t) {
    _todos.add(t);
    notifyListeners();
    _save();
    NotificationService.scheduleNotification(t);
  }

  void insertTodo(int index, Todo todo) {
    if (index < 0 || index > _todos.length) {
      _todos.add(todo);
    } else {
      _todos.insert(index, todo);
    }
    notifyListeners();
    _save();
    if (!todo.done) {
      NotificationService.scheduleNotification(todo);
    }
  }

  void updateTodo(Todo t) {
    final idx = _todos.indexWhere((x) => x.id == t.id);
    if (idx >= 0) {
      _todos[idx] = t;
      notifyListeners();
      _save();
      NotificationService.scheduleNotification(t);
    }
  }

  void removeTodo(String id) {
    final todo = _todos.firstWhere((t) => t.id == id, orElse: () => null as Todo);
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
    _save();
    NotificationService.cancelNotification(id);
  }

  void toggleDone(String id) {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _todos[idx].done = !_todos[idx].done;
      notifyListeners();
      _save();
      if (_todos[idx].done) {
        NotificationService.cancelNotification(id);
      }
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    notifyListeners();
    _save();
  }

  // UI state mutators
  void setSearch(String s) {
    search = s;
    notifyListeners();
  }

  void setFilter(FilterMode f) {
    filter = f;
    notifyListeners();
  }

  void setSort(SortMode s) {
    sortMode = s;
    notifyListeners();
  }

  void setCategory(String c) {
    activeCategory = c;
    notifyListeners();
  }

  // stats helpers
  int get totalTasks => _todos.length;
  int get completedTasks => _todos.where((t) => t.done).length;
  int get activeTasks => totalTasks - completedTasks;
  int get overdueTasks => _todos
      .where((t) =>
          t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && !t.done)
      .length;
  double get completionRate =>
      totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;

  Map<String, int> get tasksByWeekday {
    final map = <String, int>{
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };
    for (var todo in _todos) {
      if (todo.dueDate != null) {
        final weekday = todo.dueDate!.weekday;
        switch (weekday) {
          case DateTime.monday:
            map['Mon'] = map['Mon']! + 1;
            break;
          case DateTime.tuesday:
            map['Tue'] = map['Tue']! + 1;
            break;
          case DateTime.wednesday:
            map['Wed'] = map['Wed']! + 1;
            break;
          case DateTime.thursday:
            map['Thu'] = map['Thu']! + 1;
            break;
          case DateTime.friday:
            map['Fri'] = map['Fri']! + 1;
            break;
          case DateTime.saturday:
            map['Sat'] = map['Sat']! + 1;
            break;
          case DateTime.sunday:
            map['Sun'] = map['Sun']! + 1;
            break;
        }
      }
    }
    return map;
  }

  // theme
  Future<void> toggleTheme() async {
    isDark = !isDark;
    await prefs.setBool('pref_dark', isDark);
    notifyListeners();
  }
}

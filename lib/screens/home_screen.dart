import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/filter_dailog.dart';
import '../widgets/sort_dailog.dart';
import '../widgets/todo_tile.dart';
import 'edit_todo_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'pomodoro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced To-Do'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'filter':
                  showDialog(context: context, builder: (_) => const FilterDialog());
                  break;
                case 'sort':
                  showDialog(context: context, builder: (_) => const SortDialog());
                  break;
                case 'calendar':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                  break;
                case 'stats':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
                  break;
                case 'profile':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  break;
                case 'focus':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PomodoroScreen()));
                  break;
                case 'theme':
                  Provider.of<TodoProvider>(context, listen: false).toggleTheme();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              final provider = Provider.of<TodoProvider>(context, listen: false);
              return <PopupMenuEntry<String>>[
                const PopupMenuItem(
                  value: 'filter',
                  child: ListTile(leading: Icon(Icons.filter_list), title: Text('Filter')),
                ),
                const PopupMenuItem(
                  value: 'sort',
                  child: ListTile(leading: Icon(Icons.sort), title: Text('Sort')),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'calendar',
                  child: ListTile(leading: Icon(Icons.calendar_month), title: Text('Calendar')),
                ),
                const PopupMenuItem(
                  value: 'stats',
                  child: ListTile(leading: Icon(Icons.bar_chart), title: Text('Stats')),
                ),
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(leading: Icon(Icons.person), title: Text('Profile')),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'focus',
                  child: ListTile(leading: Icon(Icons.timer), title: Text('Focus Mode')),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'theme',
                  child: ListTile(
                    leading: Icon(provider.isDark ? Icons.light_mode : Icons.dark_mode),
                    title: Text(provider.isDark ? 'Light Theme' : 'Dark Theme'),
                  ),
                ),
              ];
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Consumer<TodoProvider>(
                  builder: (_, prov, __) => TextField(
                    onChanged: prov.setSearch,
                    decoration: InputDecoration(
                      hintText: 'Search tasks, descriptions, subtasks...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: prov.search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => prov.setSearch(''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ),
              Consumer<TodoProvider>(
                builder: (_, prov, __) {
                  final cats = prov.categories;
                  return SizedBox(
                    height: 34,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final c = cats[i];
                        final selected = c == prov.activeCategory;
                        return ChoiceChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (_) => prov.setCategory(c),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<TodoProvider>(
          builder: (ctx, prov, _) {
            if (prov.overdueTodos.isEmpty && prov.todayTodos.isEmpty && prov.upcomingTodos.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No tasks yet. Add one to get started!', style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildTaskList('Overdue', prov.overdueTodos, prov, Colors.red),
                _buildTaskList('Today', prov.todayTodos, prov, Colors.blue),
                _buildTaskList('Upcoming', prov.upcomingTodos, prov, Colors.grey),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditTodoScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(String title, List<Todo> todos, TodoProvider prov, Color color) {
    if (todos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (ctx, i) {
            final todo = todos[i];
            return TodoTile(todo: todo, key: ValueKey(todo.id));
          },
        ),
        const Divider(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../screens/edit_todo_screen.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final completedSubtasks = todo.subtasks.where((s) => s.done).length;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 80, // Adjust height to match your design
            color: _getPriorityColor(todo.priority),
          ),
          Expanded(
            child: ListTile(
              leading: Checkbox(
                value: todo.done,
                onChanged: (_) => provider.toggleDone(todo.id),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.done ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((todo.description ?? '').isNotEmpty) Text(todo.description!),
                  if (todo.subtasks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: completedSubtasks / todo.subtasks.length,
                          ),
                          const SizedBox(height: 4),
                          Text('$completedSubtasks of ${todo.subtasks.length} subtasks'),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      if (todo.dueDate != null)
                        Text(fmtDate(todo.dueDate), style: const TextStyle(fontSize: 12)),
                    ],
                  )
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTodoScreen(todo: todo),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

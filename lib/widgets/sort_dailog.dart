import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../utils/enums.dart';

class SortDialog extends StatelessWidget {
  const SortDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    return AlertDialog(
      title: const Text('Sort Tasks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: SortMode.values.map((s) {
          return RadioListTile<SortMode>(
            title: Text(s.name),
            value: s,
            groupValue: provider.sortMode,
            onChanged: (v) {
              if (v != null) provider.setSort(v);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

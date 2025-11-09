import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/todo.dart';

class ExportService {
  Future<void> exportTasks(List<Todo> tasks, String format) async {
    if (format == 'json') {
      await _exportToJson(tasks);
    } else if (format == 'csv') {
      await _exportToCsv(tasks);
    }
  }

  Future<void> _exportToJson(List<Todo> tasks) async {
    final List<Map<String, dynamic>> taskMaps = tasks.map((task) => task.toMap()).toList();
    final String jsonString = jsonEncode(taskMaps);
    await _saveAndOpenFile(jsonString, 'tasks.json');
  }

  Future<void> _exportToCsv(List<Todo> tasks) async {
    final List<List<dynamic>> rows = [];
    rows.add([
      'ID', 'Title', 'Description', 'Due Date', 'Priority', 'Done', 'Category', 'Created At', 'Subtasks'
    ]);
    for (var task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description ?? '',
        task.dueDate?.toIso8601String() ?? '',
        task.priority.toString(),
        task.done,
        task.category,
        task.createdAt.toIso8601String(),
        task.subtasks.map((s) => s.title).join(', ')
      ]);
    }

    final String csvString = const ListToCsvConverter().convert(rows);
    await _saveAndOpenFile(csvString, 'tasks.csv');
  }

  Future<void> _saveAndOpenFile(String data, String fileName) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String path = '${directory!.path}/$fileName';
    final File file = File(path);
    await file.writeAsString(data);
    await OpenFilex.open(path);
  }
}

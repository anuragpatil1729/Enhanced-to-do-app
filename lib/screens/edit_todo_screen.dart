import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../models/subtask.dart';
import '../providers/todo_provider.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';

class EditTodoScreen extends StatefulWidget {
  final Todo? todo;
  const EditTodoScreen({super.key, this.todo});

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  String? description;
  DateTime? dueDate;
  Priority priority = Priority.medium;
  List<Subtask> subtasks = [];
  String category = 'General';
  Reminder reminder = Reminder.atTime;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      final t = widget.todo!;
      title = t.title;
      description = t.description;
      dueDate = t.dueDate;
      priority = t.priority;
      subtasks = List.from(t.subtasks);
      category = t.category;
      reminder = t.reminder;
    } else {
      title = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TodoProvider>(context, listen: false);
    final categories = prov.categories..removeWhere((c)=>c=='All');

    return Scaffold(
      appBar: AppBar(title: Text(widget.todo == null ? 'New Task' : 'Edit Task'), actions: [
        if (widget.todo != null)
          IconButton(icon: const Icon(Icons.delete), onPressed: () { prov.removeTodo(widget.todo!.id); Navigator.pop(context); })
      ]),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(key: _formKey, child: ListView(children: [
          TextFormField(initialValue: title, decoration: const InputDecoration(labelText: 'Title'), validator: (v)=> (v==null||v.isEmpty)?'Enter title':null, onSaved: (v)=>title=v!.trim()),
          TextFormField(initialValue: description, decoration: const InputDecoration(labelText: 'Description'), onSaved: (v)=>description=v?.trim(), maxLines:3),
          const SizedBox(height:10),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Due Date'), subtitle: Text(dueDate==null?'Not set':fmtDate(dueDate)), trailing: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async {
            final now = DateTime.now();
            final pick = await showDatePicker(context: context, initialDate: dueDate ?? now, firstDate: DateTime(now.year-1), lastDate: DateTime(now.year+5));
            if (pick != null) {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              setState(()=>dueDate = DateTime(pick.year, pick.month, pick.day, time?.hour ?? 0, time?.minute ?? 0));
            }
          })),
          DropdownButtonFormField<Reminder>(
            value: reminder,
            decoration: const InputDecoration(labelText: 'Reminder'),
            items: Reminder.values.map((r) => DropdownMenuItem(value: r, child: Text(describeReminder(r)))).toList(),
            onChanged: (v) => setState(() => reminder = v ?? Reminder.atTime),
          ),
          DropdownButtonFormField<Priority>(value: priority, decoration: const InputDecoration(labelText: 'Priority'), items: Priority.values.map((p)=>DropdownMenuItem(value:p, child: Text(describePriority(p)))).toList(), onChanged: (v)=> setState(()=>priority=v ?? Priority.medium)),
          const SizedBox(height:10),
          DropdownButtonFormField<String>(
            value: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: (['General','Work','Personal','Other']..addAll(categories)).toSet().map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(()=>category=v ?? 'General'),
          ),
          const SizedBox(height:12),
          const Text('Subtasks', style: TextStyle(fontWeight: FontWeight.bold)),
          ...subtasks.map((s) => ListTile(key: ValueKey(s.id), leading: Checkbox(value:s.done, onChanged:(b)=>setState(()=>s.done=b ?? false)), title: TextFormField(initialValue:s.title, decoration: const InputDecoration(border: InputBorder.none), onChanged:(val)=>s.title=val), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=>setState(()=>subtasks.removeWhere((x)=>x.id==s.id))))),
          TextButton.icon(onPressed: ()=>setState(()=>subtasks.add(Subtask(id: UniqueKey().toString(), title: ''))), icon: const Icon(Icons.add), label: const Text('Add subtask')),
          const SizedBox(height:20),
          ElevatedButton(onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            _formKey.currentState!.save();
            final t = Todo(id: widget.todo?.id ?? UniqueKey().toString(), title: title, description: description, dueDate: dueDate, priority: priority, done: widget.todo?.done ?? false, subtasks: subtasks.where((s)=>s.title.trim().isNotEmpty).toList(), createdAt: widget.todo?.createdAt, category: category, reminder: reminder);
            if (widget.todo == null) prov.addTodo(t); else prov.updateTodo(t);
            Navigator.pop(context);
          }, child: const Text('Save'))
        ])),
      ),
    );
  }
}

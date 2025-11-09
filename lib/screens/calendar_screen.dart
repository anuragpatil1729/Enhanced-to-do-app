import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../utils/helpers.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  void _prev() => setState(()=> month = DateTime(month.year, month.month-1));
  void _next() => setState(()=> month = DateTime(month.year, month.month+1));

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TodoProvider>(context);
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final days = last.day;
    final startWeekday = first.weekday % 7; // sunday=0
    return Scaffold(
      appBar: AppBar(title: Text('${month.year} - ${month.month}')),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(onPressed:_prev, icon: const Icon(Icons.chevron_left)),
          Text('${month.year} / ${month.month}'),
          IconButton(onPressed:_next, icon: const Icon(Icons.chevron_right)),
        ]),
        const SizedBox(height:8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7),
            itemCount: startWeekday + days,
            itemBuilder: (ctx, idx) {
              if (idx < startWeekday) return const SizedBox.shrink();
              final day = idx - startWeekday + 1;
              final dt = DateTime(month.year, month.month, day);
              final count = prov.todos.where((t) => t.dueDate != null && t.dueDate!.year==dt.year && t.dueDate!.month==dt.month && t.dueDate!.day==dt.day).length;
              return Card(
                margin: const EdgeInsets.all(4),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$day', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (count>0) Expanded(child: Align(alignment: Alignment.bottomLeft, child: CircleAvatar(radius:10, child: Text('$count', style: const TextStyle(fontSize:10)))))
                  ]),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}

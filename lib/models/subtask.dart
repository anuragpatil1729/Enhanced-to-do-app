class Subtask {
  String id;
  String title;
  bool done;

  Subtask({
    required this.id,
    required this.title,
    this.done = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'done': done,
  };

  factory Subtask.fromMap(Map<String, dynamic> m) => Subtask(
    id: m['id'],
    title: m['title'],
    done: m['done'] ?? false,
  );
}

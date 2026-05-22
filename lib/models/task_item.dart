/// Tarefa do calendário (com estado feito/não feito).
class TaskItem {
  final String id;
  final String text;
  bool done;
  TaskItem({required this.id, required this.text, this.done = false});

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'done': done};
  factory TaskItem.fromJson(Map<String, dynamic> j) => TaskItem(
        id: j['id'] as String,
        text: j['text'] as String,
        done: j['done'] as bool? ?? false,
      );
}

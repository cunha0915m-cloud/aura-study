import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/tasks_provider.dart';
import '../../utils/constants.dart';

/// Calendário com tarefas (check feito/não feito + apagar).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  Future<void> _addTask() async {
    final ctrl = TextEditingController();
    final task = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nova tarefa — ${_selected.day}/${_selected.month}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex: Estudar Física 📚'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (task == null || task.isEmpty) return;
    await context.read<TasksProvider>().add(_selected, task);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksProvider>();
    final list = tasks.tasksFor(_selected);
    final doneCount = list.where((t) => t.done).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focused,
              selectedDayPredicate: (d) => isSameDay(d, _selected),
              onDaySelected: (s, f) => setState(() {
                _selected = s;
                _focused = f;
              }),
              eventLoader: (d) => tasks.tasksFor(d),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
            ),
            const Divider(height: 1),
            // Cabeçalho com progresso
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    '${_selected.day}/${_selected.month}/${_selected.year}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (list.isNotEmpty)
                    Text(
                      '$doneCount/${list.length} feito',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text('Sem tarefas. Toca em + para adicionar.'),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final t = list[i];
                        return Dismissible(
                          key: ValueKey(t.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) =>
                              tasks.remove(_selected, t.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.redAccent.withOpacity(0.15),
                            child: const Icon(Icons.delete_rounded,
                                color: Colors.redAccent),
                          ),
                          child: CheckboxListTile(
                            value: t.done,
                            onChanged: (_) =>
                                tasks.toggleDone(_selected, t.id),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            activeColor: AppColors.primary,
                            title: Text(
                              t.text,
                              style: TextStyle(
                                decoration: t.done
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: t.done ? Colors.grey : null,
                              ),
                            ),
                            secondary: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () =>
                                  tasks.remove(_selected, t.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _addTask,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/goals_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import 'subject_detail_screen.dart';

/// Hub da área de estudo: pomodoro, calendário, objetivos, estatísticas.
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _statsCard(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _tile(
                    context,
                    icon: Icons.timer_rounded,
                    title: 'Pomodoro',
                    subtitle: '25 min foco',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.pomodoro),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _tile(
                    context,
                    icon: Icons.calendar_today_rounded,
                    title: 'Calendário',
                    subtitle: 'Tarefas',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.calendar),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _tile(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: 'Disciplinas',
                    subtitle: '${Subjects.all.length} ativas',
                    onTap: () => _showSubjectsSheet(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _tile(
                    context,
                    icon: Icons.flag_rounded,
                    title: 'Objetivos',
                    subtitle: '3 hoje',
                    onTap: () => _showGoalsDialog(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Os meus objetivos',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () => _showSubjectsSheet(context),
                  child: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _goalsList(context),
          ],
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext ctx) {
    final goals = ctx.watch<GoalsProvider>();
    final done = goals.all.where((g) => g.done).length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _stat('🔥', '$done', 'objetivos\nfeitos'),
          _stat('⭐', 'Nv ${goals.level}', '${goals.xp} XP'),
          _stat('🎯', '${goals.all.length}', 'no total'),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext ctx,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: dark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showSubjectsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Disciplinas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...Subjects.all.map((s) => ListTile(
                  leading: Text(Subjects.emoji(s),
                      style: const TextStyle(fontSize: 22)),
                  title: Text(s),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectDetailScreen(subject: s),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showGoalsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Objetivos de hoje'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Estudar Matemática (30 min)')),
            ListTile(
                leading: Icon(Icons.radio_button_unchecked),
                title: Text('Resumo de História')),
            ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Quiz de Inglês')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar')),
        ],
      ),
    );
  }

  Widget _goalsList(BuildContext ctx) {
    final goalsProv = ctx.watch<GoalsProvider>();
    final goals = goalsProv.all.take(8).toList();
    if (goals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('Sem objetivos. Adiciona um!')),
      );
    }
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: goals.map((g) {
          return ListTile(
            leading: Icon(
              g.done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: g.done ? AppColors.primary : Colors.grey,
            ),
            title: Text(
              g.text,
              style: TextStyle(
                decoration: g.done ? TextDecoration.lineThrough : null,
                color: g.done ? Colors.grey : null,
              ),
            ),
            subtitle: Text('${Subjects.emoji(g.subject)} ${g.subject}',
                style: const TextStyle(fontSize: 11)),
            trailing: Text('+${g.xp} XP',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
            onTap: () => goalsProv.toggleDone(g.id),
          );
        }).toList(),
      ),
    );
  }
}

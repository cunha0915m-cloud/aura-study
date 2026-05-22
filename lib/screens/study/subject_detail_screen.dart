import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/goals_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/comments_sheet.dart';
import '../../widgets/post_card.dart';

/// Detalhe de uma disciplina: hero, objetivos, conteúdos do feed e ações.
class SubjectDetailScreen extends StatelessWidget {
  final String subject;
  const SubjectDetailScreen({super.key, required this.subject});

  Future<void> _addGoal(BuildContext context) async {
    final ctrl = TextEditingController();
    int xp = 15;
    final text = await showDialog<String>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text('Novo objetivo — $subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Ex: Resolver pág. 32'),
                onSubmitted: (v) => Navigator.pop(ctx, v),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Dificuldade (XP ao concluir):'),
              ),
              Slider(
                value: xp.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: '$xp XP',
                activeColor: AppColors.primary,
                onChanged: (v) => setSt(() => xp = v.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: Text('Adicionar +$xp XP')),
          ],
        ),
      ),
    );
    if (text == null || text.isEmpty) return;
    if (!context.mounted) return;
    await context.read<GoalsProvider>().add(subject, text, xp: xp);
  }

  void _toggleAndCelebrate(BuildContext context, Goal g) async {
    final delta = await context.read<GoalsProvider>().toggleDone(g.id);
    if (!context.mounted || delta <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('🎉 +$delta XP! Continua assim.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final goalsProv = context.watch<GoalsProvider>();
    final user = context.watch<AuthProvider>().user;
    final uid = user?.uid ?? 'guest';
    final posts = feed.posts.where((p) => p.subject == subject).toList();
    final goals = goalsProv.bySubject(subject);
    final completed = goals.where((g) => g.done).length;
    final progress = goals.isEmpty ? 0.0 : completed / goals.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(subject,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    Subjects.emoji(subject),
                    style: const TextStyle(fontSize: 70),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: _statsCard(context, completed, goals.length, progress)),
          SliverToBoxAdapter(child: _quickActions(context)),
          SliverToBoxAdapter(child: _goalsHeader()),
          if (goals.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                      'Sem objetivos. Toca em "Objetivo" em baixo para criar!'),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: goals.length,
              itemBuilder: (_, i) {
                final g = goals[i];
                return Dismissible(
                  key: ValueKey(g.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) =>
                      context.read<GoalsProvider>().remove(g.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.redAccent.withOpacity(0.15),
                    child: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                  child: CheckboxListTile(
                    value: g.done,
                    onChanged: (_) => _toggleAndCelebrate(context, g),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary,
                    title: Text(
                      g.text,
                      style: TextStyle(
                        decoration:
                            g.done ? TextDecoration.lineThrough : null,
                        color: g.done ? Colors.grey : null,
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('+${g.xp} XP',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          SliverToBoxAdapter(child: _postsHeader(posts.length)),
          if (posts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                      'Ainda não há conteúdos partilhados nesta disciplina.'),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) {
                final p = posts[i];
                return PostCard(
                  post: p,
                  liked: p.likes.contains(uid),
                  favorited: feed.isFavorite(p.id),
                  onLike: () => feed.toggleLike(p, uid),
                  onComment: () => CommentsSheet.show(context, p.id),
                  onFavorite: () => feed.toggleFavorite(p.id),
                  onShare: () {},
                  onTap: () => CommentsSheet.show(context, p.id),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _addGoal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Objetivo',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _statsCard(
      BuildContext context, int completed, int total, double progress) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Progresso',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('$completed/$total',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _action(
              context: context,
              icon: Icons.timer_rounded,
              label: 'Pomodoro',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.pomodoro),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _action(
              context: context,
              icon: Icons.auto_awesome,
              label: 'Pedir à Aura AI',
              onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _action(
              context: context,
              icon: Icons.upload_rounded,
              label: 'Partilhar',
              onTap: () => Navigator.pushNamed(context, AppRoutes.upload),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(
      {required BuildContext context,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _goalsHeader() => const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Text('🎯 Objetivos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );

  Widget _postsHeader(int n) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Text('📚 Conteúdos partilhados ($n)',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800)),
      );
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/goals_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/comments_sheet.dart';
import '../../widgets/post_card.dart';
import '../../widgets/subject_chip.dart';
import '../study/subject_detail_screen.dart';

/// Feed principal — estilo Knowunity.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final user = context.watch<AuthProvider>().user;
    final filters = ['Todos', ...Subjects.all];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: feed.refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(user?.name ?? 'Estudante')),
              SliverToBoxAdapter(child: _searchBar()),
              SliverToBoxAdapter(child: _aiHighlight(context)),
              SliverToBoxAdapter(child: _filters(feed, filters)),
              SliverList.builder(
                itemCount: feed.posts.length,
                itemBuilder: (_, i) {
                  final p = feed.posts[i];
                  final uid = user?.uid ?? 'guest';
                  return PostCard(
                    post: p,
                    liked: p.likes.contains(uid),
                    favorited: feed.isFavorite(p.id),
                    onLike: () => feed.toggleLike(p, uid),
                    onComment: () => CommentsSheet.show(context, p.id),
                    onFavorite: () => feed.toggleFavorite(p.id),
                    onTap: () => CommentsSheet.show(context, p.id),
                    onShare: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              'aurastudy://post/${p.id} — ${p.title}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('🔗 Link copiado para a área de transferência')),
                      );
                    },
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, $name 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  'Pronto para mais um dia de progresso?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.ranking),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 4),
                  Text('${context.watch<GoalsProvider>().xp} XP',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: context.read<FeedProvider>().setSearch,
        decoration: const InputDecoration(
          hintText: 'Pesquisar resumos, exercícios, disciplinas…',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _aiHighlight(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fala com a Aura AI',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Resumos, quizzes e explicações em segundos.',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filters(FeedProvider feed, List<String> filters) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemBuilder: (_, i) {
          final s = filters[i];
          return GestureDetector(
            onLongPress: s == 'Todos'
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectDetailScreen(subject: s),
                      ),
                    ),
            child: SubjectChip(
              subject: s,
              selected: feed.filter == s,
              onTap: () => feed.setFilter(s),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }
}

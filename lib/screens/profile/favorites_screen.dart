import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/comments_sheet.dart';
import '../../widgets/post_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final user = context.watch<AuthProvider>().user;
    final uid = user?.uid ?? 'guest';
    final list = feed.favoritePosts;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: list.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Ainda não tens conteúdos favoritos. Toca no 🔖 nos posts!',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final p = list[i];
                return PostCard(
                  post: p,
                  liked: p.likes.contains(uid),
                  favorited: true,
                  onLike: () => feed.toggleLike(p, uid),
                  onComment: () => CommentsSheet.show(context, p.id),
                  onFavorite: () => feed.toggleFavorite(p.id),
                  onShare: () {},
                  onTap: () => CommentsSheet.show(context, p.id),
                );
              },
            ),
    );
  }
}

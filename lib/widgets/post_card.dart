import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post_model.dart';
import '../utils/constants.dart';

/// Card de conteúdo educativo no feed (estilo Knowunity).
class PostCard extends StatelessWidget {
  final PostModel post;
  final bool liked;
  final bool favorited;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.liked,
    required this.favorited,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: dark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _author(context),
          const SizedBox(height: 12),
          _subjectTag(),
          const SizedBox(height: 10),
          Text(
            post.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            post.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: dark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _actions(),
        ],
      ),
      ),
    );
  }

  Widget _author(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          backgroundImage: post.authorPhoto != null
              ? NetworkImage(post.authorPhoto!)
              : null,
          child: post.authorPhoto == null
              ? Text(
                  post.authorName.isNotEmpty
                      ? post.authorName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.authorName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                DateFormat('dd MMM • HH:mm').format(post.createdAt),
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black45),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _subjectTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${Subjects.emoji(post.subject)}  ${post.subject}',
        style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12),
      ),
    );
  }

  Widget _actions() {
    return Row(
      children: [
        _action(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          label: '${post.likes.length}',
          color: liked ? Colors.redAccent : null,
          onTap: onLike,
        ),
        const SizedBox(width: 18),
        _action(
          icon: Icons.mode_comment_outlined,
          label: '${post.commentsCount}',
          onTap: onComment,
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            favorited ? Icons.bookmark : Icons.bookmark_border,
            color: favorited ? AppColors.primary : null,
          ),
          onPressed: onFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: onShare,
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

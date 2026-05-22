/// Comentário simples num post.
class CommentModel {
  final String id;
  final String postId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

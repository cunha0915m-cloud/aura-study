/// Conteúdo educativo partilhado no feed (apontamentos, PDFs, resumos).
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String title;
  final String description;
  final String subject;
  final String? fileUrl;
  final String? imageUrl;
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.title,
    required this.description,
    required this.subject,
    this.fileUrl,
    this.imageUrl,
    this.likes = const [],
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anónimo',
      authorPhoto: map['authorPhoto'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? 'Geral',
      fileUrl: map['fileUrl'],
      imageUrl: map['imageUrl'],
      likes: List<String>.from(map['likes'] ?? const []),
      commentsCount: (map['commentsCount'] ?? 0) as int,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'authorPhoto': authorPhoto,
        'title': title,
        'description': description,
        'subject': subject,
        'fileUrl': fileUrl,
        'imageUrl': imageUrl,
        'likes': likes,
        'commentsCount': commentsCount,
        'createdAt': createdAt.toIso8601String(),
      };
}

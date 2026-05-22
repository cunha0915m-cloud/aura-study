import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/task_item.dart';
import '../providers/goals_provider.dart';

/// Operações de leitura/escrita no Firestore para o feed, chat, objetivos e XP.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═════════════════════════════════════════════════
  // POSTS & COMENTÁRIOS (Feed)
  // ═════════════════════════════════════════════════

  Future<List<PostModel>> fetchPosts() async {
    final snap = await _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) => PostModel.fromMap(d.id, d.data())).toList();
  }

  Future<void> createPost(PostModel post) =>
      _db.collection('posts').doc(post.id).set(post.toMap());

  Future<void> toggleLike(String postId, String userId) async {
    final ref = _db.collection('posts').doc(postId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final likes = List<String>.from(doc.data()?['likes'] ?? const []);
    likes.contains(userId) ? likes.remove(userId) : likes.add(userId);
    await ref.update({'likes': likes});
  }

  Future<List<CommentModel>> fetchComments(String postId) async {
    final snap = await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();
    return snap.docs.map((d) {
      final map = d.data();
      return CommentModel(
        id: d.id,
        postId: postId,
        authorName: map['authorName'] ?? 'Anónimo',
        text: map['text'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> createComment(String postId, CommentModel comment) async {
    // Adiciona o comentário à subcoleção do post
    await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(comment.id)
        .set({
      'authorName': comment.authorName,
      'text': comment.text,
      'createdAt': comment.createdAt.toIso8601String(),
    });

    // Incrementa o contador de comentários no post principal
    final ref = _db.collection('posts').doc(postId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        final current = (snap.data()?['commentsCount'] ?? 0) as int;
        tx.update(ref, {'commentsCount': current + 1});
      }
    });
  }

  // ═════════════════════════════════════════════════
  // CHAT (Histórico de Perguntas e Respostas com a IA)
  // ═════════════════════════════════════════════════

  Future<List<Map<String, String>>> fetchChatHistory(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('chatHistory')
        .orderBy('timestamp', descending: false)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return {
        'role': (data['role'] ?? 'user').toString(),
        'content': (data['content'] ?? '').toString(),
      };
    }).toList();
  }

  Future<void> saveChatMessage(String userId, String role, String content) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('chatHistory')
        .add({
      'role': role,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearChatHistory(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('chatHistory')
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ═════════════════════════════════════════════════
  // OBJETIVOS & XP (Gamificação)
  // ═════════════════════════════════════════════════

  Future<List<Goal>> fetchGoals(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return Goal(
        id: d.id,
        subject: m['subject'] ?? 'Geral',
        text: m['text'] ?? '',
        done: m['done'] ?? false,
        xp: m['xp'] ?? 10,
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> saveGoal(String userId, Goal goal) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goal.id)
        .set(goal.toJson());
  }

  Future<void> deleteGoal(String userId, String goalId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  Future<int> fetchUserXp(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return (doc.data()?['xp'] ?? 0) as int;
  }

  Future<void> saveUserXp(String userId, int xp) async {
    await _db.collection('users').doc(userId).set(
      {'xp': xp},
      SetOptions(merge: true),
    );
  }
}

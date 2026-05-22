import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';

/// Gestão do feed de conteúdos educativos.
class FeedProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  static const _uuid = Uuid();

  List<PostModel> _posts = _mockPosts();
  String _filter = 'Todos';
  String _search = '';

  /// IDs de posts marcados como favoritos pelo utilizador (persistido).
  final Set<String> _favorites = {};
  Set<String> get favorites => _favorites;

  /// Comentários por postId.
  final Map<String, List<CommentModel>> _comments = {};
  List<CommentModel> commentsFor(String postId) =>
      List.unmodifiable(_comments[postId] ?? const []);

  FeedProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final p = await SharedPreferences.getInstance();
    _favorites.addAll(p.getStringList('favorites') ?? const []);
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favorites', _favorites.toList());
  }

  bool isFavorite(String postId) => _favorites.contains(postId);

  Future<void> toggleFavorite(String postId) async {
    _favorites.contains(postId)
        ? _favorites.remove(postId)
        : _favorites.add(postId);
    await _saveFavorites();
    notifyListeners();
  }

  /// Cria post local e sincroniza no Firestore (se ativo).
  Future<void> createPost({
    required String authorId,
    required String authorName,
    String? authorPhoto,
    required String title,
    required String description,
    required String subject,
    String? attachmentName,
  }) async {
    final p = PostModel(
      id: _uuid.v4(),
      authorId: authorId,
      authorName: authorName,
      authorPhoto: authorPhoto,
      title: title,
      description: description,
      subject: subject,
      fileUrl: attachmentName,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, p);
    notifyListeners();

    // Persiste no Firestore se estiver ativo
    try {
      await _fs.createPost(p);
    } catch (e) {
      debugPrint('⚠️ Erro ao persistir post no Firestore: $e');
    }
  }

  /// Adiciona comentário a um post (local + Firestore).
  Future<void> addComment(String postId, String authorName, String text) async {
    final c = CommentModel(
      id: _uuid.v4(),
      postId: postId,
      authorName: authorName,
      text: text,
    );
    
    final list = _comments.putIfAbsent(postId, () => []);
    list.add(c);

    // Atualiza contador no post local
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final old = _posts[idx];
      _posts[idx] = PostModel(
        id: old.id,
        authorId: old.authorId,
        authorName: old.authorName,
        authorPhoto: old.authorPhoto,
        title: old.title,
        description: old.description,
        subject: old.subject,
        fileUrl: old.fileUrl,
        imageUrl: old.imageUrl,
        likes: old.likes,
        commentsCount: list.length,
        createdAt: old.createdAt,
      );
    }
    notifyListeners();

    // Persiste no Firestore
    try {
      await _fs.createComment(postId, c);
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar comentário no Firestore: $e');
    }
  }

  /// Devolve apenas os posts favoritos do utilizador atual.
  List<PostModel> get favoritePosts =>
      _posts.where((p) => _favorites.contains(p.id)).toList();

  /// Devolve apenas os posts criados pelo utilizador.
  List<PostModel> myPosts(String userId) =>
      _posts.where((p) => p.authorId == userId).toList();

  List<PostModel> get posts {
    return _posts.where((p) {
      final matchSubject = _filter == 'Todos' || p.subject == _filter;
      final matchSearch = _search.isEmpty ||
          p.title.toLowerCase().contains(_search.toLowerCase()) ||
          p.description.toLowerCase().contains(_search.toLowerCase());
      return matchSubject && matchSearch;
    }).toList();
  }

  String get filter => _filter;

  void setFilter(String s) {
    _filter = s;
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      final remote = await _fs.fetchPosts();
      if (remote.isNotEmpty) _posts = remote;
    } catch (_) {
      // mantém os mocks se Firebase ainda não configurado
    }
    notifyListeners();
  }

  Future<void> toggleLike(PostModel post, String userId) async {
    final idx = _posts.indexWhere((p) => p.id == post.id);
    if (idx == -1) return;
    final likes = List<String>.from(_posts[idx].likes);
    likes.contains(userId) ? likes.remove(userId) : likes.add(userId);
    _posts[idx] = PostModel(
      id: post.id,
      authorId: post.authorId,
      authorName: post.authorName,
      authorPhoto: post.authorPhoto,
      title: post.title,
      description: post.description,
      subject: post.subject,
      fileUrl: post.fileUrl,
      imageUrl: post.imageUrl,
      likes: likes,
      commentsCount: post.commentsCount,
      createdAt: post.createdAt,
    );
    notifyListeners();

    try {
      await _fs.toggleLike(post.id, userId);
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar like no Firestore: $e');
    }
  }

  static List<PostModel> _mockPosts() {
    final now = DateTime.now();
    return [
      PostModel(
        id: '1',
        authorId: 'u1',
        authorName: 'Mariana Costa',
        title: 'Resumo completo de Funções Quadráticas',
        description:
            'Vértice, eixo de simetria, raízes pela fórmula resolvente e exemplos resolvidos passo a passo.',
        subject: 'Matemática',
        likes: const ['a', 'b', 'c'],
        commentsCount: 12,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      PostModel(
        id: '2',
        authorId: 'u2',
        authorName: 'João Almeida',
        title: 'Os Lusíadas — Canto I explicado',
        description:
            'Estrutura, personagens e os principais episódios do Canto I de forma simples.',
        subject: 'Português',
        likes: const ['a', 'b'],
        commentsCount: 7,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      PostModel(
        id: '3',
        authorId: 'u3',
        authorName: 'Sofia Pereira',
        title: 'Introdução ao Dart e Flutter',
        description:
            'Variáveis, funções, widgets stateless vs stateful e o teu primeiro app.',
        subject: 'Programação',
        likes: const ['a', 'b', 'c', 'd', 'e'],
        commentsCount: 21,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}

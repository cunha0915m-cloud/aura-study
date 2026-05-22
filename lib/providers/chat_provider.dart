import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../services/ai_service.dart';
import 'settings_provider.dart';

/// Estado das conversas com a Aura AI (suporta várias sessões).
class ChatProvider extends ChangeNotifier {
  final AiService _ai = AiService();
  final _uuid = const Uuid();

  AiProvider _provider = AiProvider.free;
  String _apiKey = '';
  String? _userId;

  final List<ChatSession> _sessions = [];
  String? _activeId;
  bool _loading = false;
  bool _initialized = false;

  List<ChatSession> get sessions => List.unmodifiable(
      _sessions..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  ChatSession? get active =>
      _sessions.firstWhere((s) => s.id == _activeId, orElse: _emptyFallback);
  String? get activeId => _activeId;
  List<ChatMessage> get messages =>
      active == null ? const [] : List.unmodifiable(active!.messages);
  bool get loading => _loading;

  ChatSession _emptyFallback() => ChatSession(
        id: '',
        title: '',
        messages: [_welcomeMessage()],
      );

  ChatMessage _welcomeMessage() => ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        content:
            'Olá! Eu sou a **Aura AI** ✨\n\nPosso ajudar-te a:\n- Explicar exercícios\n- Criar resumos\n- Gerar quizzes\n- Organizar o teu estudo\n\nO que queres estudar hoje?',
      );

  String get _storageKey => 'chat_sessions_${_userId ?? 'guest'}';

  /// Atualiza a sessão ativa. Sempre que o `userId` muda (login, logout,
  /// convidado), o estado em memória é limpo e o histórico do novo utilizador
  /// é carregado das `SharedPreferences`.
  Future<void> updateSession(String? userId, SettingsProvider s) async {
    _provider = s.provider;
    _apiKey = s.apiKey;

    if (!_initialized || _userId != userId) {
      _initialized = true;
      _userId = userId;
      _sessions.clear();
      _activeId = null;
      notifyListeners();
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_storageKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _sessions
          ..clear()
          ..addAll(list.map((e) => ChatSession.fromJson(
                Map<String, dynamic>.from(e),
                idGenerator: () => _uuid.v4(),
              )));
      } catch (_) {}
    }

    if (_sessions.isEmpty) {
      _createSessionInternal(notify: false);
    } else {
      _activeId = _sessions.first.id;
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _storageKey,
      jsonEncode(_sessions.map((s) => s.toJson()).toList()),
    );
  }

  // ───────── Gestão de Sessões ─────────

  ChatSession _createSessionInternal({bool notify = true}) {
    final s = ChatSession(
      id: _uuid.v4(),
      title: 'Nova Conversa',
      messages: [_welcomeMessage()],
    );
    _sessions.add(s);
    _activeId = s.id;
    if (notify) {
      _persist();
      notifyListeners();
    }
    return s;
  }

  Future<ChatSession> newSession() async {
    final s = _createSessionInternal();
    return s;
  }

  void selectSession(String id) {
    if (_sessions.any((s) => s.id == id)) {
      _activeId = id;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeId == id) {
      if (_sessions.isEmpty) {
        _createSessionInternal(notify: false);
      } else {
        _activeId = _sessions.first.id;
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> renameSession(String id, String newTitle) async {
    final idx = _sessions.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _sessions[idx].title = newTitle.trim().isEmpty ? 'Conversa' : newTitle.trim();
    await _persist();
    notifyListeners();
  }

  // ───────── Mensagens ─────────

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    if (_activeId == null) {
      _createSessionInternal(notify: false);
    }
    final session = _sessions.firstWhere((s) => s.id == _activeId);

    final userContent = text.trim();
    session.messages.add(ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: userContent,
    ));

    // Auto-titulo na primeira mensagem
    if (session.title == 'Nova Conversa') {
      session.title = userContent.length > 30
          ? '${userContent.substring(0, 30)}…'
          : userContent;
    }
    notifyListeners();

    _loading = true;
    final typingId = _uuid.v4();
    session.messages.add(ChatMessage(
      id: typingId,
      role: ChatRole.assistant,
      content: '',
      isTyping: true,
    ));
    notifyListeners();

    try {
      final answer = await _ai.sendMessage(
        session.messages
            .where((m) => !m.isTyping)
            .map((m) => {'role': m.role.name, 'content': m.content})
            .toList(),
        provider: _provider,
        apiKey: _apiKey,
      );

      session.messages.removeWhere((m) => m.id == typingId);
      session.messages.add(ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        content: answer,
      ));
    } catch (e) {
      session.messages.removeWhere((m) => m.id == typingId);
      session.messages.add(ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        content: '⚠️ Erro a contactar a IA: $e',
      ));
    } finally {
      _loading = false;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> clear() async {
    if (_activeId == null) return;
    final idx = _sessions.indexWhere((s) => s.id == _activeId);
    if (idx == -1) return;
    _sessions[idx].messages
      ..clear()
      ..add(_welcomeMessage());
    _sessions[idx].title = 'Nova Conversa';
    await _persist();
    notifyListeners();
  }
}

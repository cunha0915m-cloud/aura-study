import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'settings_provider.dart';

/// Estado das conversas com a Aura AI.
class ChatProvider extends ChangeNotifier {
  final AiService _ai = AiService();
  final FirestoreService _fs = FirestoreService();
  final _uuid = const Uuid();

  /// Configuração ativa da IA (provider + chave).
  AiProvider _provider = AiProvider.free;
  String _apiKey = '';
  String? _userId;

  void updateSession(String? userId, SettingsProvider s) {
    _provider = s.provider;
    _apiKey = s.apiKey;
    
    if (_userId != userId) {
      _userId = userId;
      if (userId != null && AppConfig.useFirebase) {
        _loadHistory();
      }
    }
  }

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'welcome',
      role: ChatRole.assistant,
      content:
          'Olá! Eu sou a **Aura AI** ✨\n\nPosso ajudar-te a:\n- Explicar exercícios\n- Criar resumos\n- Gerar quizzes\n- Organizar o teu estudo\n\nO que queres estudar hoje?',
    ),
  ];

  bool _loading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;

  Future<void> _loadHistory() async {
    if (_userId == null || !AppConfig.useFirebase) return;
    try {
      final history = await _fs.fetchChatHistory(_userId!);
      if (history.isNotEmpty) {
        _messages.clear();
        for (final item in history) {
          _messages.add(ChatMessage(
            id: _uuid.v4(),
            role: item['role'] == 'assistant'
                ? ChatRole.assistant
                : ChatRole.user,
            content: item['content'] ?? '',
          ));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar histórico de chat do Firestore: $e');
    }
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    final userContent = text.trim();
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: userContent,
    ));
    notifyListeners();

    // Salva no Firestore
    if (_userId != null && AppConfig.useFirebase) {
      _fs.saveChatMessage(_userId!, 'user', userContent).catchError((e) {
        debugPrint('⚠️ Erro ao salvar mensagem do utilizador no Firestore: $e');
      });
    }

    _loading = true;
    final typingId = _uuid.v4();
    _messages.add(ChatMessage(
      id: typingId,
      role: ChatRole.assistant,
      content: '',
      isTyping: true,
    ));
    notifyListeners();

    try {
      final answer = await _ai.sendMessage(
        _messages
            .where((m) => !m.isTyping)
            .map((m) => {'role': m.role.name, 'content': m.content})
            .toList(),
        provider: _provider,
        apiKey: _apiKey,
      );

      _messages.removeWhere((m) => m.id == typingId);
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        content: answer,
      ));

      // Salva resposta da IA no Firestore
      if (_userId != null && AppConfig.useFirebase) {
        _fs.saveChatMessage(_userId!, 'assistant', answer).catchError((e) {
          debugPrint('⚠️ Erro ao salvar resposta da IA no Firestore: $e');
        });
      }
    } catch (e) {
      _messages.removeWhere((m) => m.id == typingId);
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        content: '⚠️ Erro a contactar a IA: $e',
      ));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _messages
      ..clear()
      ..add(ChatMessage(
        id: 'welcome',
        role: ChatRole.assistant,
        content: 'Conversa reiniciada. Em que posso ajudar?',
      ));
    notifyListeners();

    if (_userId != null && AppConfig.useFirebase) {
      try {
        await _fs.clearChatHistory(_userId!);
      } catch (e) {
        debugPrint('⚠️ Erro ao limpar chat no Firestore: $e');
      }
    }
  }
}

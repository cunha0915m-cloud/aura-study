/// Mensagem usada no chat com a Aura AI.
enum ChatRole { user, assistant, system }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? createdAt,
    this.isTyping = false,
  }) : createdAt = createdAt ?? DateTime.now();

  ChatMessage copyWith({String? content, bool? isTyping}) => ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
        isTyping: isTyping ?? this.isTyping,
      );
}

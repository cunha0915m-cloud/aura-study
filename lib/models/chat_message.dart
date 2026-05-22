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

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j, {required String id}) =>
      ChatMessage(
        id: id,
        role: j['role'] == 'assistant'
            ? ChatRole.assistant
            : j['role'] == 'system'
                ? ChatRole.system
                : ChatRole.user,
        content: j['content'] as String? ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );
}

/// Representa uma conversa independente com a Aura AI.
class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(
    Map<String, dynamic> j, {
    required String Function() idGenerator,
  }) =>
      ChatSession(
        id: j['id'] as String,
        title: j['title'] as String? ?? 'Conversa',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        messages: ((j['messages'] as List?) ?? [])
            .map((m) => ChatMessage.fromJson(
                Map<String, dynamic>.from(m as Map),
                id: idGenerator()))
            .toList(),
      );
}

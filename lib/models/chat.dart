class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
    );
  }
}

class ChatSession {
  final String id;
  final List<ChatMessage> chat;

  ChatSession({required this.id, required this.chat});

  Map<String, dynamic> toJson() => {
        'id': id,
        'chat': chat,
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      chat: json['chat'] as List<ChatMessage>,
    );
  }
}
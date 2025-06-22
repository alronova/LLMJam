class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String message;

  ChatMessage({required this.role, required this.message});

  Map<String, dynamic> toJson() => {
        'role': role,
        'message': message,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      message: json['message'],
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
      chat: json['chat'],
    );
  }
}
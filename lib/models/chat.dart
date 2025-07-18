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
  final String title;
  final String description;
  final List<ChatMessage> chat;

  ChatSession({required this.id, required this.title, required this.description, required this.chat});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'chat': chat,
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      chat: json['chat'] as List<ChatMessage>,
    );
  }
}
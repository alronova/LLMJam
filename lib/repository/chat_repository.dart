import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:llm_jam/models/chat.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatRepository {
  final baseUrl = dotenv.get("B_URL");

  Future<List<ChatSession>> getChatSessions() async {
    final token = await FlutterSecureStorage().read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final body = jsonDecode(response.body);
    final data = body['data'];
    if (response.statusCode == 200) {
      if (data['chats'] == null) {
        return [];
      } else {
        return (data['chats'] as List)
            .map((e) => ChatSession(
                  id: e['id'],
                  title: e['title'] ?? 'Untitled Chat',
                  description: e['description'] ?? '',
                  chat: (e['chat'] as List)
                      .map((m) => ChatMessage(
                            role: m['role'],
                            content: m['content'],
                          ))
                      .toList(),
                ))
            .toList();
          }
    } else {
      throw Exception('Failed to fetch chat sessions: ${body['message']}');
    }
  }
}

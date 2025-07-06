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
    final body = await jsonDecode(response.body);
    final data = await body['data'];
    if (response.statusCode == 200) {
      if (data['chats'] != null) {        
        return (data['chats'] as List)
            .map((e) => ChatSession(
                  id: e['id'],
                  title: e['title'].isNotEmpty ? e['title'] : 'Untitled Chat',
                  description: e['description'].isNotEmpty ? e['description'] : 'No description',
                  chat: (e['chat'] as List)
                      .map((m) => ChatMessage(
                            role: m['role'],
                            content: m['content'],
                          ))
                      .toList(),
                ))
            .toList();
          }
      return [];
    } else {
      throw Exception('Failed to fetch chat sessions: ${body['message']}');
    }
  }

  Future<List<ChatMessage>> getChatMessages(String chatId) async {
    final token = await FlutterSecureStorage().read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final body = await jsonDecode(response.body);
    final data = await body['data'];
    final List chats = await data['chats'];
    if (response.statusCode == 200) {
      if (chats.isNotEmpty) {
        final chatSession = chats.firstWhere(
          (e) => e['id'] == chatId,
          orElse: () => null,
        );
        return (chatSession['chat'] as List)
            .map((m) => ChatMessage(
                  role: m['role'],
                  content: m['content'],
                ))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to fetch chat messages: ${body['message']}');
    }
  }

  Future<void> sendChatMessage(String chatId, ChatMessage message) async {
    final token = await FlutterSecureStorage().read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/message'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
        body: jsonEncode({
          'chatId': chatId,
          'message': message,
        }),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<void> getLLMres(String chatId, String model, List<ChatMessage> messages) async {
    final token = await FlutterSecureStorage().read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
      }),
    );
    final body = jsonDecode(response.body);
    final content = body['choices'][0]['message']['content'];
    final error = body['error'];

    final ChatMessage message = ChatMessage(
      role: 'assistant',
      content: content,
    );

    if (response.statusCode != 200) {
      throw Exception(error);
    }
    await sendChatMessage(chatId, message);
  }
}

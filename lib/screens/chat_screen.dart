import 'package:flutter/material.dart';
import 'package:llm_jam/models/chat.dart';

class ChatScreen extends StatelessWidget {
    final String id;
    final String title;
    final String description;
    final List<ChatMessage> chat;

  const ChatScreen({super.key, required this.id, required this.title, required this.description, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: chat.length,
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final message = chat[index];
                  return ListTile(
                    title: Text(message.content),
                    subtitle: Text(message.role),
                    tileColor: message.role == 'user' ? Colors.blue[50] : Colors.green[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    leading: CircleAvatar(
                      backgroundColor: message.role == 'user' ? Colors.blue : Colors.green,
                      child: Text(message.role == 'user' ? 'U' : 'A', style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10),
              ),
            ),
            BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Type a message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        // Handle send message
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
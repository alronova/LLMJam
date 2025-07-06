import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_jam/blocs/chat/chat_bloc.dart';
import 'package:llm_jam/models/chat.dart';
import 'package:llm_jam/repository/chat_repository.dart';

class ChatScreen extends StatelessWidget {
    final String id;
    final String title;
    final String description;
    final List<ChatMessage> chat;
    final TextEditingController _messageController = TextEditingController();
    final ChatRepository chatRepo = ChatRepository();


    final Map<String, String> models = {
      'mistralai/mistral-small-3.2-24b-instruct:free': 'Mistral Small 3.2(24B)',
      'moonshotai/kimi-dev-72b:free': 'Kimi Dev 72B',
      'deepseek/deepseek-r1-0528:free': 'DeepSeek R1 0528',
      'google/gemma-3n-e4b-it:free': 'Google Gemma 3N E4B',
      'qwen/qwen3-32b:free': 'Qwen3 32B',
      'nvidia/llama-3.3-nemotron-super-49b-v1:free': 'NVIDIA: Llama 3.3 Nemotron Super 49B',
    };

    final ValueNotifier<String?> selectedValueNotifier = ValueNotifier(null);
    String? model;


  ChatScreen({super.key, required this.id, required this.title, required this.description, required this.chat});

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
      body: BlocProvider(
        create: (context) => ChatBloc(chatRepository: chatRepo)
        ..add(ChatMessagesRequested(chatId: id)),
        child: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ChatLoading){
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.error,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              );
            } else if (state is ChatLoaded) {
              return Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                children: [
                  ValueListenableBuilder<String?>(
                    valueListenable: selectedValueNotifier,
                    builder: (context, selectedValue, _) {
                      return DropdownButton<String>(
                        padding: const EdgeInsets.all(10),
                        value: selectedValue,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                          ),
                        hint: Text("Select your preferred model"),
                        isExpanded: true,
                        items: models.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          selectedValueNotifier.value = newValue;
                          model = newValue;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${models[newValue]}" is the selected model')),
                          );
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.messages.length,
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                      final message = state.messages[index];
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
                              controller: _messageController,
                              decoration: InputDecoration(
                              labelText: 'Type a message',
                              border: OutlineInputBorder(),
                              ),
                          ),
                          ),
                          IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                              final messageContent = _messageController.text.trim();
                              if (model != null) {
                                if (messageContent.isNotEmpty) {
                                  context.read<ChatBloc>().add(
                                    ChatMessageSent(
                                      chatId: id,
                                      model: model!,
                                      message: ChatMessage(
                                        role: 'user',
                                        content: messageContent,
                                      ),
                                    ),
                                  );
                                  _messageController.clear();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a message')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a model first')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              );
            } else {
              return const Center(child: Text('No messages found.'));
            }
          },
        ),
      ),
    );
  }
}


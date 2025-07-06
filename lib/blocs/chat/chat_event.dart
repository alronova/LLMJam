part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class ChatMessagesRequested extends ChatEvent {
  final String chatId;

  ChatMessagesRequested({required this.chatId});
}

class ChatMessageSent extends ChatEvent {
  final String chatId;
  final String model;
  final ChatMessage message;

  ChatMessageSent({
    required this.chatId,
    required this.model,
    required this.message,
  });
}

part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String chatId;

  ChatLoaded({required this.messages, required this.chatId});
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);
}

class ChatMessageSent extends ChatState {
  final ChatMessage message;

  ChatMessageSent(this.message);
}

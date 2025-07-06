part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  ChatLoaded({required this.messages});
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);
}


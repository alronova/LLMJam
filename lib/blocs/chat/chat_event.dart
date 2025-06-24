part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class ChatMessagesRequested extends ChatEvent {
  final String chatId;

  ChatMessagesRequested({required this.chatId});
}

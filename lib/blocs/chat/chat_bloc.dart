import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:llm_jam/repository/chat_repository.dart';
import 'package:meta/meta.dart';
import 'package:llm_jam/models/chat.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<ChatMessagesRequested>(_onChatMessagesRequested);
    on<ChatMessageSent>(_onChatMessageSent);
  }

  FutureOr<void> _onChatMessagesRequested(ChatMessagesRequested event, Emitter<ChatState> emit)
  async {
    emit(ChatLoading());
    try {
      final chatMessages = await chatRepository.getChatMessages(event.chatId);
      if (chatMessages.isNotEmpty) {
        emit(ChatLoaded(messages: chatMessages));
      } else {
        emit(ChatError("No messages found for this chat."));
      }
    } catch (e) {
      emit(ChatError("Failed to load chat messages: ${e.toString()}"));
    }
  }

  FutureOr<void> _onChatMessageSent(ChatMessageSent event, Emitter<ChatState> emit)
  async {
    try {
      await chatRepository.sendChatMessage(event.chatId, event.message);
      final updatedChat = await chatRepository.getChatMessages(event.chatId);
      emit(ChatLoaded(messages: await chatRepository.getChatMessages(event.chatId)));
      await chatRepository.getLLMres(event.chatId, event.model, updatedChat);
      emit(ChatLoaded(messages: await chatRepository.getChatMessages(event.chatId)));
    } catch (e) {
      emit(ChatError(e.toString()));
    }    
  }
}

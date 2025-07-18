import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:llm_jam/repository/chat_repository.dart';
import 'package:llm_jam/models/chat.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChatRepository chatRepository;

  HomeBloc({required this.chatRepository}) : super(HomeInitial()) {
    on<ChatSessionsRequested>(_onChatSessionsRequested);
    on<NewChatSession>(_onNewChatSession);
  }

  FutureOr<void> _onChatSessionsRequested(event, Emitter<HomeState> emit) 
  async {
    emit(HomeLoading());
    try {
      final sessions = await chatRepository.getChatSessions();
      if (sessions.isNotEmpty) {
        emit(HomeLoaded(message: "Chat sessions loaded successfully.", chatSessions: sessions));
      } else {
        emit(HomeError("No chat sessions found."));
      }
    } catch (e) {
      emit(HomeError("Failed to load chat sessions: ${e.toString()}"));
    }
  }

  FutureOr<void> _onNewChatSession(event, Emitter<HomeState> emit) {
    emit(HomeNewSession());
  }
}

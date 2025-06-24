part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class ChatSessionsRequested extends HomeEvent {}

class NewChatSession extends HomeEvent {}

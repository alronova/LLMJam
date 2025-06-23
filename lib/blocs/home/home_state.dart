part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ChatSession> chatSessions;
  final String message;
  HomeLoaded(this.message, this.chatSessions);
}
class HomeError extends HomeState {
  final String error;
  HomeError(this.error);
}
part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

sealed class AuthActionState extends AuthState {}

sealed class AuthLoading extends AuthState {}

sealed class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

final class AuthInitial extends AuthState {}

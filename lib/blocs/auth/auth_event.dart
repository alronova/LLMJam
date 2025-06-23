part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignupRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  AuthSignupRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

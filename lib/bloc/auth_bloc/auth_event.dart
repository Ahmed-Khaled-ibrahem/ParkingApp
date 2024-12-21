part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class SignInClickEvent extends AuthEvent {
  const SignInClickEvent();
  @override
  List<Object?> get props => throw UnimplementedError();
}

class SignOutClickEvent extends AuthEvent {
  const SignOutClickEvent();
  @override
  List<Object?> get props => throw UnimplementedError();
}
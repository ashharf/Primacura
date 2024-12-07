part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserAuthenticated extends UserState {
  final User user;

  UserAuthenticated({required this.user});
}

final class UserProfileNotCompleted extends UserState {
  final User user;

  UserProfileNotCompleted({required this.user});
}

final class UserUnauthenticated extends UserState {}

final class UserError extends UserState {
  final User user;
  final String error;

  UserError({required this.user, required this.error});
}

class UserActionSuccess extends UserState {}

final class UserAuthError extends UserState {
  final String error;

  UserAuthError({required this.error});
}

extension GetUser on UserState {
  User? get user => this is UserAuthenticated ? (this as UserAuthenticated).user : null;
}

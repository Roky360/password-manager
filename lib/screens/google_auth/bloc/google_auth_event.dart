part of 'google_auth_bloc.dart';

@immutable
abstract class GoogleAuthEvent {}

class GoogleSignInEvent extends GoogleAuthEvent {
  final bool silent;

  GoogleSignInEvent({this.silent = false});
}

class GoogleSignOutEvent extends GoogleAuthEvent {}

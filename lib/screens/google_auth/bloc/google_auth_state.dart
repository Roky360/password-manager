part of 'google_auth_bloc.dart';

@immutable
abstract class GoogleAuthState {}

class GoogleAuthInitial extends GoogleAuthState {}

class GoogleLoadingState extends GoogleAuthState {}

class GoogleSignedInState extends GoogleAuthState {}

class GoogleSignedOutState extends GoogleAuthState {}

class GoogleSignInMessage extends GoogleAuthState {
  final String message;

  GoogleSignInMessage(this.message);
}

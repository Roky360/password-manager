part of 'device_auth_bloc.dart';

@immutable
abstract class DeviceAuthState {}

class DeviceAuthInitial extends DeviceAuthState {}

class AuthenticatingState extends DeviceAuthState {}

class AuthSucceededState extends DeviceAuthState {}

class AuthFailedState extends DeviceAuthState {
  final String? message;

  AuthFailedState({this.message});
}

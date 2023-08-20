part of 'device_auth_bloc.dart';

@immutable
abstract class DeviceAuthEvent {}

class RequestAuthenticationEvent extends DeviceAuthEvent {
  final String message;

  RequestAuthenticationEvent(this.message);
}

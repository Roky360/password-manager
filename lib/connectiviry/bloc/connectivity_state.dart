part of 'connectivity_bloc.dart';

@immutable
abstract class ConnectivityState {}

class OnlineState extends ConnectivityState {}

class OfflineState extends ConnectivityState {}

part of 'connectivity_bloc.dart';

@immutable
abstract class ConnectivityEvent {}

class OnlineConnectionEvent extends ConnectivityEvent {}

class OfflineConnectionEvent extends ConnectivityEvent {}

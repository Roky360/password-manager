import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../connectivity_service.dart';

part 'connectivity_event.dart';

part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService connectivityService = ConnectivityService();
  bool registeredConnectivityListener = false;
  late final StreamSubscription connectivityStreamSubscription;

  ConnectivityBloc() : super(ConnectivityService().isOnline ? OnlineState() : OfflineState()) {
    on<OnlineConnectionEvent>((event, emit) {
      connectivityService.isOnline = true;
      emit(OnlineState());
    });

    on<OfflineConnectionEvent>((event, emit) {
      connectivityService.isOnline = false;
      emit(OfflineState());
    });

    // listen to connectivity changes
    if (!registeredConnectivityListener) {
      registeredConnectivityListener = true;
      connectivityStreamSubscription =
          connectivityService.onConnectivityChangedStream.listen((event) {
        if (connectivityService.isConnectedByResult(event)) {
          add(OnlineConnectionEvent());
        } else {
          add(OfflineConnectionEvent());
        }
      });
    }
  }

  @override
  Future<void> close() async {
    await connectivityStreamSubscription.cancel();
    return super.close();
  }
}

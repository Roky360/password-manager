import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../device_auth_service.dart';

part 'device_auth_event.dart';

part 'device_auth_state.dart';

class DeviceAuthBloc extends Bloc<DeviceAuthEvent, DeviceAuthState> {
  final DeviceAuthService deviceAuthService = DeviceAuthService();

  DeviceAuthBloc() : super(DeviceAuthInitial()) {
    on<RequestAuthenticationEvent>((event, emit) async {
      emit(AuthenticatingState());

      final ({String errorMsg, bool success}) result =
          await deviceAuthService.requireAuthentication(event.message);

      if (result.success) {
        emit(AuthSucceededState());
      } else {
        emit(AuthFailedState(message: result.errorMsg));
      }
    });
  }
}

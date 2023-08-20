import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:password_manager/connectiviry/connectivity_service.dart';

import '../google_sign_in_service.dart';

part 'google_auth_event.dart';

part 'google_auth_state.dart';

class GoogleAuthBloc extends Bloc<GoogleAuthEvent, GoogleAuthState> {
  final GoogleSignInService googleSignInService = GoogleSignInService();
  final ConnectivityService connectivityService = ConnectivityService();

  GoogleAuthBloc() : super(GoogleAuthInitial()) {
    on<GoogleSignInEvent>((event, emit) async {
      emit(GoogleLoadingState());

      if (connectivityService.isOnline) {
        if (await googleSignInService.signIn(silent: event.silent)) {
          emit(GoogleSignedInState());
        } else {
          emit(GoogleSignedOutState());
        }
      } else {
        if (googleSignInService.currentUser != null) {
          emit(GoogleSignedInState());
        } else {
          emit(GoogleSignInMessage(
              "The attempt to log in was failed because there is no previously logged in account and no internet connection.\n"
              "Try to get online and log in again."));
          emit(GoogleSignedOutState());
        }
      }
    });

    on<GoogleSignOutEvent>((event, emit) async {
      emit(GoogleLoadingState());
      await googleSignInService.singOut();
      emit(GoogleSignedOutState());
    });
  }
}

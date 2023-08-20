import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:password_manager/widgets/animated_snackbar/animated_snackbar_messenger.dart';

part 'animated_snackbar_event.dart';
part 'animated_snackbar_state.dart';

class AnimatedSnackbarBloc extends Bloc<AnimatedSnackbarEvent, AnimatedSnackbarState> {
  AnimatedSnackbarBloc() : super(AnimatedSnackbarInitial()) {
    on<StopSnackBarAniamtionEvent>((event, emit) {
      emit(StopSnackbarAnimationState());
    });

    on<SnackBarAnimationCompletedEvent>((event, emit) {
      AnimatedSnackBarMessenger.removeOverlay();
      emit(SnackbarAnimationCompletedState());
    });

    on<StartSnackBarAniamtionEvent>((event, emit) {
      emit(StartSnackbarAnimationState());
    });
  }
}

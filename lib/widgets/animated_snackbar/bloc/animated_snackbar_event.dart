part of 'animated_snackbar_bloc.dart';

@immutable
abstract class AnimatedSnackbarEvent {}

class StartSnackBarAniamtionEvent extends AnimatedSnackbarEvent {}

class StopSnackBarAniamtionEvent extends AnimatedSnackbarEvent {}

class SnackBarAnimationCompletedEvent extends AnimatedSnackbarEvent {}

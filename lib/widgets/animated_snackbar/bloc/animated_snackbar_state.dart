part of 'animated_snackbar_bloc.dart';

@immutable
abstract class AnimatedSnackbarState {}

class AnimatedSnackbarInitial extends AnimatedSnackbarState {}

class StartSnackbarAnimationState extends AnimatedSnackbarState {}

class StopSnackbarAnimationState extends AnimatedSnackbarState {}

class SnackbarAnimationCompletedState extends AnimatedSnackbarState {}

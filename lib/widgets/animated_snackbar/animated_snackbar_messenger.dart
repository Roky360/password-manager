import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/widgets/animated_snackbar/animated_snackbar.dart';
import 'package:password_manager/widgets/animated_snackbar/bloc/animated_snackbar_bloc.dart';

class AnimatedSnackBarMessenger {
  static OverlayEntry? _overlayEntry;

  static void _createOverlay(
    BuildContext context, {
    required Widget child,
    required Alignment alignment,
  }) {
    context.read<AnimatedSnackbarBloc>().add(StopSnackBarAniamtionEvent());
    final OverlayEntry? prevEntry = _overlayEntry;

    _overlayEntry = OverlayEntry(
      builder: (context) => SafeArea(
          child: Align(
        alignment: alignment,
        heightFactor: 1.0,
        child: child,
      )),
    );

    Overlay.of(context).insert(_overlayEntry!, above: prevEntry);
    context.read<AnimatedSnackbarBloc>().add(StartSnackBarAniamtionEvent());
  }

  static void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void showSnackBar(BuildContext context, AnimatedSnackBar snackBar,
      {VoidCallback? onComplete}) {
    _createOverlay(context, child: snackBar, alignment: snackBar.alignment);
  }
}

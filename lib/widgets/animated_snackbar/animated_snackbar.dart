import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/widgets/animated_snackbar/bloc/animated_snackbar_bloc.dart';
import 'package:sizer/sizer.dart';

class AnimatedSnackBar extends StatefulWidget {
  final Widget content;
  final Color? bgColor;
  final EdgeInsets? contentPadding;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Alignment alignment;
  final double? elevation;
  final Duration delay;

  /// entrance animation duration
  final Duration duration;

  /// exit animation duration
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;

  final List<Effect>? entranceEffects;
  final List<Effect>? exitEffects;

  final VoidCallback? onComplete;

  /* Default values */
  static const _defaultContentPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const _defaultAlignment = Alignment.topCenter;
  static const _defaultDelay = Duration(seconds: 3);
  static const _defaultDuration = Duration(milliseconds: 500);
  static const _defaultReverseDuration = _defaultDuration;
  static const _defaultCurve = Curves.easeOutExpo;
  static const _defaultReverseCurve = Curves.easeInOut;

  const AnimatedSnackBar({
    super.key,
    required this.content,
    this.borderRadius,
    this.bgColor,
    this.contentPadding = _defaultContentPadding,
    this.alignment = _defaultAlignment,
    this.delay = _defaultDelay,
    this.duration = _defaultDuration,
    this.reverseDuration = _defaultReverseDuration,
    this.curve = _defaultCurve,
    this.reverseCurve = _defaultReverseCurve,
    this.onComplete,
    this.elevation,
    this.padding,
    this.entranceEffects,
    this.exitEffects,
  });

  @override
  State<AnimatedSnackBar> createState() => AnimatedSnackBarState();

  AnimatedSnackBar.bounce({
    super.key,
    required this.content,
    this.bgColor,
    this.contentPadding = _defaultContentPadding,
    this.padding,
    this.borderRadius,
    this.alignment = _defaultAlignment,
    this.elevation,
    this.delay = _defaultDelay,
    this.duration = _defaultDuration,
    this.reverseDuration = _defaultReverseDuration,
    this.curve = _defaultCurve,
    this.reverseCurve = _defaultReverseCurve,
    this.onComplete,
    double heightFactor = .7,
    bool fadeOut = false,
  })  : entranceEffects = [
          SlideEffect(
              begin: SlideEffect.neutralValue
                  .copyWith(dy: alignment == Alignment.topCenter ? -heightFactor : heightFactor),
              end: SlideEffect.neutralValue.copyWith(dy: -heightFactor),
              duration: duration,
              curve: Curves.elasticOut),
        ],
        exitEffects = [
          SlideEffect(
              begin: SlideEffect.neutralValue.copyWith(dy: -heightFactor),
              end: SlideEffect.neutralValue.copyWith(
                  dy: alignment == Alignment.topCenter
                      ? -(heightFactor * (fadeOut ? 1.3 : 3))
                      : heightFactor * (fadeOut ? 1.3 : 3)),
              duration: reverseDuration,
              curve: Curves.easeInCubic),
          ...(fadeOut ? [FadeEffect(begin: 1, end: 0, duration: reverseDuration)] : []),
        ];
}

class AnimatedSnackBarState extends State<AnimatedSnackBar> with TickerProviderStateMixin {
  OverlayEntry? overlayEntry;
  late final AnimationController controller;
  late final Alignment alignment;
  late final Duration delay;
  late final Duration duration;
  late final Duration reverseDuration;
  late final Curve curve;
  late final Curve reverseCurve;

  late final double startY;

  late final List<Effect> defaultEntranceFx;
  late final List<Effect> defaultExitFx;

  void show(BuildContext context) {
    controller.forward();
  }

  void hide({bool animate = true}) {
    controller.reverse();
  }

  List<Effect> getEffects() {
    List<Effect> effects = [];
    final entranceEffects = widget.entranceEffects;
    final exitEffects = widget.exitEffects;

    effects += entranceEffects ?? defaultEntranceFx;
    effects.add(ThenEffect(delay: delay));
    effects += exitEffects ?? defaultExitFx;

    return effects;
  }

  @override
  void initState() {
    super.initState();

    alignment = widget.alignment;
    delay = widget.delay;
    duration = widget.duration;
    reverseDuration = widget.reverseDuration;
    curve = widget.curve;
    reverseCurve = widget.reverseCurve;
    controller =
        AnimationController(vsync: this, duration: duration, reverseDuration: reverseDuration);
    switch (alignment) {
      case Alignment.topCenter:
        startY = -1;
        break;
      case Alignment.bottomCenter:
        startY = 1;
        break;
      default:
        startY = -1;
        break;
    }

    defaultEntranceFx = [
      SlideEffect(
          begin: SlideEffect.neutralValue.copyWith(dy: startY), duration: duration, curve: curve),
      ScaleEffect(alignment: alignment, duration: duration, curve: curve),
    ];
    defaultExitFx = [
      SlideEffect(
          end: SlideEffect.neutralValue.copyWith(dy: startY),
          duration: reverseDuration,
          curve: reverseCurve),
      ScaleEffect(
          begin: const Offset(1, 1),
          end: const Offset(0, 0),
          alignment: alignment,
          duration: reverseDuration,
          curve: reverseCurve),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) => show(context));
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimatedSnackbarBloc, AnimatedSnackbarState>(
      listener: (context, state) {
        if (state is StartSnackbarAnimationState) {
          controller.reset();
          controller.forward();
        } else if (state is StopSnackbarAnimationState) {
          controller.reset();
          context.read<AnimatedSnackbarBloc>().add(SnackBarAnimationCompletedEvent());
        }
      },
      child: SafeArea(
        child: Padding(
          padding: widget.padding ?? EdgeInsets.symmetric(vertical: 5.h),
          child: Align(
            alignment: alignment,
            child: Animate(
                controller: controller,
                autoPlay: false,
                onComplete: (_) {
                  context.read<AnimatedSnackbarBloc>().add(SnackBarAnimationCompletedEvent());

                  if (widget.onComplete != null) {
                    widget.onComplete!();
                  }
                },
                effects: getEffects(),
                child: Card(
                  color: widget.bgColor,
                  elevation: widget.elevation,
                  child: Container(
                    padding: widget.contentPadding,
                    decoration: BoxDecoration(
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(10)),
                    child: widget.content,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}

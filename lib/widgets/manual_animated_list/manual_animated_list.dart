import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:password_manager/widgets/manual_animated_list/manual_list_controller.dart';

class ManualAnimatedList<T extends Widget> extends ListBase<Widget>
    with AnimateManager<ManualAnimatedList> {
  static const Duration defaultInterval = Duration.zero;

  late final ManualListController controller;

  final List<Widget> _widgets = [];
  final List<Animate> _managers = [];

  List<AnimationController> get _controllers => controller.controllers;

  ManualAnimatedList({
    required List<Widget> children,
    required ManualListController listController,
    List<Effect>? effects,
    AnimateCallback? onInit,
    AnimateCallback? onPlay,
    AnimateCallback? onComplete,
    bool? autoPlay,
    Duration? delay,
    Duration? interval,
  })  : assert(listController.controllers.length == children.length),
        controller = listController {
    if (interval != null) controller.interval = interval;
    if (delay != null) controller.delay = delay;

    for (int i = 0; i < children.length; i++) {
      final Widget child = Animate(
        controller: _controllers[i],
        onInit: onInit,
        onPlay: onPlay,
        onComplete: onComplete,
        autoPlay: autoPlay,
        // delay: (delay ?? Duration.zero) + (interval ?? Duration.zero) * i,
        child: children[i],
      );
      _managers.add(child as Animate);
      _widgets.add(child);
    }
    if (effects != null) addEffects(effects);
  }

  @override
  ManualAnimatedList addEffect(Effect effect) {
    for (Animate manager in _managers) {
      manager.addEffect(effect);
    }
    return this;
  }

  // concrete implementations required when extending ListBase:
  @override
  set length(int length) {
    _widgets.length = length;
  }

  @override
  int get length => _widgets.length;

  @override
  Widget operator [](int index) => _widgets[index];

  @override
  void operator []=(int index, Widget value) {
    _widgets[index] = value;
  }
}

import 'package:flutter/material.dart';

class ManualListController {
  final List<AnimationController> controllers;
  Duration interval;
  Duration delay;

  ManualListController(
      {required this.controllers, this.interval = Duration.zero, this.delay = Duration.zero});

  /// Runs the animation of all the controllers from the [from] value.
  /// Returns the [TickerFuture] of the last controller.
  Future<TickerFuture> forward({double? from}) async {
    for (int i = 0; i < controllers.length - 1; i++) {
      Future.delayed(delay + interval * i, () => controllers[i].forward(from: from));
    }
    // for (final c in controllers.sublist(0, controllers.length - 1)) {
    //   c.forward(from: from);
    // }
    return Future.delayed(delay + interval * (controllers.length - 1),
        () => controllers.last.forward(from: from));
  }

  bool isAnimating() => controllers.last.isAnimating;

  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
  }
}

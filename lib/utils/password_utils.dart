import 'package:flutter/material.dart';

enum PasswordStrength {
  very_weak,
  weak,
  ok,
  good,
  strong,
}

extension PasswordStrengthUtils on PasswordStrength {
  String stringFormat() {
    return this.name.replaceAll("_", " ").toUpperCase();
  }

  Color? toColor() => _strengthToColor[this];
}

final Map<PasswordStrength, Color> _strengthToColor = {
  PasswordStrength.very_weak: Colors.red,
  PasswordStrength.weak: Colors.deepOrangeAccent,
  PasswordStrength.ok: Colors.orange,
  PasswordStrength.good: Colors.lightGreen,
  PasswordStrength.strong: Colors.green,
};

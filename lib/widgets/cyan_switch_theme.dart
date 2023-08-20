import 'package:flutter/material.dart';

class CyanSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;

  const CyanSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: Colors.teal[400],
      focusColor: Colors.teal[400],
      hoverColor: Colors.teal[400],
      inactiveThumbColor: Colors.blueGrey.shade400,
      activeColor: Colors.white,
      overlayColor: MaterialStateProperty.all(Colors.teal.withOpacity(.25)),
      trackOutlineColor: MaterialStateProperty.all(const Color(0xFF6FA7A3).withOpacity(.7)),
    );
  }
}

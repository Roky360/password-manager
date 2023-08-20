import 'package:flutter/material.dart';

class ActionBadge extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback? onTap;
  final Color fillColor;
  final Color borderColor;

  final double borderRadius = 30;

  const ActionBadge({
    Key? key,
    required this.name,
    required this.icon,
    this.onTap,
    required this.fillColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: borderColor.withOpacity(.6),
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: Center(
                child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(name),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

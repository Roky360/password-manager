import 'package:flutter/material.dart';

class ConnectionBadge extends StatelessWidget {
  final bool isOnline;

  const ConnectionBadge({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline ? Colors.greenAccent : Colors.redAccent,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        isOnline ? "ONLINE" : "OFFLINE",
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

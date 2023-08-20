import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  const CustomDropdownButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_alt),
      itemBuilder: (context) {
        return [
          CheckedPopupMenuItem(
            checked: true,
            child: Text("dsadasd"),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            enabled: false,
            height: 0,
            child: const Text("data")
          ),
          PopupMenuItem(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text("data")
              ],
            ),
          ),
        ];
      },
    );
  }
}

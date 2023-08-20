import 'package:flutter/material.dart';
import 'package:password_manager/screens/passwords_screen/widgets/service_entry.dart';

import '../../../passwords/passwords_repository/service.dart';

class PasswordsServiceListView extends StatelessWidget {
  final List<Service> services;

  const PasswordsServiceListView(this.services, {super.key});

  @override
  Widget build(BuildContext context) {
    // sort the services so the favorites are first, then sort by ABC.
    services.sort((a, b) => a.compareTo(b));
    return ListView(
      shrinkWrap: true,
      children: List.generate(
          services.length,
          (index) => ServiceEntry(
                services[index],
                independent: true,
              ))
        ..add(const SizedBox(height: 50)),
    );
  }
}

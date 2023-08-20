import 'package:flutter/material.dart';

import '../../../passwords/passwords_repository/category.dart';
import '../../../passwords/passwords_repository/service.dart';
import '../widgets/category_dropdown.dart';

class PasswordsCategoryView extends StatelessWidget {
  final List<Category> categories;
  final List<Service> services;

  const PasswordsCategoryView({super.key, required this.categories, required this.services});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: List.generate(
          categories.length,
          (index) => CategoryDropdown(
              categories[index],
              services
                  .where((element) => element.categoryId == categories[index].id)
                  .toList(growable: false)
                ..sort((a, b) => a.compareTo(b))))
        ..add(const SizedBox(height: 50)),
    );
  }
}

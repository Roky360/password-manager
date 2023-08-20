import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/passwords/bloc/passwords_bloc.dart';
import 'package:password_manager/passwords/passwords_repository/passwords_repository.dart';
import 'package:password_manager/passwords/passwords_service.dart';
import 'package:sizer/sizer.dart';

import '../passwords/passwords_repository/category.dart';

class Dialogs {
  /// Confirm overriding existing password with generated one
  static Future<bool> showOverridePasswordDialog(BuildContext context) async {
    final bool res = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: const Text(
                      "The password entry is not empty. Are you sure you want to override the existing password with a generated one?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("No"),
                    ),
                  ],
                )) ??
        false;

    return res;
  }

  static Future<Category> showChooseCategoryDialog(BuildContext context,
      {Category? initialCategory}) async {
    PasswordsRepository passwordsRepository = PasswordsRepository();
    List<Category> categories = List.from(passwordsRepository.categories)
      ..insert(0, Category.noneCategory);
    Category selected = initialCategory ?? Category.noneCategory;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          // title: const Text("Choose category"),
          contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  categories.length,
                  (index) => ListTile(
                        leading: Icon(
                            categories[index] == Category.noneCategory
                                ? Icons.circle_outlined
                                : Icons.circle,
                            color: categories[index].color.toMaterialColor()),
                        title: Text(
                          categories[index].name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () {
                          setState(() => selected = categories[index]);
                          Navigator.of(context).pop();
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      )),
            ),
          )),
    );

    return selected;
  }

  /// if [Category] instance is returned, that's the updated category.
  /// if null is returned, no changes should be made
  static Future<Category?> showEditCategoryDialog(BuildContext context,
      {required Category category, bool createNew = false}) async {
    final PasswordsBloc passwordsBloc = context.read<PasswordsBloc>();
    final TextEditingController nameController = TextEditingController()..text = category.name;
    CategoryColors color = category.color;

    final formKey = GlobalKey<FormState>();

    final bool? save = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            validator: (value) {
              if (value != null && value.isNotEmpty && !RegExp(r"^\s*$").hasMatch(value)) {
                return null;
              }
              return "Category name is required";
            },
            autofocus: true,
            decoration: const InputDecoration(labelText: "Category name"),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text("COLOR",
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            StatefulBuilder(
              builder: (context, setState) => Wrap(
                children: List.generate(
                    CategoryColors.values.length,
                    (index) => IconButton(
                          onPressed: () => setState(() => color = CategoryColors.values[index]),
                          isSelected: CategoryColors.values[index] == color,
                          color: CategoryColors.values[index].toMaterialColor(),
                          icon: const Icon(Icons.circle),
                          selectedIcon: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black), shape: BoxShape.circle),
                            child: const Icon(Icons.circle),
                          ),
                        )),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    if (save != null && save) {
      category.name = nameController.text.trim();
      category.color = color;

      if (createNew) {
        passwordsBloc.add(CreateCategoryEvent(category));
      } else {
        passwordsBloc.add(UpdateCategoryEvent(category));
      }

      return category;
    }
    return null;
  }

  /// returns if the category has been deleted
  static Future<bool> showDeleteCategoryDialog(
      BuildContext context, String categoryId, bool hasChildren) async {
    final PasswordsBloc passwordsBloc = context.read<PasswordsBloc>();

    if (hasChildren) {
      final action = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Delete category"),
                content: const Text(
                    "Choose whether to keep the services under this category or to delete them all. "
                    "Keeping the services will make them under no category."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop("keep"),
                    child: const Text("Keep"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop("delete"),
                    child: const Text("Delete"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop("cancel"),
                    child: const Text("Cancel"),
                  ),
                ],
              ));

      if (action != null && action != "cancel") {
        passwordsBloc.add(DeleteCategoryEvent(categoryId, action == "keep"));
        return true;
      }
      return false;
    } else {
      final action = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                // title: const Text("Delete this category?"),
                content: const Text("Delete this category?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Delete"),
                  ),
                ],
              ));
      if (action != null && action) {
        passwordsBloc.add(DeleteCategoryEvent(categoryId, false));
        return true;
      }
      return false;
    }
  }

  static Future<bool> showDeleteServiceConfirmationDialog(BuildContext context) async {
    final bool? res = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: const Text("Delete this service?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Yes",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
              ],
            ));
    return res ?? false;
  }

  static Future<bool> showWeakPasswordDialog(BuildContext context) async {
    final bool? res = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content:
                  const Text("Your password is pretty weak. Are you sure you want to proceed?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Yes",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
              ],
            ));
    return res ?? false;
  }
}

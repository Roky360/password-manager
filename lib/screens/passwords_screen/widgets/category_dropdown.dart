import 'package:flutter/material.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/screens/edit_service_screen.dart';
import 'package:password_manager/screens/passwords_screen/widgets/service_entry.dart';
import 'package:password_manager/widgets/dialogs.dart';

import '../../../passwords/passwords_repository/service.dart';

class CategoryDropdown extends StatelessWidget {
  final Category category;
  final List<Service> services;

  CategoryDropdown(this.category, this.services, {super.key});

  final ExpansionTileController tileController = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: category.color.toMaterialColor()!.withOpacity(.1),
      elevation: 0,
      child: ExpansionTile(
        controller: tileController,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          category.name,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: category.color.toMaterialColor()),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditServiceScreen(
                        Service("", "", "", categoryId: category.id),
                        createNew: true,
                      ))),
              icon: const Icon(Icons.add),
              tooltip: "Add to this category",
            ),
            IconButton(
              onPressed: () => Dialogs.showEditCategoryDialog(context, category: category),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () =>
                  Dialogs.showDeleteCategoryDialog(context, category.id, services.isNotEmpty),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        subtitle: Text("${services.length} password${services.length == 1 ? "" : "s"}"),
        children: List.generate(services.length, (index) => ServiceEntry(services[index]))
          ..add(const SizedBox(height: 20)),
      ),
    );
  }
}

// class CategoryDropdown extends StatefulWidget {
//   final Category category;
//   final List<Service> services;
//
//   const CategoryDropdown(this.category, this.services, {super.key});
//
//   @override
//   State<CategoryDropdown> createState() => _CategoryDropdownState();
// }
//
// class _CategoryDropdownState extends State<CategoryDropdown> {
//   late final Category category;
//   late final List<Service> services;
//   final ExpansionTileController tileController = ExpansionTileController();
//
//   double turns = 0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     category = widget.category;
//     services = widget.services;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       clipBehavior: Clip.antiAlias,
//       color: category.color.toMaterialColor()!.withOpacity(.1),
//       elevation: 0,
//       child: ExpansionTile(
//         controller: tileController,
//         onExpansionChanged: (expanded) {
//           setState(() {
//             turns = expanded ? .25 : 0;
//           });
//         },
//         leading: AnimatedRotation(
//           turns: turns,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOutQuart,
//           child: Icon(Icons.keyboard_arrow_right, color: category.color.toMaterialColor()),
//         ),
//         title: Text(
//           category.name,
//           style: Theme.of(context)
//               .textTheme
//               .titleMedium
//               ?.copyWith(color: category.color.toMaterialColor()),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         trailing: IconButton(
//           onPressed: () async {
//             await Dialogs.showEditCategoryDialog(context, category: category);
//             setState(() {});
//           },
//           icon: const Icon(Icons.edit),
//         ),
//         subtitle: Text("${services.length} password${services.length == 1 ? "" : "s"}"),
//         children: List.generate(services.length, (index) => ServiceEntry(services[index]))
//           ..add(const SizedBox(height: 20)),
//       ),
//     );
//   }
// }

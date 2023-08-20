import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../passwords/passwords_repository/category.dart';
import '../../passwords/passwords_repository/service.dart';
import '../../passwords/passwords_service.dart';

enum FilterGate {
  and,
  or,
}

class SearchFilter {
  static const String favoritesFilterId = "favorites";
  static const String sensitivesFilterId = "sensitives";

  static final SearchFilter _favoritesFilter = SearchFilter(favoritesFilterId, (s) => s.isFavorite);
  static final SearchFilter _sensitivesFilter =
      SearchFilter(sensitivesFilterId, (s) => s.isSensitive);

  static SearchFilter get favoritesFilter => _favoritesFilter;

  static SearchFilter get sensitivesFilter => _sensitivesFilter;

  /* non static fields */
  final String id;
  final bool Function(Service) test;
  final FilterGate gate;

  SearchFilter(this.id, this.test, {this.gate = FilterGate.and});

  SearchFilter.hasCategory(String categoryId)
      : this(categoryId, (s) => s.categoryId == categoryId, gate: FilterGate.or);

  /* Filters Dialog */
  static Future<List<SearchFilter>> showSearchFiltersDialog(
      BuildContext context, List<SearchFilter> filters) async {
    final List<Category> categories = List.of(PasswordsService().categories)
      ..insert(0, Category.noneCategory);
    final List<SearchFilter> newFilters = List.of(filters);

    const EdgeInsets tilePadding = EdgeInsets.symmetric(horizontal: 24);

    await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                titlePadding: const EdgeInsets.only(top: 18, left: 24, right: 24),
                contentPadding: const EdgeInsets.only(top: 16),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                title: Row(
                  children: [
                    const Text("Filters"),
                    const Spacer(),
                    TextButton(
                        onPressed: () => setState(() => newFilters.clear()),
                        child: const Text("Reset")),
                  ],
                ),
                content: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 50.h),
                  child: ListView(
                    children: [
                      CheckboxListTile(
                        value: newFilters.any((element) => element.id == favoritesFilterId),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: tilePadding,
                        fillColor: MaterialStateProperty.all(Colors.redAccent),
                        onChanged: (value) {
                          if (value != null) {
                            if (value) {
                              newFilters.add(favoritesFilter);
                            } else {
                              newFilters.remove(favoritesFilter);
                            }
                          }
                          setState(() {});
                        },
                        title: Text(
                          "Favorites",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      CheckboxListTile(
                        value: newFilters.any((element) => element.id == sensitivesFilterId),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: tilePadding,
                        fillColor: MaterialStateProperty.all(Colors.redAccent),
                        onChanged: (value) {
                          if (value != null) {
                            if (value) {
                              newFilters.add(sensitivesFilter);
                            } else {
                              newFilters.remove(sensitivesFilter);
                            }
                          }
                          setState(() {});
                        },
                        title: Text(
                          "Sensitives",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: tilePadding.copyWith(top: 4, bottom: 4),
                        child: const Text("From categories:"),
                      ),
                      ...List.generate(
                          categories.length,
                          (i) => CheckboxListTile(
                                value: newFilters.any((element) => element.id == categories[i].id),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: tilePadding,
                                fillColor: MaterialStateProperty.all(
                                    categories[i].color.toMaterialColor()),
                                onChanged: (value) {
                                  if (value != null) {
                                    if (value) {
                                      newFilters.add(SearchFilter.hasCategory(categories[i].id));
                                    } else {
                                      newFilters
                                          .removeWhere((element) => element.id == categories[i].id);
                                    }
                                  }
                                  setState(() {});
                                },
                                title: Text(
                                  categories[i].name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              )),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("close"),
                  ),
                ],
              ),
            ));

    return newFilters;
  }
}

extension GroupTesting on List<SearchFilter> {
  bool testOn(Service service) {
    bool passAndGate = true;
    bool orGatesExist = false;
    bool passOrGate = false;

    forEach((f) {
      final pass = f.test(service);
      if (f.gate == FilterGate.or) {
        if (!orGatesExist) {
          orGatesExist = true;
        }
        passOrGate = !passOrGate ? pass : passOrGate;
      } else if (!pass) {
        passAndGate = false;
      }
    });

    return passAndGate && (!orGatesExist || passOrGate);
  }
}

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/passwords/passwords_service.dart';
import 'package:password_manager/screens/passwords_screen/widgets/service_entry.dart';
import 'package:password_manager/screens/search_screen/search_filters.dart';
import 'package:password_manager/widgets/cyan_switch_theme.dart';

import '../../passwords/passwords_repository/service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PasswordsService passwordsService = PasswordsService();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchBarFocusNode = FocusNode();
  late List<Service> searchResults;
  late bool isExtendedSearch;
  late List<SearchFilter> filters;

  void updateSearch(String val) {
    val = val.trim().toLowerCase();
    // check search query
    if (val.isEmpty) {
      if (filters.isEmpty) {
        searchResults = [];
      } else {
        searchResults = List.of(passwordsService.services);
      }
    } else {
      if (isExtendedSearch) {
        searchResults = passwordsService.services
            .where((e) =>
                e.name.toLowerCase().contains(val) ||
                (e.category != null && e.category!.name.toLowerCase().contains(val)) ||
                e.username.toLowerCase().contains(val) ||
                e.additionalInfo.toLowerCase().contains(val))
            .toList();
      } else {
        searchResults = passwordsService.services
            .where((e) =>
                e.name.toLowerCase().contains(val) ||
                (e.category != null && e.category!.name.toLowerCase().contains(val)))
            .toList();
      }
    }

    // check filters
    final List<Service> toRemove = [];
    for (final Service s in searchResults) {
      if (!filters.testOn(s)) {
        toRemove.add(s);
      }
    }
    for (final s in toRemove) {
      searchResults.remove(s);
    }

    setState(() => searchResults.sort((a, b) => a.compareTo(b)));
  }

  void toggleExtendedSearch(bool newVal) {
    isExtendedSearch = newVal;
    updateSearch(searchController.text);
  }

  Widget getFiltersDropdown() {
    return DropdownButton(
      icon: const Icon(Icons.filter_alt),
      items: [
        DropdownMenuItem(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              const Text("Sensitives"),
            ],
          ),
        )
      ],
      onChanged: (value) {},
    );
  }

  @override
  void initState() {
    super.initState();

    searchResults = List.empty();
    isExtendedSearch = false;
    filters = List.empty();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(
        const Duration(milliseconds: 300),
        () => searchBarFocusNode.requestFocus(),
      );
    });

    Animate.restartOnHotReload = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        leadingWidth: 0,
        title: Hero(
          tag: "search_bar",
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            margin: EdgeInsets.zero,
            child: TextField(
              controller: searchController,
              focusNode: searchBarFocusNode,
              decoration: InputDecoration(
                  hintText: "Search anything",
                  isDense: true,
                  prefixIcon: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back)),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.text = "";
                            updateSearch("");
                          },
                          icon: const Icon(Icons.close))
                      : const SizedBox()),
              onChanged: updateSearch,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // options bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pageMargin),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    filters = await SearchFilter.showSearchFiltersDialog(context, filters);
                    updateSearch(searchController.text);
                    if (filters.isNotEmpty) {
                      WidgetsBinding.instance
                          .addPostFrameCallback((timeStamp) => searchBarFocusNode.unfocus());
                    }
                  },
                  tooltip: "Filters",
                  icon: const Icon(Icons.filter_alt),
                ),
                const SizedBox(height: 20, child: VerticalDivider()),
                GestureDetector(
                  onTap: () => toggleExtendedSearch(!isExtendedSearch),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CyanSwitch(
                        value: isExtendedSearch,
                        onChanged: (value) => toggleExtendedSearch(value),
                      ),
                      const SizedBox(width: 6),
                      const Text("Extended search"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // results
          Expanded(
            child: ImplicitlyAnimatedList<Service>(
              items: searchResults,
              areItemsTheSame: (oldItem, newItem) => oldItem.id == newItem.id,
              removeItemBuilder: (context, animation, item) => FadeTransition(
                opacity: animation,
                child: ServiceEntry(item, independent: true),
              ),
              itemBuilder: (context, animation, item, i) {
                if (i >= searchResults.length || i < 0) {
                  return const SizedBox();
                }
                return SizeFadeTransition(
                  sizeFraction: 0.7,
                  curve: Curves.easeInOut,
                  animation: animation,
                  child: ServiceEntry(searchResults[i],
                      independent: true, markText: searchController.text),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

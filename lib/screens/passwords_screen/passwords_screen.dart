import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/connectiviry/bloc/connectivity_bloc.dart';
import 'package:password_manager/connectiviry/connectivity_service.dart';
import 'package:password_manager/passwords/bloc/passwords_bloc.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/passwords/passwords_repository/service.dart';
import 'package:password_manager/passwords/passwords_service.dart';
import 'package:password_manager/screens/edit_service_screen.dart';
import 'package:password_manager/screens/passwords_screen/views/category_view.dart';
import 'package:password_manager/screens/passwords_screen/views/service_list_view.dart';
import 'package:password_manager/screens/passwords_screen/widgets/connection_badge.dart';
import 'package:password_manager/screens/search_screen/search_screen.dart';
import 'package:password_manager/screens/settings_screen/global_settings_service.dart';
import 'package:password_manager/widgets/dialogs.dart';
import 'package:sizer/sizer.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  final ConnectivityService connectivityService = ConnectivityService();
  final PasswordsService passwordsService = PasswordsService();
  late final PasswordsBloc passwordsBloc;
  late final ConnectivityBloc connectivityBloc;

  final EdgeInsets _iconsPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
  late final List<Widget> modesIcons;
  late List<bool> modesSelections;
  late final List<VoidCallback> modesCallbacks;
  late int prevIdx;

  void changeDisplayMode(int idx, {bool callSetState = true}) {
    modesSelections[prevIdx] = false;
    modesSelections[idx] = true;
    modesCallbacks[idx]();
    prevIdx = idx;

    if (callSetState) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    passwordsBloc = context.read<PasswordsBloc>();
    connectivityBloc = context.read<ConnectivityBloc>();
    modesIcons = [
      Padding(padding: _iconsPadding, child: const Icon(Icons.view_agenda_outlined)),
      Padding(padding: _iconsPadding, child: const Icon(Icons.list)),
    ];
    modesCallbacks = [
      () => passwordsBloc.add(LoadCategoriesEvent()),
      () => passwordsBloc.add(LoadServicesEvent()),
    ];
    modesSelections = List.generate(modesCallbacks.length, (index) => false, growable: false);
    prevIdx = 0;

    changeDisplayMode(1, callSetState: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Passwords"),
        centerTitle: true,
        actions: [
          Visibility(
            visible: GlobalSettingsService().getSetting(GlobalSettingsService.showConnectionStatus)
                as bool,
            child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
              bloc: connectivityBloc,
              builder: (context, state) => ConnectionBadge(isOnline: state is OnlineState),
            ),
          ),
          SizedBox(width: pageMargin),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pageMargin / 2, vertical: 10),
            child: SizedBox(
              width: 100.w,
              child: Hero(
                tag: "search_bar",
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.blueGrey.shade100)),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 12),
                          Text("Search anything",
                              style: Theme.of(context).inputDecorationTheme.hintStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pageMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Dialogs.showEditCategoryDialog(context,
                        category: Category.empty.copyWith(), createNew: true),
                    child: const Text("+  Category")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditServiceScreen(
                                Service.empty,
                                createNew: true,
                              )));
                    },
                    child: const Text("+  Service")),
                const SizedBox(height: 20, child: VerticalDivider()),
                ToggleButtons(
                  isSelected: modesSelections,
                  constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  onPressed: (index) {
                    if (index != prevIdx) {
                      changeDisplayMode(index);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  children: modesIcons,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(height: 0),
          ),

          // content
          BlocListener<ConnectivityBloc, ConnectivityState>(
            bloc: connectivityBloc,
            listener: (context, state) {
              if (state is OnlineState) {
                changeDisplayMode(prevIdx);
              }
            },
            child: BlocBuilder<PasswordsBloc, PasswordsState>(
              builder: (context, state) {
                // category view
                if (state is OnlineCategoriesLoadedState) {
                  return StreamBuilder<List<Category>>(
                      stream: state.categoriesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final List<Category> categories = snapshot.data!;
                          return Expanded(
                            child: PasswordsCategoryView(
                                categories: categories, services: passwordsService.services),
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      });
                } else if (state is CachedCategoriesLoadedState) {
                  final List<Category> categories = state.categories;
                  return Expanded(
                    child: PasswordsCategoryView(
                        categories: categories, services: passwordsService.services),
                  );

                  // service list view
                } else if (state is OnlineServicesLoadedState) {
                  return StreamBuilder<List<Service>>(
                    stream: state.servicesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<Service> services = snapshot.data!;
                        return Expanded(
                          child: PasswordsServiceListView(services),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                } else if (state is CachedServicesLoadedState) {
                  return Expanded(child: PasswordsServiceListView(state.services));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

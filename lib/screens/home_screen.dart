import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/connectiviry/bloc/connectivity_bloc.dart';
import 'package:password_manager/connectiviry/connectivity_service.dart';
import 'package:password_manager/passwords/bloc/passwords_bloc.dart';
import 'package:password_manager/screens/passwords_factory/passwords_factory_screen.dart';
import 'package:password_manager/screens/passwords_screen/passwords_screen.dart';
import 'package:password_manager/screens/settings_screen/settings_screen.dart';

import '../widgets/animated_snackbar/animated_snackbar.dart';
import '../widgets/animated_snackbar/animated_snackbar_messenger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConnectivityService connectivityService = ConnectivityService();

  late int tabIdx;
  late final List<Widget> tabs;

  @override
  void initState() {
    super.initState();

    tabIdx = 0;
    tabs = [
      const PasswordsScreen(),
      const PasswordsFactoryScreen(),
      SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PasswordsBloc, PasswordsState>(
          listener: (context, state) {
            if (state is PasswordsErrorState) {
              AnimatedSnackBarMessenger.showSnackBar(
                  context,
                  AnimatedSnackBar(
                    content: Text(state.message),
                  ));
            }
          },
        ),
        BlocListener<ConnectivityBloc, ConnectivityState>(
          listener: (context, state) {
            if (state is OnlineState) {
              connectivityService.showOnlineSnackBar(context);
            } else if (state is OfflineState) {
              connectivityService.showOfflineSnackBar(context);
            }
          },
        ),
      ],
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: tabs[tabIdx],
        ),
        bottomNavigationBar: NavigationBar(
          indicatorColor: Colors.tealAccent,
          selectedIndex: tabIdx,
          height: 80 - 14,
          onDestinationSelected: (value) {
            setState(() {
              tabIdx = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.password_outlined),
              selectedIcon: Icon(Icons.password),
              label: "Services",
            ),
            NavigationDestination(
              icon: Icon(Icons.factory_outlined),
              selectedIcon: Icon(Icons.factory),
              label: "Factory",
              tooltip: "Passwords factory",
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/screens/settings_screen/global_settings_service.dart';
import 'package:password_manager/screens/settings_screen/widgets/setting_tile.dart';

import '../google_auth/bloc/google_auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final GlobalSettingsService settingsService = GlobalSettingsService();

  PackageInfo get info => settingsService.packageInfo!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<GoogleAuthBloc>().add(GoogleSignOutEvent()),
            color: Colors.red,
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Log out from Google",
          ),
        ],
      ),
      body: ListView(
        children: settingsService.allSettingsKeys
            .map((k) => BoolSettingTile(name: k, value: settingsService.getSetting(k) as bool))
            .toList(),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: pageMargin, vertical: 6),
        child: Text("${info.appName} ${info.version} • build ${info.buildNumber}"),
      ),
    );
  }
}

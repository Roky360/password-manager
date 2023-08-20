import 'package:flutter/material.dart';
import 'package:password_manager/screens/settings_screen/global_settings_service.dart';
import 'package:password_manager/widgets/cyan_switch_theme.dart';

class BoolSettingTile extends StatefulWidget {
  final String name;
  final bool value;

  const BoolSettingTile({super.key, required this.name, required this.value});

  @override
  State<BoolSettingTile> createState() => _BoolSettingTileState();
}

class _BoolSettingTileState extends State<BoolSettingTile> {
  final GlobalSettingsService settingsService = GlobalSettingsService();
  late final String name;
  late bool value;

  void toggleSetting(bool value) async {
    await settingsService.setSetting(name, value);
    setState(() => this.value = value);
  }

  @override
  void initState() {
    super.initState();

    name = widget.name;
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        settingsService.formatSettingName(name),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: CyanSwitch(
        value: value,
        onChanged: toggleSetting,
      ),
      onTap: () => toggleSetting(!value),
    );
  }
}

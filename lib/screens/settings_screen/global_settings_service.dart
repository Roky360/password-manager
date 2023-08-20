import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettingsService {
  static final GlobalSettingsService _globalSettingsService = GlobalSettingsService._();

  GlobalSettingsService._();

  factory GlobalSettingsService() => _globalSettingsService;

  /* Settings Keys */
  static const _firstLaunchFlagKey = "IS_FIRST_LAUNCH";
  static const _forceOverrideWithDefaultSettings = false;
  static const _prefix = "set-";

  // Settings
  static const useAnimations = "${_prefix}use_animations";
  static const showConnectionStatus = "${_prefix}show_connection_status";
  static const copyPasswordOnServiceCreation = "${_prefix}copy_password_when_creating_service";

  final Map<String, Object?> _settings = {};
  final Map<String, Object> _defaultSettings = {
    useAnimations: true,
    showConnectionStatus: false,
    copyPasswordOnServiceCreation: false,
  };

  PackageInfo? packageInfo;

  Future<PackageInfo> getPackageInfo() async => packageInfo = await PackageInfo.fromPlatform();

  Future<SharedPreferences> get sharedPref async => await SharedPreferences.getInstance();

  int get numOfSettings => _settings.length;

  List<String> get allSettingsKeys => _settings.keys.toList(growable: false);

  String formatSettingName(String key) {
    return key.replaceFirst(_prefix, "").splitMapJoin("_",
        onMatch: (s) => " ",
        onNonMatch: (s) => "${s[0].toUpperCase()}${s.substring(1).toLowerCase()}");
  }

  Future<void> initGlobalSettings() async {
    final SharedPreferences pref = await sharedPref;

    final bool? isFirstLaunch = pref.getBool(_firstLaunchFlagKey);
    if (isFirstLaunch == null || isFirstLaunch || _forceOverrideWithDefaultSettings) {
      // first launch - set default settings
      pref.setBool(_firstLaunchFlagKey, false);

      _defaultSettings.forEach((key, value) {
        setSetting(key, value);
      });
    } else {
      // not first launch - load settings
      final keys = pref.getKeys().where((e) => e.startsWith(_prefix)).toList(growable: false);
      for (final key in keys) {
        _settings[key] = pref.get(key);
      }
    }
  }

  dynamic getSetting(String key) {
    return _settings[key];
  }

  Future<void> setSetting(String key, dynamic value) async {
    _settings[key] = value;

    final SharedPreferences pref = await sharedPref;
    if (value is int) {
      pref.setInt(key, value);
    } else if (value is bool) {
      pref.setBool(key, value);
    } else if (value is double) {
      pref.setDouble(key, value);
    } else if (value is List<String>) {
      pref.setStringList(key, value);
    } else {
      pref.setString(key, value.toString());
    }
  }
}

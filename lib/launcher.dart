import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password_manager/connectiviry/connectivity_service.dart';
import 'package:password_manager/screens/device_auth/device_auth_manager.dart';
import 'package:password_manager/passwords/encryption_service/encryption_service.dart';
import 'package:password_manager/screens/settings_screen/global_settings_service.dart';
import 'package:password_manager/services/company_icon_provider.dart';

class AppLauncher extends StatelessWidget {
  final Widget Function(BuildContext) homeRoute;

  const AppLauncher({super.key, required this.homeRoute});

  Future<String> initializeCredentials() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final EncryptionService encryptionService = EncryptionService();
    final CompanyIconProvider companyIconProvider = CompanyIconProvider();
    const fetchErrorMessage =
        "In the first launch, the app must have an internet connection to fetch remote config.\n"
        "Check your connection and restart the app.";

    final FirebaseRemoteConfig remoteConfig =
        FirebaseRemoteConfig.instanceFor(app: Firebase.app("pass_mngr"));
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    try {
      await remoteConfig.fetchAndActivate();
      final aesKey = remoteConfig.getString("xX_TenBis_Xx");
      final clearbitKey = remoteConfig.getString("Xx_elevenBis_xX");
      if (aesKey.isEmpty || clearbitKey.isEmpty) throw Exception();
      await secureStorage.write(key: "hahaSyceeeee", value: aesKey);
      encryptionService.encryptionKey = aesKey;

      await secureStorage.write(key: "maMan11", value: aesKey);
      companyIconProvider.apiKey = clearbitKey;
    } catch (e) {
      // get local
      final localAes = await secureStorage.read(key: "hahaSyceeeee");
      final localClearbit = await secureStorage.read(key: "maMan11");
      if (localAes != null && localClearbit != null) {
        encryptionService.encryptionKey = localAes;
        companyIconProvider.apiKey = localClearbit;
      } else {
        return fetchErrorMessage;
      }
    }

    return "";
  }

  Future<void> initGlobalSettings() async => await GlobalSettingsService().initGlobalSettings();

  Future<void> initPackageInfo() async => await GlobalSettingsService().getPackageInfo();

  Future<void> checkConnection() async {
    final ConnectivityService connectivityService = ConnectivityService();
    connectivityService.isOnline = await connectivityService.checkConnectivity();
  }

  Future<String> initApp() async {
    final errorMsg = await initializeCredentials();
    if (errorMsg.isNotEmpty) return errorMsg;
    await initGlobalSettings();
    await initPackageInfo();
    await checkConnection();
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: initApp(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return Scaffold(body: Center(child: Text(snapshot.data!)));
          }
          return DeviceAuthManager(homeRoute: homeRoute);
        } else {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

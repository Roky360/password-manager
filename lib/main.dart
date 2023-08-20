import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:password_manager/config/style.dart';
import 'package:password_manager/connectiviry/bloc/connectivity_bloc.dart';
import 'package:password_manager/screens/device_auth/bloc/device_auth_bloc.dart';
import 'package:password_manager/screens/device_auth/device_auth_manager.dart';
import 'package:password_manager/launcher.dart';
import 'package:password_manager/passwords/bloc/passwords_bloc.dart';
import 'package:password_manager/screens/google_auth/bloc/google_auth_bloc.dart';
import 'package:password_manager/screens/home_screen.dart';
import 'package:password_manager/screens/passwords_factory/passwords_factory_screen.dart';
import 'package:password_manager/screens/passwords_screen/passwords_screen.dart';
import 'package:password_manager/widgets/animated_snackbar/bloc/animated_snackbar_bloc.dart';
import 'package:sizer/sizer.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: "pass_mngr", options: DefaultFirebaseOptions.android
      // options: DefaultFirebaseOptions.currentPlatform
      );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routeMap = {
      "/launcher": (context) => AppLauncher(homeRoute: (context) => const HomeScreen()),
      "/home": (context) => const PasswordsScreen(),
      "/auth": (context) => DeviceAuthManager(homeRoute: (context) => const PasswordsScreen()),
      "/factory": (context) => const PasswordsFactoryScreen(),
    };

    return Sizer(
      builder: (BuildContext context, Orientation orientation, DeviceType deviceType) =>
          MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => PasswordsBloc()),
          BlocProvider(create: (context) => DeviceAuthBloc()),
          BlocProvider(create: (context) => AnimatedSnackbarBloc()),
          BlocProvider(create: (context) => ConnectivityBloc()),
          BlocProvider(create: (context) => GoogleAuthBloc()),
        ],
        child: GlobalLoaderOverlay(
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 250),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Password Manager",
            theme: AppStyle.lightTheme,
            routes: routeMap,
            // initialRoute: "/add_service",
            initialRoute: "/launcher",
            // initialRoute: "/factory",
            // initialRoute: "/test",

            // home: const PasswordsScreen(),
          ),
        ),
      ),
    );
  }
}

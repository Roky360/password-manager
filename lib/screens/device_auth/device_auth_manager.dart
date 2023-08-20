import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/config/constants.dart';
import 'package:password_manager/screens/device_auth/bloc/device_auth_bloc.dart';
import 'package:password_manager/screens/google_auth/google_auth_screen.dart';

class DeviceAuthManager extends StatefulWidget {
  final Widget Function(BuildContext) homeRoute;

  const DeviceAuthManager({super.key, required this.homeRoute});

  @override
  State<DeviceAuthManager> createState() => _DeviceAuthManagerState();
}

class _DeviceAuthManagerState extends State<DeviceAuthManager> with WidgetsBindingObserver {
  late final DeviceAuthBloc deviceAuthBloc;

  // THIS is called whenever life cycle changed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      deviceAuthBloc.add(RequestAuthenticationEvent("Authenticate to access app contents"));
    }
  }

  @override
  void initState() {
    super.initState();

    deviceAuthBloc = context.read<DeviceAuthBloc>();

    if (kReleaseMode) {
      WidgetsBinding.instance.addObserver(this);
      deviceAuthBloc.add(RequestAuthenticationEvent("Authenticate to access app contents"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceAuthBloc, DeviceAuthState>(
      builder: (context, state) {
        if (!kReleaseMode) {
          // return widget.homeRoute(context);
          return GoogleAuthScreen(homeRoute: widget.homeRoute);
        }
        if (state is AuthSucceededState) {
          return GoogleAuthScreen(homeRoute: widget.homeRoute);
        } else if (state is AuthFailedState) {
          return AuthFailedScreen(state.message ?? "(no info)");
        } else {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

/// ********** Failed State Screen **********
class AuthFailedScreen extends StatefulWidget {
  final String errorMsg;

  const AuthFailedScreen(this.errorMsg, {super.key});

  @override
  State<AuthFailedScreen> createState() => _AuthFailedScreenState();
}

class _AuthFailedScreenState extends State<AuthFailedScreen> {
  late String errorMsg;

  @override
  void initState() {
    super.initState();
    errorMsg = widget.errorMsg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: pageMargin),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Auth Failed", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 30),
              Text(errorMsg),
              const SizedBox(height: 50),
              const Text(
                  "A device authentication is required in order to access the application.\n"
                  "If the device has no authentication method, please set-up one to use the app.",
                  textAlign: TextAlign.center),
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () => context
                      .read<DeviceAuthBloc>()
                      .add(RequestAuthenticationEvent("Authenticate to access app contents")),
                  child: const Text("Try again")),
            ],
          ),
        ),
      ),
    );
  }
}

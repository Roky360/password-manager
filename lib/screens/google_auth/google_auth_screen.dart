import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:password_manager/screens/google_auth/bloc/google_auth_bloc.dart';
import 'package:password_manager/screens/google_auth/google_sign_in_service.dart';
import 'package:password_manager/widgets/animated_snackbar/animated_snackbar_messenger.dart';

import '../../widgets/animated_snackbar/animated_snackbar.dart';

class GoogleAuthScreen extends StatefulWidget {
  final Widget Function(BuildContext) homeRoute;

  const GoogleAuthScreen({super.key, required this.homeRoute});

  @override
  State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  late final GoogleAuthBloc googleAuthBloc;

  @override
  void initState() {
    super.initState();

    googleAuthBloc = context.read<GoogleAuthBloc>();
    googleAuthBloc.add(GoogleSignInEvent(silent: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GoogleAuthBloc, GoogleAuthState>(
      bloc: googleAuthBloc,
      listener: (context, state) {
        if (state is GoogleSignInMessage) {
          AnimatedSnackBarMessenger.showSnackBar(
              context,
              AnimatedSnackBar(
                content: Text(state.message),
                alignment: Alignment.bottomCenter,
                delay: const Duration(seconds: 5),
              ));
        }
      },
      builder: (context, state) {
        if (state is GoogleSignedOutState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Google Auth"),
              centerTitle: true,
            ),
            body: Center(
              heightFactor: 10,
              child: OutlinedButton.icon(
                onPressed: () => googleAuthBloc.add(GoogleSignInEvent(silent: false)),
                icon: SvgPicture.asset("assets/logos/Google_G_Logo.svg", height: 18),
                label: const Text("Sign in with Google"),
              ),
            ),
          );
        } else if (state is GoogleSignedInState) {
          return widget.homeRoute(context);
        } else {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

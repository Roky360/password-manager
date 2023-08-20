import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:password_manager/connectiviry/bloc/connectivity_bloc.dart';

import '../widgets/animated_snackbar/animated_snackbar.dart';
import '../widgets/animated_snackbar/animated_snackbar_messenger.dart';

class ConnectivityService {
  static final ConnectivityService _connectivityService = ConnectivityService._();

  ConnectivityService._();

  factory ConnectivityService() => _connectivityService;

  /* ****** */
  final Connectivity _connectivity = Connectivity();
  /// Stores the current connection state; Manages by the [ConnectivityBloc].
  bool isOnline = true;

  Stream<ConnectivityResult> get onConnectivityChangedStream => _connectivity.onConnectivityChanged;

  bool isConnectedByResult(ConnectivityResult result) => [
        ConnectivityResult.ethernet,
        ConnectivityResult.mobile,
        ConnectivityResult.wifi,
        ConnectivityResult.vpn,
      ].contains(result);

  Future<bool> checkConnectivity() async {
    final res = await _connectivity.checkConnectivity();
    return isConnectedByResult(res);
  }

  /* SnackBars */

  void _showSnackBar(BuildContext context, List<Widget> children) {
    AnimatedSnackBarMessenger.showSnackBar(
        context,
        AnimatedSnackBar.bounce(
          heightFactor: .7,
          padding: EdgeInsets.zero,
          alignment: Alignment.bottomCenter,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ));
  }

  void showOnlineSnackBar(BuildContext context) {
    const color = Colors.green;
    _showSnackBar(context, [
      const Icon(Icons.info_outline, color: color),
      const SizedBox(width: 8),
      Text(
        "Back online!\n"
        "Showing live data.",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    ]);
  }

  void showOfflineSnackBar(BuildContext context) {
    const color = Colors.red;
    _showSnackBar(context, [
      const Icon(Icons.info_outline, color: color),
      const SizedBox(width: 8),
      Text(
        "Connection lost. Data may be outdated.\n"
        "Editing is not available while offline.",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    ]);
  }
}

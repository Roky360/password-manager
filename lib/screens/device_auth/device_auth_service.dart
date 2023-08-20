import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class DeviceAuthService {
  static final DeviceAuthService _deviceAuthService = DeviceAuthService._();

  DeviceAuthService._();

  factory DeviceAuthService() => _deviceAuthService;

  /* Fields */
  final LocalAuthentication auth = LocalAuthentication();

  Future<({bool success, String errorMsg})> requireAuthentication(String message) async {
    try {
      final bool res = await auth.authenticate(
        localizedReason: message,
        options: const AuthenticationOptions(),
      );
      return (success: res, errorMsg: !res ? "Authentication failed" : "");
    } on PlatformException catch (e) {
      return (
        success: false,
        errorMsg: (e.message == null || e.message!.isEmpty) ? "Authentication failed" : e.message!
      );
    }
  }
}

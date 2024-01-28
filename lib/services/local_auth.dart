import 'package:local_auth/local_auth.dart';

class LocalAuth {
  static final _auth = LocalAuthentication();
  static Future<bool> _canAuth() async =>
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    try {
      if (!await _canAuth()) return false;
      return await _auth.authenticate(
          localizedReason: 'Necesito su confirmación');
    } catch (e) {
      print(e);
      return false;
    }
  }
}

import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Storage keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  /// Check if device has biometric hardware
  static Future<bool> hasBiometricHardware() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      print('Error checking biometric hardware: $e');
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, iris)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if biometric login is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      print('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Enable biometric login and save credentials
  static Future<bool> enableBiometricLogin({
    required String email,
    required String password,
  }) async {
    try {
      // Save credentials securely
      await _secureStorage.write(key: _savedEmailKey, value: email);
      await _secureStorage.write(key: _savedPasswordKey, value: password);
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      return true;
    } catch (e) {
      print('Error enabling biometric login: $e');
      return false;
    }
  }

  /// Disable biometric login and clear saved credentials
  static Future<bool> disableBiometricLogin() async {
    try {
      await _secureStorage.delete(key: _savedEmailKey);
      await _secureStorage.delete(key: _savedPasswordKey);
      await _secureStorage.delete(key: _biometricEnabledKey);
      return true;
    } catch (e) {
      print('Error disabling biometric login: $e');
      return false;
    }
  }

  /// Authenticate with biometrics and return saved credentials
  static Future<Map<String, String>?> authenticateWithBiometrics() async {
    try {
      // Check if biometric is enabled
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return null;
      }

      // Check if hardware is available
      final hasHardware = await hasBiometricHardware();
      if (!hasHardware) {
        return null;
      }

      // Authenticate
      final authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        return null;
      }

      // Retrieve saved credentials
      final email = await _secureStorage.read(key: _savedEmailKey);
      final password = await _secureStorage.read(key: _savedPasswordKey);

      if (email == null || password == null) {
        return null;
      }

      return {
        'email': email,
        'password': password,
      };
    } catch (e) {
      print('Error authenticating with biometrics: $e');

      // Handle specific errors
      if (e is PlatformException) {
        switch (e.code) {
          case auth_error.notAvailable:
            print('Biometric authentication not available on this device');
            break;
          case auth_error.notEnrolled:
            print('No biometrics enrolled on this device');
            break;
          case auth_error.lockedOut:
            print('Biometric authentication is locked out');
            break;
          case auth_error.permanentlyLockedOut:
            print('Biometric authentication is permanently locked out');
            break;
          default:
            print('Biometric authentication error: ${e.message}');
        }
      }

      return null;
    }
  }

  /// Get saved email (without authentication)
  static Future<String?> getSavedEmail() async {
    try {
      return await _secureStorage.read(key: _savedEmailKey);
    } catch (e) {
      print('Error getting saved email: $e');
      return null;
    }
  }

  /// Get biometric type name for display
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      default:
        return 'Biometric';
    }
  }

  /// Get user-friendly message about available biometrics
  static Future<String> getBiometricMessage() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) {
      return 'No biometric authentication available';
    }

    if (biometrics.contains(BiometricType.face)) {
      return 'Login with Face Recognition';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Login with Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Login with Iris';
    } else {
      return 'Login with Biometric';
    }
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'api_service.dart';

// Replace with your Web Client ID from Google Cloud Console
// (APIs & Services → Credentials → OAuth 2.0 Client IDs → Web client)
const _kGoogleWebClientId = '184692010949-2vnfqds7tavkjrismm5f5bbgphm0lr3k.apps.googleusercontent.com';

class AuthService {
  /// Login with email and password
  static Future<AuthResult> login(String email, String password) async {
    final response = await ApiService.post(
      '/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );

    if (response.success && response.data != null) {
      final user = UserModel.fromJson(
        response.data['user'],
        token: response.data['token'],
      );

      // Store token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token ?? '');
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_role', user.role);

      return AuthResult(success: true, user: user, message: response.message);
    }

    return AuthResult(
      success: false,
      user: null,
      message: response.message.isNotEmpty
          ? response.message
          : 'Login failed. Please check your credentials.',
    );
  }

  /// Register a new user
  static Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await ApiService.post(
      '/auth/register',
      {'name': name, 'email': email, 'password': password},
      auth: false,
    );

    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data);
      return AuthResult(success: true, user: user, message: response.message);
    }

    return AuthResult(
      success: false,
      user: null,
      message: response.message.isNotEmpty
          ? response.message
          : 'Registration failed. Please try again.',
    );
  }

  /// Check if user is already logged in
  static Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final role = prefs.getString('user_role');

    if (token != null && userId != null && email != null && name != null) {
      return UserModel(
        id: userId,
        email: email,
        name: name,
        role: role ?? 'USER',
        token: token,
      );
    }
    return null;
  }

  /// Login with Google OAuth
  static Future<AuthResult> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: _kGoogleWebClientId,
      serverClientId: kIsWeb ? null : _kGoogleWebClientId,
    );
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        return AuthResult(success: false, user: null, message: 'Google sign-in cancelled');
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      if (idToken == null && accessToken == null) {
        return AuthResult(success: false, user: null, message: 'Failed to get Google token');
      }

      final Map<String, dynamic> body = idToken != null
          ? {'idToken': idToken}
          : {'accessToken': accessToken};

      final response = await ApiService.post(
        '/auth/google',
        body,
        auth: false,
      );

      if (response.success && response.data != null) {
        final user = UserModel.fromJson(
          response.data['user'],
          token: response.data['token'],
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', user.token ?? '');
        await prefs.setString('user_id', user.id);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_role', user.role);
        return AuthResult(success: true, user: user, message: response.message);
      }

      return AuthResult(
        success: false,
        user: null,
        message: response.message.isNotEmpty ? response.message : 'Google login failed',
      );
    } catch (e) {
      return AuthResult(success: false, user: null, message: 'Google sign-in error: $e');
    }
  }

  /// Logout — clear stored data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
  }
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String message;

  AuthResult({
    required this.success,
    required this.user,
    required this.message,
  });
}

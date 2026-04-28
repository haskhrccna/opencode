import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';

/// Abstract local datasource interface
abstract class AuthLocalDataSource {
  /// Cache auth token
  Future<void> cacheToken(String token);

  /// Get cached auth token
  Future<String?> getToken();

  /// Delete cached auth token
  Future<void> deleteToken();

  /// Cache refresh token
  Future<void> cacheRefreshToken(String token);

  /// Get cached refresh token
  Future<String?> getRefreshToken();

  /// Delete cached refresh token
  Future<void> deleteRefreshToken();

  /// Cache user data
  Future<void> cacheUserData(Map<String, dynamic> userData);

  /// Get cached user data
  Future<Map<String, dynamic>?> getUserData();

  /// Delete cached user data
  Future<void> deleteUserData();

  /// Cache user role
  Future<void> cacheUserRole(String role);

  /// Get cached user role
  Future<String?> getUserRole();

  /// Clear all cached auth data
  Future<void> clearAll();
}

/// Secure storage implementation of AuthLocalDataSource
class SecureStorageAuthDataSource implements AuthLocalDataSource {

  const SecureStorageAuthDataSource({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accountName: 'quran_tutor_auth',
          ),
        );
  final FlutterSecureStorage _storage;

  // Keys for secure storage
  static const String _tokenKey = AppConstants.authTokenKey;
  static const String _refreshTokenKey = AppConstants.refreshTokenKey;
  static const String _userDataKey = AppConstants.userDataKey;
  static const _userRoleKey = 'user_role';

  @override
  Future<void> cacheToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<void> cacheRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _storage.write(key: _userDataKey, value: jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await _storage.read(key: _userDataKey);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // If parsing fails, delete corrupted data
      await deleteUserData();
      return null;
    }
  }

  @override
  Future<void> deleteUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  @override
  Future<void> cacheUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  @override
  Future<String?> getUserRole() async {
    return _storage.read(key: _userRoleKey);
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

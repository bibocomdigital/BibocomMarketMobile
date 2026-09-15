import 'dart:convert';

import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/error/exceptions.dart';
import 'package:bibomarketmobile/core/storage/local_storage_service.dart';
import 'package:bibomarketmobile/core/storage/token_storage.dart';
import 'package:bibomarketmobile/features/auth/data/models/auth_response_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({
    required this._tokenStorage,
    required this._localStorage,
  });

  final TokenStorage _tokenStorage;
  final LocalStorageService _localStorage;

  Future<void> cacheSession(AuthResponseModel session) async {
    try {
      await _tokenStorage.saveAccessToken(session.token);
      await _localStorage.setString(
        StorageKeys.cachedUser,
        jsonEncode(session.user.toJson()),
      );
    } catch (_) {
      throw const CacheException();
    }
  }

  Future<AuthResponseModel?> readSession() async {
    try {
      final token = await _tokenStorage.readAccessToken();
      final rawUser = _localStorage.getString(StorageKeys.cachedUser);
      if (token == null || token.isEmpty || rawUser == null) return null;

      return AuthResponseModel.fromJson({
        'token': token,
        'user': jsonDecode(rawUser) as Map<String, dynamic>,
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _tokenStorage.clear();
    await _localStorage.remove(StorageKeys.cachedUser);
  }
}

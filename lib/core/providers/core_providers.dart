import 'package:bibomarketmobile/core/network/dio_client.dart';
import 'package:bibomarketmobile/core/storage/local_storage_service.dart';
import 'package:bibomarketmobile/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override sharedPreferencesProvider dans main.dart',
  );
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(ref.watch(tokenStorageProvider));
});

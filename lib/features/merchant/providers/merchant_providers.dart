import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/core/storage/local_storage_service.dart';
import 'package:bibomarketmobile/features/client/domain/client_models.dart'
    show AppNotification;
import 'package:bibomarketmobile/features/client/providers/client_providers.dart';
import 'package:bibomarketmobile/features/merchant/data/datasources/merchant_remote_datasource.dart';
import 'package:bibomarketmobile/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final merchantRemoteDataSourceProvider =
    Provider<MerchantRemoteDataSource>((ref) {
  return MerchantRemoteDataSource(ref.watch(dioProvider));
});

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MerchantRepositoryImpl(ref.watch(merchantRemoteDataSourceProvider));
});

final shopCategoriesProvider = FutureProvider<List<CatalogItem>>((ref) async {
  final result =
      await ref.watch(merchantRepositoryProvider).getShopCategories();
  return result.fold(
    failure: (failure) => throw Exception(failure.message),
    success: (data) => data,
  );
});

final productCategoriesProvider =
    FutureProvider<List<CatalogItem>>((ref) async {
  final result =
      await ref.watch(merchantRepositoryProvider).getProductCategories();
  return result.fold(
    failure: (failure) => throw Exception(failure.message),
    success: (data) => data,
  );
});

final merchantOverviewProvider =
    FutureProvider<ShopOverview>((ref) async {
  final result = await ref.watch(merchantRepositoryProvider).loadOverview();
  return result.fold(
    failure: (failure) => throw Exception(failure.message),
    success: (data) => data,
  );
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final result = await ref.watch(merchantRepositoryProvider).getConversations();
  return result.fold(
    failure: (failure) => throw Exception(failure.message),
    success: (data) => data,
  );
});

final messagesProvider =
    FutureProvider.family<List<ChatMessage>, int>((ref, partnerId) async {
  final result =
      await ref.watch(merchantRepositoryProvider).getMessages(partnerId);
  return result.fold(
    failure: (failure) => throw Exception(failure.message),
    success: (data) => data,
  );
});

final orderDetailProvider =
    FutureProvider.family<MerchantOrder, int>((ref, orderId) async {
  final result = await ref.watch(merchantRepositoryProvider).getOrder(orderId);
  return result.fold(
    failure: (failure) => throw Exception(failure.message),
    success: (data) => data,
  );
});

final merchantNotificationsProvider =
    FutureProvider<List<AppNotification>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).notifications();
  return result.fold(
    failure: (failure) => throw Exception(failure.message),
    success: (data) => data,
  );
});

class MerchantLocalPrefs {
  MerchantLocalPrefs(this._storage);

  final LocalStorageService _storage;

  bool flag(String key, {required bool fallback}) {
    final value = _storage.getString(key);
    if (value == null) return fallback;
    return value == '1' || value.toLowerCase() == 'true';
  }

  Future<void> setFlag(String key, bool value) {
    return _storage.setString(key, value ? '1' : '0');
  }

  String text(String key, String fallback) =>
      _storage.getString(key) ?? fallback;

  Future<void> setText(String key, String value) =>
      _storage.setString(key, value);

  bool get notifyOrders =>
      flag(StorageKeys.notifyOrders, fallback: true);
  bool get notifyMessages =>
      flag(StorageKeys.notifyMessages, fallback: true);
  bool get notifyReviews =>
      flag(StorageKeys.notifyReviews, fallback: true);
  bool get notifyPromo =>
      flag(StorageKeys.notifyPromo, fallback: false);
  bool get notifyEmail =>
      flag(StorageKeys.notifyEmail, fallback: true);
  bool get twoFactor =>
      flag(StorageKeys.twoFactorEnabled, fallback: false);

  String get language => text(StorageKeys.prefLanguage, 'Français');
  String get timezone =>
      text(StorageKeys.prefTimezone, 'Africa/Dakar (GMT+0)');
  String get dateFormat => text(StorageKeys.prefDateFormat, 'JJ/MM/AAAA');
  String get currency => text(StorageKeys.prefCurrency, 'FCFA');
}

final merchantLocalPrefsProvider = Provider<MerchantLocalPrefs>((ref) {
  return MerchantLocalPrefs(ref.watch(localStorageServiceProvider));
});

import 'package:bibomarketmobile/core/providers/core_providers.dart';
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

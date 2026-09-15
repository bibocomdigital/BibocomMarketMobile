import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/client/data/client_remote_datasource.dart';
import 'package:bibomarketmobile/features/client/data/client_repository.dart';
import 'package:bibomarketmobile/features/client/domain/client_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ClientRemoteDataSource(ref.watch(dioProvider)));
});

final featuredProductsProvider = FutureProvider<List<CatalogProduct>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).featured();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final latestProductsProvider = FutureProvider<List<CatalogProduct>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).latest();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final productCategoriesProvider = FutureProvider<List<ProductCategory>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).categories();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final shopsProvider = FutureProvider<List<ShopPreview>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).shops();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final cartProvider = FutureProvider<CartSummary>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).cart();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final clientOrdersProvider = FutureProvider<List<ClientOrder>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).orders();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).conversations();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final result = await ref.watch(clientRepositoryProvider).notifications();
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final productProvider = FutureProvider.family<CatalogProduct, int>((ref, id) async {
  final result = await ref.watch(clientRepositoryProvider).product(id);
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final shopDetailsProvider =
    FutureProvider.family<({ShopPreview shop, List<CatalogProduct> products}), int>(
  (ref, id) async {
    final result = await ref.watch(clientRepositoryProvider).shopDetails(id);
    return result.fold(failure: (failure) => throw failure, success: (data) => data);
  },
);

final orderProvider = FutureProvider.family<ClientOrder, int>((ref, id) async {
  final result = await ref.watch(clientRepositoryProvider).order(id);
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final threadProvider = FutureProvider.family<List<ChatMessage>, int>((ref, id) async {
  final result = await ref.watch(clientRepositoryProvider).thread(id);
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final productCommentsProvider = FutureProvider.family<List<ProductComment>, int>((ref, id) async {
  final result = await ref.watch(clientRepositoryProvider).comments(id);
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final followInfoProvider = FutureProvider.family<FollowInfo, int>((ref, userId) async {
  final result = await ref.watch(clientRepositoryProvider).followInfo(userId);
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

final followingProvider = FutureProvider<List<FollowedUser>>((ref) async {
  final userId = ref.watch(authNotifierProvider).user?.id;
  if (userId == null) return const [];
  final result = await ref.watch(clientRepositoryProvider).following(userId);
  return result.fold(failure: (failure) => throw failure, success: (data) => data);
});

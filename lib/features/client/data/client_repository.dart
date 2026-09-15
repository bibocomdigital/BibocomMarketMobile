import 'package:bibomarketmobile/core/error/error_mapper.dart';
import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/client/data/client_remote_datasource.dart';
import 'package:bibomarketmobile/features/client/domain/client_models.dart';

class ClientRepository {
  ClientRepository(this._remote);

  final ClientRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  Future<Result<List<CatalogProduct>>> products({
    int page = 1,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? order,
  }) =>
      _guard(
        () => _remote.products(
          page: page,
          categoryId: categoryId,
          search: search,
          minPrice: minPrice,
          maxPrice: maxPrice,
          sortBy: sortBy,
          order: order,
        ),
      );

  Future<Result<List<CatalogProduct>>> featured() => _guard(_remote.featured);

  Future<Result<List<CatalogProduct>>> latest() => _guard(_remote.latest);

  Future<Result<CatalogProduct>> product(int id) => _guard(() => _remote.product(id));

  Future<Result<List<ProductCategory>>> categories() => _guard(_remote.categories);

  Future<Result<List<ShopPreview>>> shops() => _guard(_remote.shops);

  Future<Result<({ShopPreview shop, List<CatalogProduct> products})>> shopDetails(int id) =>
      _guard(() => _remote.shopDetails(id));

  Future<Result<void>> contactShop({
    required int shopId,
    required String subject,
    required String message,
  }) =>
      _guard(
        () => _remote.contactShop(shopId: shopId, subject: subject, message: message),
      );

  Future<Result<({String action, int likesCount})>> likeProduct(int id) =>
      _guard(() => _remote.likeProduct(id));

  Future<Result<List<ProductComment>>> comments(int productId) =>
      _guard(() => _remote.comments(productId));

  Future<Result<ProductComment>> addComment(int productId, String comment) =>
      _guard(() => _remote.addComment(productId, comment));

  Future<Result<FollowInfo>> followInfo(int userId) =>
      _guard(() => _remote.followInfo(userId));

  Future<Result<FollowInfo>> toggleFollow(int userId) =>
      _guard(() => _remote.toggleFollow(userId));

  Future<Result<List<FollowedUser>>> following(int userId) =>
      _guard(() => _remote.following(userId));

  Future<Result<CartSummary>> cart() => _guard(_remote.cart);

  Future<Result<CartSummary>> addToCart(int productId, {int quantity = 1}) =>
      _guard(() => _remote.addToCart(productId, quantity: quantity));

  Future<Result<CartSummary>> updateCartItem(int itemId, int quantity) =>
      _guard(() => _remote.updateCartItem(itemId, quantity));

  Future<Result<void>> removeCartItem(int itemId) =>
      _guard(() => _remote.removeCartItem(itemId));

  Future<Result<CheckoutResult>> checkout({String? message}) =>
      _guard(() => _remote.checkout(message: message));

  Future<Result<void>> shareCartWhatsApp({String? message}) =>
      _guard(() => _remote.shareCartWhatsApp(message: message));

  Future<Result<List<ClientOrder>>> orders() => _guard(_remote.orders);

  Future<Result<ClientOrder>> order(int id) => _guard(() => _remote.order(id));

  Future<Result<void>> updateOrderStatus(int id, String status) =>
      _guard(() => _remote.updateOrderStatus(id, status));

  Future<Result<List<Conversation>>> conversations() => _guard(_remote.conversations);

  Future<Result<List<ChatMessage>>> thread(int partnerId) =>
      _guard(() => _remote.thread(partnerId));

  Future<Result<void>> sendMessage(int receiverId, String content) =>
      _guard(() => _remote.sendMessage(receiverId: receiverId, content: content));

  Future<Result<List<AppNotification>>> notifications() => _guard(_remote.notifications);

  Future<Result<void>> markNotificationsRead() => _guard(_remote.markNotificationsRead);
}

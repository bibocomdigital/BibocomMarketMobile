import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/network/api_envelope.dart';
import 'package:bibomarketmobile/features/client/domain/client_models.dart';
import 'package:dio/dio.dart';

class ClientRemoteDataSource {
  ClientRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CatalogProduct>> products({
    int page = 1,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? order,
  }) async {
    final path = search != null && search.isNotEmpty
        ? ApiEndpoints.productSearch
        : ApiEndpoints.products;
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: {
        'page': page,
        'limit': 20,
        'status': 'PUBLISHED',
        if (categoryId != null) 'category': categoryId,
        if (search != null && search.isNotEmpty) 'query': search,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sortBy != null) 'sortBy': sortBy,
        if (order != null) 'order': order,
      },
    );
    return _productsFrom(response.data);
  }

  Future<List<CatalogProduct>> featured() async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.productFeatured,
      queryParameters: {'limit': 10},
    );
    return _productsFrom(response.data);
  }

  Future<List<CatalogProduct>> latest() async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.productLatest,
      queryParameters: {'limit': 10},
    );
    return _productsFrom(response.data);
  }

  Future<CatalogProduct> product(int id) async {
    final response = await _dio.get<dynamic>('${ApiEndpoints.products}/$id');
    final map = unwrapApiMap(response.data);
    return _product(asMap(map['product']) ?? map);
  }

  Future<List<ProductCategory>> categories() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.categoriesProduit);
    return unwrapApiList(response.data).whereType<Map>().map((item) {
      return ProductCategory(
        id: asInt(item['id']),
        name: asString(item['name']),
        categorieShopId:
            item['categorieShopId'] == null ? null : asInt(item['categorieShopId']),
      );
    }).toList();
  }

  Future<List<ShopPreview>> shops() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.shop);
    return unwrapApiList(response.data).whereType<Map>().map(_shop).toList();
  }

  Future<({ShopPreview shop, List<CatalogProduct> products})> shopDetails(int id) async {
    final response = await _dio.get<dynamic>('${ApiEndpoints.shop}/$id/details');
    final map = unwrapApiMap(response.data);
    return (
      shop: _shop(asMap(map['shop']) ?? map, stats: asMap(map['merchantStats'])),
      products: _productsFrom(map['products']),
    );
  }

  Future<void> contactShop({
    required int shopId,
    required String subject,
    required String message,
  }) async {
    await _dio.post<dynamic>(
      '${ApiEndpoints.shop}/$shopId/contact',
      data: {'subject': subject, 'message': message},
    );
  }

  Future<({String action, int likesCount})> likeProduct(int id) async {
    final response = await _dio.post<dynamic>('${ApiEndpoints.productsAlias}/$id/like');
    final map = unwrapApiMap(response.data);
    return (
      action: asString(map['action']),
      likesCount: asInt(map['likesCount']),
    );
  }

  Future<List<ProductComment>> comments(int productId, {int page = 1}) async {
    final response = await _dio.get<dynamic>(
      '${ApiEndpoints.productsAlias}/$productId/comments',
      queryParameters: {'page': page, 'limit': 20},
    );
    return unwrapApiList(response.data).whereType<Map>().map(_comment).toList();
  }

  Future<ProductComment> addComment(int productId, String comment) async {
    final response = await _dio.post<dynamic>(
      '${ApiEndpoints.productsAlias}/$productId/comments',
      data: {'comment': comment},
    );
    final map = unwrapApiMap(response.data);
    return _comment(asMap(map['comment']) ?? map);
  }

  Future<FollowInfo> followInfo(int userId) async {
    final results = await Future.wait([
      _dio.get<dynamic>('${ApiEndpoints.users}/$userId/isFollowing'),
      _dio.get<dynamic>(
        '${ApiEndpoints.users}/$userId/followers',
        queryParameters: {'page': 1, 'limit': 1},
      ),
    ]);
    final followingMap = unwrapApiMap(results[0].data);
    final followersMap = unwrapApiMap(results[1].data);
    final pagination = asMap(followersMap['pagination']);
    return FollowInfo(
      isFollowing: asBool(followingMap['isFollowing']),
      followerCount: asInt(pagination?['total'] ?? followersMap['followerCount']),
    );
  }

  Future<FollowInfo> toggleFollow(int userId) async {
    final response = await _dio.post<dynamic>('${ApiEndpoints.users}/$userId/toggle-follow');
    final map = unwrapApiMap(response.data);
    return FollowInfo(
      isFollowing: asString(map['action']) == 'followed',
      followerCount: asInt(map['followerCount']),
    );
  }

  Future<List<FollowedUser>> following(int userId) async {
    final response = await _dio.get<dynamic>(
      '${ApiEndpoints.users}/$userId/following',
      queryParameters: {'page': 1, 'limit': 50},
    );
    return unwrapApiList(response.data).whereType<Map>().map(_followedUser).toList();
  }

  Future<CartSummary> cart() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.cart);
    final map = unwrapApiMap(response.data);
    return _cart(asMap(map['cart']) ?? map);
  }

  Future<CartSummary> addToCart(int productId, {int quantity = 1}) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.cart,
      data: {'productId': productId, 'quantity': quantity},
    );
    final map = unwrapApiMap(response.data);
    return _cart(asMap(map['cart']) ?? map);
  }

  Future<CartSummary> updateCartItem(int itemId, int quantity) async {
    final response = await _dio.put<dynamic>(
      '${ApiEndpoints.cart}/items/$itemId',
      data: {'quantity': quantity},
    );
    final map = unwrapApiMap(response.data);
    return _cart(asMap(map['cart']) ?? map);
  }

  Future<void> removeCartItem(int itemId) async {
    await _dio.delete<dynamic>('${ApiEndpoints.cart}/items/$itemId');
  }

  Future<CheckoutResult> checkout({String? message}) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.cartOrder,
      data: {if (message != null) 'message': message},
    );
    final map = unwrapApiMap(response.data);
    final order = asMap(map['order']) ?? map;
    return CheckoutResult(
      orderId: asInt(order['id']),
      totalAmount: asDouble(order['totalAmount']),
      status: asString(order['status'], fallback: 'PENDING'),
      paymentMethod: asString(order['paymentMethod'], fallback: PaymentMethods.cashOnDelivery),
    );
  }

  Future<void> shareCartWhatsApp({String? message}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.cartShare,
      data: {if (message != null) 'message': message},
    );
  }

  Future<List<ClientOrder>> orders() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.orders);
    final map = unwrapApiMap(response.data);
    final list = map['orders'];
    if (list is! List) return const [];
    return list.whereType<Map>().map(_order).toList();
  }

  Future<ClientOrder> order(int id) async {
    final response = await _dio.get<dynamic>('${ApiEndpoints.orders}/$id');
    final map = unwrapApiMap(response.data);
    return _order(asMap(map['order']) ?? map);
  }

  Future<void> updateOrderStatus(int id, String status) async {
    await _dio.patch<dynamic>(
      '${ApiEndpoints.orders}/$id/status',
      data: {'status': status},
    );
  }

  Future<List<Conversation>> conversations() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.conversations);
    return unwrapApiList(response.data).whereType<Map>().map((item) {
      return Conversation(
        partnerId: asInt(item['partnerId']),
        partnerName: asString(item['partnerName'], fallback: 'Boutique'),
        partnerPhoto: item['partnerPhoto'] as String?,
        lastMessage: asString(item['lastMessage']),
        unreadCount: asInt(item['unreadCount']),
      );
    }).toList();
  }

  Future<List<ChatMessage>> thread(int partnerId) async {
    final response =
        await _dio.get<dynamic>('${ApiEndpoints.messages}/with/$partnerId');
    final raw = unwrapApi(response.data);
    final list = raw is List
        ? raw
        : (raw is Map && raw['messages'] is List ? raw['messages'] as List : unwrapApiList(raw));
    return list.whereType<Map>().map((item) {
      return ChatMessage(
        id: asInt(item['id']),
        senderId: asInt(item['senderId']),
        content: asString(item['content']),
        createdAt: DateFormatFr.tryParse(item['createdAt']) ?? DateTime.now(),
        isRead: asBool(item['isRead']),
      );
    }).toList();
  }

  Future<void> sendMessage({required int receiverId, required String content}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.messageSend,
      data: {'receiverId': receiverId, 'content': content},
    );
  }

  Future<List<AppNotification>> notifications() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.notifications);
    return unwrapApiList(response.data).whereType<Map>().map((item) {
      return AppNotification(
        id: asInt(item['id']),
        type: asString(item['type']),
        message: asString(item['message']),
        isRead: asBool(item['isRead']),
        createdAt: DateFormatFr.tryParse(item['createdAt']),
      );
    }).toList();
  }

  Future<void> markNotificationsRead() async {
    await _dio.patch<dynamic>(ApiEndpoints.notifications);
  }

  List<CatalogProduct> _productsFrom(dynamic raw) {
    final unwrapped = unwrapApi(raw);
    if (unwrapped is List) {
      return unwrapped.whereType<Map>().map(_product).toList();
    }
    if (unwrapped is Map) {
      final list = unwrapped['products'];
      if (list is List) return list.whereType<Map>().map(_product).toList();
    }
    return const [];
  }

  CatalogProduct _product(Map json) {
    final images = json['images'];
    String? imageUrl;
    if (images is List && images.isNotEmpty && images.first is Map) {
      imageUrl = asString((images.first as Map)['imageUrl'] ?? (images.first as Map)['url']);
      if (imageUrl.isEmpty) imageUrl = null;
    }
    final shop = asMap(json['shop']);
    final category = asMap(json['categorieProd']);
    return CatalogProduct(
      id: asInt(json['id']),
      name: asString(json['name']),
      price: asDouble(json['price']),
      stock: asInt(json['stock']),
      description: json['description'] as String?,
      imageUrl: imageUrl,
      shopName: shop == null ? null : asString(shop['name']),
      shopId: shop == null ? null : asInt(shop['id']),
      shopPhone: shop?['phoneNumber'] as String?,
      shopUserId: json['userId'] == null ? null : asInt(json['userId']),
      categoryId: json['categorieProdId'] == null ? null : asInt(json['categorieProdId']),
      categoryName: category == null ? null : asString(category['name']),
      isLiked: asBool(json['isLiked']),
      likesCount: asInt(json['likesCount'] ?? asMap(json['_count'])?['likes']),
      commentsCount: asInt(json['commentsCount'] ?? asMap(json['_count'])?['comments']),
    );
  }

  ProductComment _comment(Map json) {
    final user = asMap(json['user']);
    return ProductComment(
      id: asInt(json['id']),
      comment: asString(json['comment']),
      firstName: asString(user?['firstName'] ?? json['firstName']),
      lastName: asString(user?['lastName'] ?? json['lastName']),
      createdAt: DateFormatFr.tryParse(json['createdAt']),
    );
  }

  FollowedUser _followedUser(Map json) {
    return FollowedUser(
      id: asInt(json['id']),
      firstName: asString(json['firstName']),
      lastName: asString(json['lastName']),
      photo: json['photo'] as String?,
      role: json['role'] as String?,
    );
  }

  ShopPreview _shop(Map json, {Map<String, dynamic>? stats}) {
    final owner = asMap(json['owner']);
    final category = asMap(json['categorieShop']);
    return ShopPreview(
      id: asInt(json['id']),
      name: asString(json['name']),
      phoneNumber: asString(json['phoneNumber']),
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      address: json['address'] as String?,
      ownerId: json['userId'] == null
          ? (owner == null ? null : asInt(owner['id']))
          : asInt(json['userId']),
      categoryName: category == null ? null : asString(category['name']),
      totalProducts: stats == null ? null : asInt(stats['totalProducts']),
      memberSince: DateFormatFr.tryParse(stats?['memberSince']),
    );
  }

  CartSummary _cart(Map json) {
    final items = json['items'];
    final parsed = items is List
        ? items.whereType<Map>().map((item) {
            final product = asMap(item['product']);
            final shop = asMap(product?['shop']);
            return CartItem(
              id: asInt(item['id']),
              productId: asInt(item['productId'] ?? product?['id']),
              name: asString(product?['name'] ?? item['name'], fallback: 'Produit'),
              price: asDouble(product?['price'] ?? item['price']),
              quantity: asInt(item['quantity'], fallback: 1),
              stock: asInt(product?['stock']),
              imageUrl: _firstImage(product),
              shopName: shop == null ? null : asString(shop['name']),
              shopPhone: shop?['phoneNumber'] as String?,
              merchantId: shop == null ? null : asInt(shop['userId']),
            );
          }).toList()
        : const <CartItem>[];
    final total = json['totalPrice'] != null
        ? asDouble(json['totalPrice'])
        : parsed.fold<double>(0, (sum, item) => sum + item.subtotal);
    return CartSummary(items: parsed, totalPrice: total);
  }

  ClientOrder _order(Map json) {
    final items = json['orderItems'] ?? json['items'];
    return ClientOrder(
      id: asInt(json['id']),
      status: asString(json['status']),
      totalAmount: asDouble(json['totalAmount']),
      createdAt: DateFormatFr.tryParse(json['createdAt']) ?? DateTime.now(),
      paymentMethod: asString(json['paymentMethod'], fallback: PaymentMethods.cashOnDelivery),
      items: items is List
          ? items.whereType<Map>().map((item) {
              final product = asMap(item['product']);
              final shop = asMap(product?['shop']);
              return ClientOrderItem(
                id: asInt(item['id']),
                name: asString(product?['name'] ?? item['name'], fallback: 'Produit'),
                quantity: asInt(item['quantity'], fallback: 1),
                price: asDouble(item['price']),
                imageUrl: _firstImage(product),
                shopName: shop == null ? null : asString(shop['name']),
                shopPhone: shop?['phoneNumber'] as String?,
              );
            }).toList()
          : const [],
    );
  }

  String? _firstImage(Map<String, dynamic>? product) {
    final images = product?['images'];
    if (images is List && images.isNotEmpty && images.first is Map) {
      return ((images.first as Map)['imageUrl'] ?? (images.first as Map)['url'])?.toString();
    }
    return null;
  }
}

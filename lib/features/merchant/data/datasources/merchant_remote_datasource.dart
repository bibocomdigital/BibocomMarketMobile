import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/merchant/data/models/merchant_models.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:dio/dio.dart';

class MerchantRemoteDataSource {
  MerchantRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ShopOverview> loadOverview() async {
    Shop? shop;
    var products = <Product>[];
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.myShop);
      final data = asJsonMap(response.data);
      shop = ShopModel.fromJson(data['shop'] ?? data);
      products = asList(data['products']).map(ProductModel.fromJson).toList();
    } on DioException catch (error) {
      final status = error.response?.statusCode ?? 0;
      if (status != 404 && status != 403) rethrow;
    }

    var orders = <MerchantOrder>[];
    try {
      orders = await getOrders();
    } catch (_) {}

    var stats = const ProductStats();
    try {
      final statsResponse = await _dio.get<dynamic>(ApiEndpoints.productStats);
      stats = ProductStatsModel.fromJson(statsResponse.data);
    } catch (_) {
      stats = ProductStats(
        totalProducts: products.length,
        lowStockCount: products.where((item) => item.stock <= 5).length,
      );
    }

    var merchantStats = const MerchantStats();
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.merchantStats);
      merchantStats = MerchantStatsModel.fromJson(response.data);
    } catch (_) {}

    return ShopOverview(
      shop: shop,
      products: products,
      orders: orders,
      stats: stats,
      merchantStats: merchantStats,
    );
  }

  Future<List<CatalogItem>> getShopCategories() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.shopCategories);
    return asList(response.data).map(CatalogItemModel.fromJson).toList();
  }

  Future<List<CatalogItem>> getProductCategories() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.productCategories);
    return asList(response.data).map(CatalogItemModel.fromJson).toList();
  }

  Future<Shop> createShop(CreateShopParams params) async {
    final form = FormData.fromMap({
      'name': params.name,
      'description': params.description,
      'phoneNumber': params.phoneNumber,
      'address': params.address,
      if (params.categorieShopId != null)
        'categorieShopId': params.categorieShopId.toString(),
      if (params.logoPath != null)
        'logo': await MultipartFile.fromFile(params.logoPath!),
    });
    final response = await _dio.post<dynamic>(ApiEndpoints.shop, data: form);
    final data = asJsonMap(response.data);
    return ShopModel.fromJson(data['shop'] ?? data)!;
  }

  Future<Shop> updateShop(int shopId, CreateShopParams params) async {
    final form = FormData.fromMap({
      'name': params.name,
      'description': params.description,
      'phoneNumber': params.phoneNumber,
      'address': params.address,
      if (params.categorieShopId != null)
        'categorieShopId': params.categorieShopId.toString(),
      if (params.logoPath != null)
        'logo': await MultipartFile.fromFile(params.logoPath!),
    });
    final response = await _dio.put<dynamic>(
      '${ApiEndpoints.shop}/$shopId',
      data: form,
    );
    final data = asJsonMap(response.data);
    return ShopModel.fromJson(data['shop'] ?? data)!;
  }

  Future<List<Product>> getProducts() async {
    final overview = await loadOverview();
    return overview.products;
  }

  Future<Product> saveProduct(ProductFormParams params) async {
    final form = FormData.fromMap({
      'name': params.name,
      'description': params.description,
      'price': params.price.toString(),
      'stock': params.stock.toString(),
      if (params.categorieProdId != null)
        'categorieProdId': params.categorieProdId.toString(),
      'status': params.status,
      if (params.imagePath != null)
        'productImages': await MultipartFile.fromFile(params.imagePath!),
    });
    final Response<dynamic> response;
    if (params.id == null) {
      response = await _dio.post<dynamic>(ApiEndpoints.products, data: form);
    } else {
      response = await _dio.put<dynamic>(
        '${ApiEndpoints.products}/${params.id}',
        data: form,
      );
    }
    final data = asJsonMap(response.data);
    return ProductModel.fromJson(data['product'] ?? data);
  }

  Future<Product> updateStock(int productId, int stock) async {
    final response = await _dio.patch<dynamic>(
      '${ApiEndpoints.products}/$productId/stock',
      data: {'stock': stock},
    );
    final data = asJsonMap(response.data);
    return ProductModel.fromJson(data['product'] ?? data);
  }

  Future<void> deleteProduct(int productId) async {
    await _dio.delete<dynamic>('${ApiEndpoints.products}/$productId');
  }

  Future<List<MerchantOrder>> getOrders() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.merchantOrders);
    final data = asJsonMap(response.data);
    final list = asList(data['orders'] ?? data['data'] ?? response.data);
    return list.map(OrderModel.fromJson).toList();
  }

  Future<MerchantOrder> getOrder(int orderId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${ApiEndpoints.orders}/$orderId',
      );
      final data = asJsonMap(response.data);
      return OrderModel.fromJson(data['order'] ?? data);
    } catch (_) {
      final orders = await getOrders();
      return orders.firstWhere((order) => order.id == orderId);
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await _dio.patch<dynamic>(
      '${ApiEndpoints.orders}/$orderId/status',
      data: {'status': status},
    );
  }

  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.conversations);
    final data = asJsonMap(response.data);
    final list = asList(data['data'] ?? data['conversations'] ?? response.data);
    return list.map(ConversationModel.fromJson).toList();
  }

  Future<List<ChatMessage>> getMessages(int partnerId) async {
    final response =
        await _dio.get<dynamic>(ApiEndpoints.messagesWith(partnerId));
    final data = asJsonMap(response.data);
    final payload = asJsonMap(data['data']);
    final list = asList(payload['messages'] ?? data['messages']);
    return list.map(ChatMessageModel.fromJson).toList();
  }

  Future<void> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    final form = FormData.fromMap({
      'receiverId': receiverId.toString(),
      'content': content,
    });
    await _dio.post<dynamic>(ApiEndpoints.sendMessage, data: form);
  }
}

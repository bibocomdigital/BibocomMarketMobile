import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';

class CreateShopParams {
  const CreateShopParams({
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.address,
    this.logoPath,
    this.categorieShopId,
  });

  final String name;
  final String description;
  final String phoneNumber;
  final String address;
  final String? logoPath;
  final int? categorieShopId;
}

class ProductFormParams {
  const ProductFormParams({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.categorieProdId,
    this.status = 'PUBLISHED',
    this.imagePath,
  });

  final int? id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final int? categorieProdId;
  final String status;
  final String? imagePath;
}

abstract class MerchantRepository {
  Future<Result<List<CatalogItem>>> getShopCategories();

  Future<Result<List<CatalogItem>>> getProductCategories();

  Future<Result<ShopOverview>> loadOverview();

  Future<Result<Shop?>> getMyShop();

  Future<Result<Shop>> createShop(CreateShopParams params);

  Future<Result<Shop>> updateShop(int shopId, CreateShopParams params);

  Future<Result<List<Product>>> getProducts();

  Future<Result<Product>> saveProduct(ProductFormParams params);

  Future<Result<Product>> updateStock(int productId, int stock);

  Future<Result<void>> deleteProduct(int productId);

  Future<Result<List<MerchantOrder>>> getOrders();

  Future<Result<MerchantOrder>> getOrder(int orderId);

  Future<Result<void>> updateOrderStatus(int orderId, String status);

  Future<Result<List<Conversation>>> getConversations();

  Future<Result<List<ChatMessage>>> getMessages(int partnerId);

  Future<Result<void>> sendMessage({
    required int receiverId,
    required String content,
  });
}

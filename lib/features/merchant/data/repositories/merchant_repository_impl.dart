import 'package:bibomarketmobile/core/error/error_mapper.dart';
import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/merchant/data/datasources/merchant_remote_datasource.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  MerchantRepositoryImpl(this._remote);

  final MerchantRemoteDataSource _remote;

  @override
  Future<Result<List<CatalogItem>>> getShopCategories() async {
    try {
      return Success(await _remote.getShopCategories());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<CatalogItem>>> getProductCategories() async {
    try {
      return Success(await _remote.getProductCategories());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<ShopOverview>> loadOverview() async {
    try {
      return Success(await _remote.loadOverview());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<Shop?>> getMyShop() async {
    try {
      final overview = await _remote.loadOverview();
      return Success(overview.shop);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<Shop>> createShop(CreateShopParams params) async {
    try {
      return Success(await _remote.createShop(params));
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<Shop>> updateShop(int shopId, CreateShopParams params) async {
    try {
      return Success(await _remote.updateShop(shopId, params));
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      return Success(await _remote.getProducts());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<Product>> saveProduct(ProductFormParams params) async {
    try {
      return Success(await _remote.saveProduct(params));
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<Product>> updateStock(int productId, int stock) async {
    try {
      return Success(await _remote.updateStock(productId, stock));
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> deleteProduct(int productId) async {
    try {
      await _remote.deleteProduct(productId);
      return const Success(null);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<MerchantOrder>>> getOrders() async {
    try {
      return Success(await _remote.getOrders());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<MerchantOrder>> getOrder(int orderId) async {
    try {
      return Success(await _remote.getOrder(orderId));
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> updateOrderStatus(int orderId, String status) async {
    try {
      await _remote.updateOrderStatus(orderId, status);
      return const Success(null);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<Conversation>>> getConversations() async {
    try {
      return Success(await _remote.getConversations());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages(int partnerId) async {
    try {
      return Success(await _remote.getMessages(partnerId));
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    try {
      await _remote.sendMessage(receiverId: receiverId, content: content);
      return const Success(null);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }
}

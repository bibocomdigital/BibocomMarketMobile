import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';

class ShopModel {
  static Shop? fromJson(Object? json) {
    final map = asJsonMap(json);
    if (map.isEmpty || map['id'] == null) return null;
    final category = asJsonMap(map['categorieShop']);
    return Shop(
      id: asInt(map['id']),
      name: asString(map['name']),
      description: asString(map['description']),
      phoneNumber: asString(map['phoneNumber'] ?? map['phone']),
      address: asString(map['address']),
      logo: map['logo']?.toString(),
      userId: map['userId'] == null ? null : asInt(map['userId']),
      createdAt: map['createdAt']?.toString(),
      verified: asBool(map['verified'] ?? map['verifiedBadge']),
      categorieShopId: map['categorieShopId'] == null
          ? (category['id'] == null ? null : asInt(category['id']))
          : asInt(map['categorieShopId']),
    );
  }
}

class ProductModel {
  static Product fromJson(Object? json) {
    final map = asJsonMap(json);
    final images = asList(map['images']);
    String? imageUrl;
    if (images.isNotEmpty) {
      final first = asJsonMap(images.first);
      imageUrl = first['imageUrl']?.toString() ?? first['url']?.toString();
    }
    final category = asJsonMap(map['categorieProd'] ?? map['category']);
    final categoryName = asString(
      category['name'] ?? map['category'],
      'Général',
    );
    return Product(
      id: asInt(map['id']),
      name: asString(map['name']),
      description: asString(map['description']),
      price: asDouble(map['price']),
      stock: asInt(map['stock']),
      category: categoryName,
      categorieProdId: map['categorieProdId'] == null
          ? (category['id'] == null ? null : asInt(category['id']))
          : asInt(map['categorieProdId']),
      status: asString(map['status'], 'PUBLISHED'),
      imageUrl: imageUrl,
      shopId: map['shopId'] == null ? null : asInt(map['shopId']),
    );
  }
}

class OrderModel {
  static MerchantOrder fromJson(Object? json) {
    final map = asJsonMap(json);
    final client = asJsonMap(map['client']);
    final items = asList(map['orderItems'] ?? map['items']).map((item) {
      final itemMap = asJsonMap(item);
      final product = asJsonMap(itemMap['product']);
      final images = asList(product['images']);
      String? imageUrl;
      if (images.isNotEmpty) {
        final first = asJsonMap(images.first);
        imageUrl = first['imageUrl']?.toString() ?? first['url']?.toString();
      }
      return MerchantOrderItem(
        name: asString(product['name'] ?? itemMap['name'], 'Produit'),
        quantity: asInt(itemMap['quantity'], 1),
        price: asDouble(itemMap['price'] ?? product['price']),
        imageUrl: imageUrl,
      );
    }).toList();

    final firstName = asString(client['firstName']);
    final lastName = asString(client['lastName']);
    final clientName = '$firstName $lastName'.trim();

    return MerchantOrder(
      id: asInt(map['id']),
      status: asString(map['status'], 'PENDING'),
      totalAmount: asDouble(map['totalAmount'] ?? map['total']),
      createdAt: asString(map['createdAt']),
      clientName: clientName.isEmpty ? null : clientName,
      clientPhone: client['phoneNumber']?.toString(),
      items: items,
    );
  }
}

class ConversationModel {
  static Conversation fromJson(Object? json) {
    final map = asJsonMap(json);
    return Conversation(
      partnerId: asInt(map['partnerId']),
      partnerName: asString(map['partnerName'], 'Client'),
      partnerPhoto: map['partnerPhoto']?.toString(),
      partnerPhone: (map['partnerPhone'] ?? map['phoneNumber'] ?? map['phone'])
          ?.toString(),
      lastMessage: map['lastMessage']?.toString(),
      lastMessageTime: map['lastMessageTime']?.toString(),
      unreadCount: asInt(map['unreadCount']),
    );
  }
}

class ChatMessageModel {
  static ChatMessage fromJson(Object? json) {
    final map = asJsonMap(json);
    return ChatMessage(
      id: asInt(map['id']),
      content: asString(map['content']),
      senderId: asInt(map['senderId']),
      createdAt: asString(map['createdAt']),
      isRead: asBool(map['isRead']),
    );
  }
}

class ProductStatsModel {
  static ProductStats fromJson(Object? json) {
    final map = asJsonMap(json);
    return ProductStats(
      totalProducts: asInt(map['totalProducts']),
      lowStockCount: asInt(map['lowStockCount']),
    );
  }
}

class CatalogItemModel {
  static CatalogItem fromJson(Object? json) {
    final map = asJsonMap(json);
    return CatalogItem(
      id: asInt(map['id']),
      name: asString(map['name']),
    );
  }
}

class MerchantStatsModel {
  static MerchantStats fromJson(Object? json) {
    final raw = asJsonMap(json);
    final nested = asJsonMap(raw['data']);
    final map = nested.isNotEmpty ? nested : raw;
    final chart = asList(map['revenueChart'] ?? map['chartData']).map((item) {
      final point = asJsonMap(item);
      return MerchantChartPoint(
        date: asString(point['date']),
        revenue: asDouble(point['revenue']),
        orderCount: asInt(point['orderCount']),
      );
    }).toList();
    final top = asList(map['topProducts']).map((item) {
      final row = asJsonMap(item);
      final product = asJsonMap(row['product']);
      return MerchantTopProduct(
        name: asString(
          row['productName'] ?? product['name'],
          'Produit',
        ),
        totalSold: asInt(row['totalSold']),
        totalRevenue: asDouble(row['totalRevenue']),
      );
    }).toList();
    return MerchantStats(
      totalRevenue: asDouble(map['totalRevenue']),
      totalOrders: asInt(map['totalOrders']),
      pendingOrders: asInt(map['pendingOrders']),
      deliveredOrders: asInt(map['deliveredOrders']),
      chart: chart,
      topProducts: top,
    );
  }
}

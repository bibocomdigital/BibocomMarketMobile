class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.address,
    this.logo,
    this.userId,
    this.createdAt,
    this.verified = false,
    this.categorieShopId,
  });

  final int id;
  final String name;
  final String description;
  final String phoneNumber;
  final String address;
  final String? logo;
  final int? userId;
  final String? createdAt;
  final bool verified;
  final int? categorieShopId;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'B';
    if (parts.length == 1) {
      final word = parts.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    final a = parts[0].isNotEmpty ? parts[0][0] : 'B';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return '$a$b'.toUpperCase();
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.categorieProdId,
    this.status = 'PUBLISHED',
    this.imageUrl,
    this.shopId,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final int? categorieProdId;
  final String status;
  final String? imageUrl;
  final int? shopId;
}

class MerchantOrder {
  const MerchantOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.clientName,
    this.clientPhone,
    this.items = const [],
  });

  final int id;
  final String status;
  final double totalAmount;
  final String createdAt;
  final String? clientName;
  final String? clientPhone;
  final List<MerchantOrderItem> items;

  bool get isDelivered {
    final value = status.toUpperCase();
    return value.contains('DELIVER') || value.contains('COMPLETE');
  }
}

class MerchantOrderItem {
  const MerchantOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
}

class Conversation {
  const Conversation({
    required this.partnerId,
    required this.partnerName,
    this.partnerPhoto,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  final int partnerId;
  final String partnerName;
  final String? partnerPhoto;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.isRead = false,
  });

  final int id;
  final String content;
  final int senderId;
  final String createdAt;
  final bool isRead;
}

class CatalogItem {
  const CatalogItem({required this.id, required this.name});

  final int id;
  final String name;
}

class MerchantChartPoint {
  const MerchantChartPoint({
    required this.date,
    required this.revenue,
    this.orderCount = 0,
  });

  final String date;
  final double revenue;
  final int orderCount;
}

class MerchantTopProduct {
  const MerchantTopProduct({
    required this.name,
    this.totalSold = 0,
    this.totalRevenue = 0,
  });

  final String name;
  final int totalSold;
  final double totalRevenue;
}

class MerchantStats {
  const MerchantStats({
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.deliveredOrders = 0,
    this.chart = const [],
    this.topProducts = const [],
  });

  final double totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;
  final List<MerchantChartPoint> chart;
  final List<MerchantTopProduct> topProducts;
}

class ProductStats {
  const ProductStats({
    this.totalProducts = 0,
    this.lowStockCount = 0,
  });

  final int totalProducts;
  final int lowStockCount;
}

class ShopOverview {
  const ShopOverview({
    this.shop,
    this.products = const [],
    this.orders = const [],
    this.stats = const ProductStats(),
    this.merchantStats = const MerchantStats(),
  });

  final Shop? shop;
  final List<Product> products;
  final List<MerchantOrder> orders;
  final ProductStats stats;
  final MerchantStats merchantStats;

  double get salesTotal => merchantStats.totalRevenue > 0
      ? merchantStats.totalRevenue
      : orders.fold(0, (sum, order) => sum + order.totalAmount);

  int get ordersCount => merchantStats.totalOrders > 0
      ? merchantStats.totalOrders
      : orders.length;
}

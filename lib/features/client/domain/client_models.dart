class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.shopName,
    this.shopId,
    this.shopPhone,
    this.shopUserId,
    this.categoryId,
    this.categoryName,
    this.isLiked = false,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  final int id;
  final String name;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;
  final String? shopName;
  final int? shopId;
  final String? shopPhone;
  final int? shopUserId;
  final int? categoryId;
  final String? categoryName;
  final bool isLiked;
  final int likesCount;
  final int commentsCount;

  bool get inStock => stock > 0;
}

class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    this.categorieShopId,
  });

  final int id;
  final String name;
  final int? categorieShopId;
}

class ShopPreview {
  const ShopPreview({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.description,
    this.logo,
    this.address,
    this.ownerId,
    this.categoryName,
    this.totalProducts,
    this.memberSince,
  });

  final int id;
  final String name;
  final String phoneNumber;
  final String? description;
  final String? logo;
  final String? address;
  final int? ownerId;
  final String? categoryName;
  final int? totalProducts;
  final DateTime? memberSince;
}

class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.stock,
    this.imageUrl,
    this.shopName,
    this.shopPhone,
    this.merchantId,
  });

  final int id;
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final int stock;
  final String? imageUrl;
  final String? shopName;
  final String? shopPhone;
  final int? merchantId;

  double get subtotal => price * quantity;
}

class CartSummary {
  const CartSummary({this.items = const [], this.totalPrice = 0});

  final List<CartItem> items;
  final double totalPrice;

  bool get isEmpty => items.isEmpty;
}

class ClientOrder {
  const ClientOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.paymentMethod = 'CASH_ON_DELIVERY',
    this.items = const [],
  });

  final int id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String paymentMethod;
  final List<ClientOrderItem> items;
}

class ClientOrderItem {
  const ClientOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.shopName,
    this.shopPhone,
  });

  final int id;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? shopName;
  final String? shopPhone;
}

class Conversation {
  const Conversation({
    required this.partnerId,
    required this.partnerName,
    this.partnerPhoto,
    this.lastMessage = '',
    this.unreadCount = 0,
  });

  final int partnerId;
  final String partnerName;
  final String? partnerPhoto;
  final String lastMessage;
  final int unreadCount;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  final int id;
  final int senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
}

class CheckoutResult {
  const CheckoutResult({
    required this.orderId,
    required this.totalAmount,
    this.status = 'PENDING',
    this.paymentMethod = 'CASH_ON_DELIVERY',
  });

  final int orderId;
  final double totalAmount;
  final String status;
  final String paymentMethod;
}

class ProductComment {
  const ProductComment({
    required this.id,
    required this.comment,
    required this.firstName,
    required this.lastName,
    this.createdAt,
  });

  final int id;
  final String comment;
  final String firstName;
  final String lastName;
  final DateTime? createdAt;

  String get author => '$firstName $lastName'.trim();
}

class FollowedUser {
  const FollowedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photo,
    this.role,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? photo;
  final String? role;

  String get displayName => '$firstName $lastName'.trim();
}

class FollowInfo {
  const FollowInfo({required this.isFollowing, required this.followerCount});

  final bool isFollowing;
  final int followerCount;
}

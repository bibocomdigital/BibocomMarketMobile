abstract final class StorageKeys {
  static const accessToken = 'access_token';
  static const cachedUser = 'cached_user';
  static const onboardingDone = 'onboarding_done';
  static const selectedRole = 'selected_role';
  static const pendingShopName = 'pending_shop_name';
  static const pendingShopSector = 'pending_shop_sector';
  static const pendingShopPhone = 'pending_shop_phone';
  static const pendingShopCategoryId = 'pending_shop_category_id';
}

abstract final class UserRoles {
  static const client = 'CLIENT';
  static const merchant = 'MERCHANT';
  static const supplier = 'SUPPLIER';
}

abstract final class PaymentMethods {
  static const cashOnDelivery = 'CASH_ON_DELIVERY';
  static const mobileMoney = 'MOBILE_MONEY';

  static String label(String value) {
    return switch (value) {
      cashOnDelivery => 'Paiement à la livraison',
      mobileMoney => 'Mobile Money',
      _ => value,
    };
  }
}

abstract final class OrderStatuses {
  static const pending = 'PENDING';
  static const confirmed = 'CONFIRMED';
  static const shipped = 'SHIPPED';
  static const delivered = 'DELIVERED';
  static const canceled = 'CANCELED';

  static const timeline = [pending, confirmed, shipped, delivered];

  static String label(String status) {
    return switch (status) {
      pending => 'En attente',
      confirmed => 'Confirmée',
      shipped => 'Expédiée',
      delivered => 'Livrée',
      canceled => 'Annulée',
      _ => status,
    };
  }
}

abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const verify = '/auth/verify';
  static const googleAuth = '/auth/google';
  static const logout = '/auth/logout';
  static const changePassword = '/auth/change-password';
  static const deleteAccount = '/auth/account';
  static const usersProfile = '/users/profile';
  static const profile = '/auth/profile';
  static const onboardingPersonal = '/auth/onboarding/personal';
  static const products = '/produit';
  static const productsAlias = '/products';
  static const productSearch = '/produit/search';
  static const productLatest = '/produit/latest';
  static const productFeatured = '/produit/featured';
  static const productStats = '/produit/stats';
  static const categoriesProduit = '/categories-produit';
  static const productCategories = categoriesProduit;
  static const categoriesShop = '/categories-shop';
  static const shopCategories = categoriesShop;
  static const shop = '/shop';
  static const myShop = '/shop/mine';
  static const cart = '/cart';
  static const cartOrder = '/cart/order';
  static const cartShare = '/cart/share/whatsapp';
  static const orders = '/orders';
  static const merchantOrders = '/merchant/orders';
  static const merchantStats = '/merchant/stats';
  static const merchantRevenueChart = '/merchant/revenue-chart';
  static const merchantTopProducts = '/merchant/top-products';
  static const messages = '/messages';
  static const messageSend = '/messages/send';
  static const sendMessage = messageSend;
  static const conversations = '/messages/conversations';
  static const notifications = '/notifications';
  static const users = '/users';

  static String messagesWith(int partnerId) => '/messages/with/$partnerId';
  static String productMerchant(int merchantId) =>
      '/produit/merchant/$merchantId';
}

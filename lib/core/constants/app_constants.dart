abstract final class StorageKeys {
  static const accessToken = 'access_token';
  static const cachedUser = 'cached_user';
  static const onboardingDone = 'onboarding_done';
  static const pendingShopName = 'pending_shop_name';
  static const pendingShopSector = 'pending_shop_sector';
  static const pendingShopPhone = 'pending_shop_phone';
  static const pendingShopCategoryId = 'pending_shop_category_id';
}

abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const googleAuth = '/auth/google';
  static const profile = '/auth/profile';
  static const myShop = '/shop/mine';
  static const shop = '/shop';
  static const shopCategories = '/categories-shop';
  static const productCategories = '/categories-produit';
  static const products = '/produit';
  static const productStats = '/produit/stats';
  static const merchantOrders = '/merchant/orders';
  static const merchantStats = '/merchant/stats';
  static const merchantRevenueChart = '/merchant/revenue-chart';
  static const merchantTopProducts = '/merchant/top-products';
  static const orders = '/orders';
  static const conversations = '/messages/conversations';
  static const sendMessage = '/messages/send';

  static String messagesWith(int partnerId) => '/messages/with/$partnerId';
  static String productMerchant(int merchantId) =>
      '/produit/merchant/$merchantId';
}

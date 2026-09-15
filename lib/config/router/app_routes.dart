abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const roleSelect = '/role';
  static const register = '/register';
  static const merchantRegister = '/register/merchant';
  static const verify = '/verify';
  static const verifyWait = '/verify-wait';
  static const completeProfile = '/complete-profile';
  static const identityVerification = '/identity-verification';
  static const login = '/login';

  static const home = '/home';
  static const categories = '/categories';
  static const search = '/search';
  static const product = '/product';
  static const shops = '/shops';
  static const shop = '/shop';
  static const shopContact = '/shop-contact';
  static const cart = '/cart';
  static const orderConfirmed = '/order-confirmed';
  static const orders = '/orders';
  static const messages = '/messages';
  static const chat = '/chat';
  static const whatsapp = '/whatsapp';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const security = '/profile/security';
  static const preferences = '/profile/preferences';
  static const favorites = '/profile/favorites';

  static const merchantHome = '/merchant';
  static const products = '/products';
  static const addProduct = '/products/new';
  static const merchantOrders = '/merchant/orders';
  static const stats = '/stats';
  static const merchantProfile = '/merchant/profile';
  static const merchantMessages = '/merchant/messages';
  static const support = '/support';
  static const faq = '/faq';
  static const settings = '/settings';
  static const shopStatus = '/shop-status';
  static const shopProfile = '/shop-profile';
  static const editShop = '/shop-edit';
  static const stock = '/stock';
  static const promotions = '/promotions';
  static const payments = '/payments';
  static const withdraw = '/withdraw';
  static const productRequests = '/product-requests';
  static const logoutConfirm = '/logout';

  static String editProductPath(int id) => '/products/$id/edit';
  static String orderDetailPath(int id) => '$merchantOrders/$id';
  static String messageThreadPath(int id) => '$merchantMessages/$id';

  static String homeFor({required bool isMerchant}) =>
      isMerchant ? merchantHome : home;

  static const public = {
    splash,
    onboarding,
    roleSelect,
    register,
    merchantRegister,
    verify,
    verifyWait,
    login,
    identityVerification,
  };

  static const _merchantPrefixes = [
    merchantHome,
    products,
    merchantOrders,
    stats,
    merchantProfile,
    merchantMessages,
    support,
    faq,
    settings,
    shopStatus,
    shopProfile,
    editShop,
    stock,
    promotions,
    payments,
    withdraw,
    productRequests,
    logoutConfirm,
    addProduct,
  ];

  static bool isMerchantArea(String location) {
    return _merchantPrefixes.any(
      (path) => location == path || location.startsWith('$path/'),
    );
  }

  static bool isClientArea(String location) {
    if (isMerchantArea(location)) return false;
    const prefixes = [
      home,
      categories,
      search,
      product,
      shops,
      shop,
      shopContact,
      cart,
      orderConfirmed,
      orders,
      messages,
      chat,
      whatsapp,
      notifications,
      profile,
      editProfile,
      security,
      preferences,
      favorites,
    ];
    return prefixes.any(
      (path) => location == path || location.startsWith('$path/'),
    );
  }
}

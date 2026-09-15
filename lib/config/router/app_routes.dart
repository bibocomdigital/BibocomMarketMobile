abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const identityVerification = '/identity-verification';

  static const home = '/home';
  static const products = '/products';
  static const addProduct = '/products/new';
  static const orders = '/orders';
  static const stats = '/stats';
  static const profile = '/profile';

  static const messages = '/messages';
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
  static String orderDetailPath(int id) => '/orders/$id';
  static String messageThreadPath(int id) => '/messages/$id';

  static const public = {
    splash,
    onboarding,
    login,
    register,
    identityVerification,
  };
}

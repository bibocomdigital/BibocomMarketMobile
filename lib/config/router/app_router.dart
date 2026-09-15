import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/config/router/auth_refresh.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/features/auth/presentation/pages/identity_verification_page.dart';
import 'package:bibomarketmobile/features/auth/presentation/pages/login_page.dart';
import 'package:bibomarketmobile/features/auth/presentation/pages/register_page.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/dashboard_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/help_pages.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/messages_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/ops_pages.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/order_detail_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/orders_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/product_form_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/products_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/profile_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/shop_pages.dart';
import 'package:bibomarketmobile/features/merchant/presentation/pages/stats_page.dart';
import 'package:bibomarketmobile/features/merchant/presentation/shell/merchant_shell.dart';
import 'package:bibomarketmobile/screens/onboarding/onboarding_screen.dart';
import 'package:bibomarketmobile/screens/splash/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authRefreshProvider = Provider<AuthRefreshListenable>((ref) {
  final refresh = AuthRefreshListenable();
  ref.onDispose(refresh.dispose);
  ref.listen(authNotifierProvider, (_, _) => refresh.ping());
  ref.listen(splashReadyProvider, (_, _) => refresh.ping());
  return refresh;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final location = state.matchedLocation;
      final onboardingDone = ref
          .read(localStorageServiceProvider)
          .getBool(StorageKeys.onboardingDone);

      final splashReady = ref.read(splashReadyProvider);
      if (auth.isRestoring || !splashReady) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (!auth.isAuthenticated) {
        if (!onboardingDone && location != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }
        if (onboardingDone && !AppRoutes.public.contains(location)) {
          return AppRoutes.login;
        }
        if (location == AppRoutes.splash) {
          return onboardingDone ? AppRoutes.login : AppRoutes.onboarding;
        }
        return null;
      }

      if (location == AppRoutes.splash ||
          location == AppRoutes.login ||
          location == AppRoutes.onboarding ||
          location == AppRoutes.register ||
          location == AppRoutes.identityVerification) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.identityVerification,
        builder: (context, state) => const IdentityVerificationPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MerchantShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (context, state) => const ProductsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                builder: (context, state) => const StatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addProduct,
        builder: (context, state) => const ProductFormPage(),
      ),
      GoRoute(
        path: '/products/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return ProductFormPage(productId: id);
        },
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailPage(orderId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.messages,
        builder: (context, state) => const MessagesPage(),
      ),
      GoRoute(
        path: '/messages/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return MessageThreadPage(partnerId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        builder: (context, state) => const FaqPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.shopStatus,
        builder: (context, state) => const ShopStatusPage(),
      ),
      GoRoute(
        path: AppRoutes.shopProfile,
        builder: (context, state) => const ShopProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.editShop,
        builder: (context, state) => const EditShopPage(),
      ),
      GoRoute(
        path: AppRoutes.stock,
        builder: (context, state) => const StockPage(),
      ),
      GoRoute(
        path: AppRoutes.promotions,
        builder: (context, state) => const PromotionsPage(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        builder: (context, state) => const PaymentsPage(),
      ),
      GoRoute(
        path: AppRoutes.withdraw,
        builder: (context, state) => const WithdrawPage(),
      ),
      GoRoute(
        path: AppRoutes.productRequests,
        builder: (context, state) => const ProductRequestsPage(),
      ),
      GoRoute(
        path: AppRoutes.logoutConfirm,
        builder: (context, state) => const LogoutConfirmPage(),
      ),
    ],
  );
});

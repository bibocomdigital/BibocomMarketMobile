import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/config/router/auth_refresh.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/features/auth/presentation/pages/auth_flow_pages.dart';
import 'package:bibomarketmobile/features/auth/presentation/pages/login_page.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/client/presentation/pages/account_pages.dart';
import 'package:bibomarketmobile/features/client/presentation/pages/cart_pages.dart';
import 'package:bibomarketmobile/features/client/presentation/pages/catalog_pages.dart';
import 'package:bibomarketmobile/features/client/presentation/pages/message_pages.dart';
import 'package:bibomarketmobile/features/client/presentation/pages/shop_pages.dart';
import 'package:bibomarketmobile/features/home/presentation/pages/home_page.dart';
import 'package:bibomarketmobile/screens/onboarding/onboarding_screen.dart';
import 'package:bibomarketmobile/screens/splash/splash_screen.dart';
import 'package:bibomarketmobile/shared/widgets/client_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authRefreshProvider = Provider<AuthRefreshListenable>((ref) {
  final refresh = AuthRefreshListenable();
  ref.onDispose(refresh.dispose);
  ref.listen(authNotifierProvider, (_, _) => refresh.ping());
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

      if (auth.isRestoring) {
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
          return onboardingDone ? AppRoutes.roleSelect : AppRoutes.onboarding;
        }
        return null;
      }

      if (location == AppRoutes.splash ||
          location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.onboarding ||
          location == AppRoutes.roleSelect ||
          location == AppRoutes.verifyWait) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.roleSelect, builder: (context, state) => const RoleSelectPage()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: AppRoutes.verify,
        builder: (context, state) => VerifyCodePage(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(path: AppRoutes.verifyWait, builder: (context, state) => const VerifyWaitingPage()),
      GoRoute(path: AppRoutes.completeProfile, builder: (context, state) => const CompleteProfilePage()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ClientShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.home, builder: (context, state) => const ClientHomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) => CategoriesPage(
                  categoryId: int.tryParse(state.uri.queryParameters['id'] ?? ''),
                  categoryName: state.uri.queryParameters['name'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.cart, builder: (context, state) => const CartPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.messages, builder: (context, state) => const ConversationsPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfilePage()),
            ],
          ),
        ],
      ),
      GoRoute(path: AppRoutes.search, builder: (context, state) => const SearchPage()),
      GoRoute(
        path: '${AppRoutes.product}/:id',
        builder: (context, state) => ProductDetailPage(
          productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(path: AppRoutes.shops, builder: (context, state) => const ShopsPage()),
      GoRoute(
        path: '${AppRoutes.shop}/:id',
        builder: (context, state) => ShopDetailPage(
          shopId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.shopContact}/:id',
        builder: (context, state) => ShopContactPage(
          shopId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmed,
        builder: (context, state) => OrderConfirmedPage(
          orderId: int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0,
          total: double.tryParse(state.uri.queryParameters['total'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => OrderDetailPage(
              orderId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => ChatPage(
          partnerId: int.tryParse(state.uri.queryParameters['partnerId'] ?? '') ?? 0,
          partnerName: state.uri.queryParameters['name'] ?? 'Boutique',
        ),
      ),
      GoRoute(path: AppRoutes.whatsapp, builder: (context, state) => const WhatsAppPage()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsPage()),
      GoRoute(path: AppRoutes.editProfile, builder: (context, state) => const EditProfilePage()),
      GoRoute(path: AppRoutes.favorites, builder: (context, state) => const FavoritesPage()),
      GoRoute(path: AppRoutes.security, builder: (context, state) => const SecurityPage()),
      GoRoute(path: AppRoutes.preferences, builder: (context, state) => const PreferencesPage()),
    ],
  );
});

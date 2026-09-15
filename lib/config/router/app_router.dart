import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/config/router/auth_refresh.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/features/auth/presentation/pages/login_page.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/home/presentation/pages/home_page.dart';
import 'package:bibomarketmobile/screens/onboarding/onboarding_screen.dart';
import 'package:bibomarketmobile/screens/splash/splash_screen.dart';
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
          return onboardingDone ? AppRoutes.login : AppRoutes.onboarding;
        }
        return null;
      }

      if (location == AppRoutes.splash ||
          location == AppRoutes.login ||
          location == AppRoutes.onboarding) {
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
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});

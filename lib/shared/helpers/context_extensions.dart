import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/shared/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:bibomarketmobile/shared/widgets/app_toast.dart'
    show AppAlert, AppToast, AppToastKind;

extension BuildContextX on BuildContext {
  void showSnack(String message, {AppToastKind? kind}) {
    AppToast.show(this, message: message, kind: kind);
  }

  /// Always leaves the current screen: pop when possible, otherwise `go` home.
  void popOrFallback({String? fallback}) {
    if (canPop()) {
      pop();
      return;
    }
    go(fallback ?? _fallbackRoute());
  }

  String _fallbackRoute() {
    final location = GoRouterState.of(this).uri.path;
    if (AppRoutes.public.contains(location) ||
        location == AppRoutes.completeProfile ||
        location == AppRoutes.roleSelect) {
      return AppRoutes.login;
    }
    if (AppRoutes.isMerchantArea(location)) {
      return AppRoutes.merchantHome;
    }
    if (location == AppRoutes.orders ||
        location.startsWith('${AppRoutes.orders}/') ||
        location == AppRoutes.notifications ||
        location == AppRoutes.whatsapp ||
        location == AppRoutes.favorites ||
        location == AppRoutes.security ||
        location == AppRoutes.preferences ||
        location.startsWith(AppRoutes.profile)) {
      return AppRoutes.profile;
    }
    return AppRoutes.home;
  }
}

import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final overview = ref.watch(merchantOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          MerchantHeader(
            height: 210,
            child: overview.when(
              loading: () => const AppLoader(),
              error: (_, _) => _ProfileHead(
                name: user?.displayName ?? 'Commerçant',
                email: user?.email ?? '',
                initials: 'B',
              ),
              data: (data) => _ProfileHead(
                name: data.shop?.name ?? user?.displayName ?? 'Commerçant',
                email: user?.email ?? '',
                initials: data.shop?.initials ?? 'B',
                products: data.products.length,
                rating: data.shop?.verified == true ? '4,8' : '—',
                sales: '${data.ordersCount}',
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  MerchantMenuTile(
                    icon: Icons.storefront_outlined,
                    label: 'Ma boutique',
                    onTap: () => context.push(AppRoutes.shopProfile),
                  ),
                  const SizedBox(height: 8),
                  MerchantMenuTile(
                    icon: Icons.inventory_2_outlined,
                    label: 'Mes produits',
                    onTap: () => context.go(AppRoutes.products),
                  ),
                  const SizedBox(height: 8),
                  MerchantMenuTile(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Commandes',
                    onTap: () => context.go(AppRoutes.orders),
                  ),
                  const SizedBox(height: 8),
                  MerchantMenuTile(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistiques',
                    onTap: () => context.go(AppRoutes.stats),
                  ),
                  const SizedBox(height: 8),
                  MerchantMenuTile(
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  const SizedBox(height: 8),
                  MerchantMenuTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Aide et support',
                    onTap: () => context.push(AppRoutes.support),
                  ),
                  const SizedBox(height: 8),
                  MerchantMenuTile(
                    icon: Icons.logout_rounded,
                    label: 'Se déconnecter',
                    destructive: true,
                    onTap: () => context.push(AppRoutes.logoutConfirm),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHead extends StatelessWidget {
  const _ProfileHead({
    required this.name,
    required this.email,
    required this.initials,
    this.products,
    this.rating,
    this.sales,
  });

  final String name;
  final String email;
  final String initials;
  final int? products;
  final String? rating;
  final String? sales;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        Text(
          email,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
        ),
        if (products != null) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(value: '$products', label: 'Produits'),
              _MiniStat(value: rating ?? '—', label: 'Note'),
              _MiniStat(value: sales ?? '0', label: 'Ventes'),
            ],
          ),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

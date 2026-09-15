import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/client/presentation/widgets/product_card.dart';
import 'package:bibomarketmobile/features/client/providers/client_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:bibomarketmobile/shared/widgets/error_view.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientHomePage extends ConsumerWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProductsProvider);
    final latest = ref.watch(latestProductsProvider);
    final categories = ref.watch(productCategoriesProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BIBO MARKET'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(LucideIcons.search),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(LucideIcons.bell),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(latestProductsProvider);
          ref.invalidate(productCategoriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Bonjour ${user?.firstName ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => context.push(AppRoutes.search),
              child: const Row(
                children: [
                  Icon(LucideIcons.search, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Rechercher un produit'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            categories.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ActionChip(
                      label: Text(item.name),
                      onPressed: () => context.push(
                        '${AppRoutes.categories}?id=${item.id}&name=${Uri.encodeComponent(item.name)}',
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF163A5F)],
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explorez le marché',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Produits publiés par les boutiques partenaires.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.shops),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(88, 40),
                    ),
                    child: const Text('Boutiques'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text('Produits populaires', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.search),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            featured.when(
              loading: () => const AppLoader(),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(featuredProductsProvider),
              ),
              data: (items) => items.isEmpty
                  ? const EmptyState(message: 'Aucun produit populaire.')
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.take(4).length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) => ProductCard(product: items[index]),
                    ),
            ),
            const SizedBox(height: 16),
            const Text('Nouveautés', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            latest.when(
              loading: () => const AppLoader(),
              error: (error, _) => Text(error.toString()),
              data: (items) => items.isEmpty
                  ? const EmptyState(message: 'Aucun produit récent.')
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.take(4).length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) => ProductCard(product: items[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(merchantOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantCenteredHeader(title: 'Statistiques'),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: overview.when(
                loading: () => const AppLoader(),
                error: (error, _) => Center(
                  child: Text(error.toString().replaceFirst('Exception: ', '')),
                ),
                data: (data) {
                  final top = data.merchantStats.topProducts.isNotEmpty
                      ? data.merchantStats.topProducts
                      : data.products
                          .map(
                            (product) => MerchantTopProduct(
                              name: product.name,
                              totalRevenue: product.price,
                            ),
                          )
                          .toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MerchantCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ventes',
                                    style: TextStyle(color: AppColors.muted),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatCfa(data.salesTotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MerchantCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Commandes',
                                    style: TextStyle(color: AppColors.muted),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${data.ordersCount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MerchantCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Évolution des ventes',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 110,
                              decoration: BoxDecoration(
                                color: AppColors.light,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.show_chart_rounded,
                                  color: AppColors.secondary,
                                  size: 64,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Produits les plus vendus',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (top.isEmpty)
                        const MerchantCard(
                          child: Text('Pas encore de produits'),
                        )
                      else
                        ...top.take(3).map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MerchantCard(
                              child: Row(
                                children: [
                                  Expanded(child: Text(product.name)),
                                  Text(formatCfa(product.totalRevenue)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

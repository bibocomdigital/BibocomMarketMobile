import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(merchantOverviewProvider);
    final user = ref.watch(authNotifierProvider).user;
    final shopName = overview.value?.shop?.name ??
        user?.displayName ??
        'votre espace';

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          MerchantHeader(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $shopName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voici votre aperçu aujourd’hui',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.push(AppRoutes.merchantNotifications),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.merchantMessages),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: overview.when(
                loading: () => const AppLoader(),
                error: (error, _) => _DashboardError(
                  message: error.toString().replaceFirst('Exception: ', ''),
                  onRetry: () => ref.invalidate(merchantOverviewProvider),
                ),
                data: (data) => _DashboardBody(overview: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        MerchantCard(
          child: Column(
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.overview});

  final ShopOverview overview;

  @override
  Widget build(BuildContext context) {
    final values = overview.merchantStats.chart.isNotEmpty
        ? overview.merchantStats.chart.map((point) => point.revenue).toList()
        : _chartValues(overview.orders);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatMiniCard(
                label: 'Ventes aujourd’hui',
                value: formatCfa(overview.salesTotal),
                trend: overview.orders.isEmpty ? '—' : '+12%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatMiniCard(
                label: 'Commandes',
                value: '${overview.ordersCount}',
                trend: overview.merchantStats.pendingOrders > 0
                    ? '${overview.merchantStats.pendingOrders} en attente'
                    : (overview.ordersCount == 0 ? '—' : 'commandes'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        MerchantCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Évolution des ventes',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(painter: _BarsPainter(values)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mes actions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _ActionTile(
              icon: Icons.add_box_outlined,
              label: 'Ajouter un produit',
              onTap: () => context.push(AppRoutes.addProduct),
            ),
            _ActionTile(
              icon: Icons.inventory_outlined,
              label: 'Voir les stocks',
              onTap: () => context.push(AppRoutes.stock),
            ),
            _ActionTile(
              icon: Icons.local_offer_outlined,
              label: 'Promotions',
              onTap: () => context.push(AppRoutes.promotions),
            ),
            _ActionTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Paiements',
              onTap: () => context.push(AppRoutes.payments),
            ),
          ],
        ),
        if (overview.shop == null) ...[
          const SizedBox(height: 16),
          MerchantCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Créez votre boutique pour commencer à vendre.',
                  style: TextStyle(color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.push(AppRoutes.editShop),
                  child: const Text('Créer ma boutique'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<double> _chartValues(List<MerchantOrder> orders) {
    final buckets = List<double>.filled(7, 0);
    final now = DateTime.now();
    for (final order in orders) {
      final date = DateTime.tryParse(order.createdAt);
      if (date == null) continue;
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < 7) {
        buckets[6 - diff] += order.totalAmount;
      }
    }
    if (buckets.every((value) => value == 0)) {
      return const [8, 14, 10, 18, 12, 16, 20];
    }
    return buckets;
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.trend,
  });

  final String label;
  final String value;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return MerchantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: const TextStyle(color: AppColors.success, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MerchantCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final max = values.reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / (values.length * 1.8);
    final paint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    final accent = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    for (var i = 0; i < values.length; i++) {
      final height = max == 0 ? 8.0 : (values[i] / max) * (size.height - 8);
      final x = (i + 0.4) * (size.width / values.length);
      final rect = RRect.fromLTRBR(
        x,
        size.height - height,
        x + barWidth,
        size.height,
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, i == values.length - 1 ? accent : paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.values != values;
}

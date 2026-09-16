import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  bool _delivered = false;

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(merchantOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantCenteredHeader(title: 'Commandes'),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: overview.when(
                loading: () => const AppLoader(),
                error: (error, _) => Center(
                  child: Text(error.toString().replaceFirst('Exception: ', '')),
                ),
                data: (data) {
                  final orders = data.orders
                      .where((order) => _delivered == order.isDelivered)
                      .toList();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Row(
                          children: [
                            _TabChip(
                              label: 'En cours',
                              selected: !_delivered,
                              onTap: () => setState(() => _delivered = false),
                            ),
                            const SizedBox(width: 8),
                            _TabChip(
                              label: 'Livrées',
                              selected: _delivered,
                              onTap: () => setState(() => _delivered = true),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: orders.isEmpty
                            ? const Center(child: Text('Aucune commande'))
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  24,
                                ),
                                itemCount: orders.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  return _OrderTile(order: orders[index]);
                                },
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

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final MerchantOrder order;

  @override
  Widget build(BuildContext context) {
    final preview = order.items.isEmpty ? null : order.items.first;
    return MerchantCard(
      onTap: () => context.push(AppRoutes.orderDetailPath(order.id)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: preview?.imageUrl == null
                  ? Container(
                      color: AppColors.light,
                      child: const Icon(Icons.shopping_bag_outlined),
                    )
                  : Image.network(preview!.imageUrl!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#BM-${order.id.toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  formatCfa(order.totalAmount),
                  style: const TextStyle(color: AppColors.accent),
                ),
                Text(
                  order.clientName ?? 'Client',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatShortDate(order.createdAt),
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

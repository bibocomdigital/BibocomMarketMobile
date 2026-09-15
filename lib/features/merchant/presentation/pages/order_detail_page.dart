import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Détail commande'),
          Expanded(
            child: detail.when(
              loading: () => const AppLoader(),
              error: (error, _) => Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
              data: (order) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    MerchantCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client : ${order.clientName ?? 'Client'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatShortDate(order.createdAt),
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MerchantCard(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${item.quantity} x ${item.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(formatCfa(item.price * item.quantity)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    MerchantCard(
                      child: Row(
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            formatCfa(order.totalAmount),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.push(AppRoutes.messages);
                      },
                      child: const Text('Contacter le client'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(merchantRepositoryProvider)
                            .updateOrderStatus(order.id, 'DELIVERED');
                        ref.invalidate(merchantOverviewProvider);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text('Marquer comme livrée'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
